[CmdletBinding()]
param(
    [string] $DeviceId = "",
    [string] $PackageName = "app.projectatlas.personal",
    [string] $ActivityName = ".MainActivity",
    [ValidateRange(5, 60)]
    [int] $SampleSeconds = 15,
    [switch] $SkipBuild,
    [switch] $SkipInstall,
    [switch] $SkipInteraction,
    [string] $ProjectPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDirectory = if ($PSScriptRoot.Trim().Length -gt 0) {
    $PSScriptRoot
} else {
    Split-Path -Parent $MyInvocation.MyCommand.Path
}

if ($ProjectPath.Trim().Length -eq 0) {
    $ProjectPath = (Resolve-Path (Join-Path $ScriptDirectory "..\..")).Path
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string] $File,
        [Parameter(Mandatory = $true)]
        [string[]] $Arguments,
        [string] $WorkingDirectory = $ProjectPath
    )

    Push-Location $WorkingDirectory
    try {
        $output = & $File @Arguments 2>&1
        if ($LASTEXITCODE -ne 0) {
            $joinedArguments = $Arguments -join " "
            throw "$File $joinedArguments failed with exit code $LASTEXITCODE.`n$output"
        }
        return @($output)
    } finally {
        Pop-Location
    }
}

function Invoke-Adb {
    param([Parameter(Mandatory = $true)] [string[]] $Arguments)

    $fullArguments = @()
    if ($DeviceId.Trim().Length -gt 0) {
        $fullArguments += "-s"
        $fullArguments += $DeviceId.Trim()
    }
    $fullArguments += $Arguments

    return Invoke-Checked -File "adb" -Arguments $fullArguments
}

function Get-AuthorizedDevice {
    $rows = Invoke-Checked -File "adb" -Arguments @("devices", "-l")
    $devices = @(
        $rows |
            Where-Object { $_ -match "^\S+\s+device\b" } |
            ForEach-Object { ($_ -split "\s+")[0] }
    )

    if ($DeviceId.Trim().Length -gt 0) {
        if ($devices -notcontains $DeviceId.Trim()) {
            throw "Device '$DeviceId' is not listed as an authorized Android device."
        }
        return $DeviceId.Trim()
    }

    if ($devices.Count -eq 0) {
        throw "No authorized Android device found. Connect an unlocked physical device, accept USB debugging, then rerun this script."
    }

    if ($devices.Count -gt 1) {
        throw "Multiple Android devices are connected. Pass -DeviceId with one of: $($devices -join ', ')."
    }

    return $devices[0]
}

function Get-DeviceProperty {
    param([Parameter(Mandatory = $true)] [string] $Name)

    $value = Invoke-Adb -Arguments @("shell", "getprop", $Name)
    return ($value | Select-Object -First 1).Trim()
}

function Get-ScreenSize {
    $wmSize = Invoke-Adb -Arguments @("shell", "wm", "size")
    foreach ($line in $wmSize) {
        if ($line -match "Physical size:\s*(\d+)x(\d+)") {
            return [ordered] @{
                width = [int] $Matches[1]
                height = [int] $Matches[2]
            }
        }
    }

    return [ordered] @{
        width = 720
        height = 1600
    }
}

function Convert-StartMetrics {
    param([AllowEmptyString()] [string[]] $Lines = @())

    $metrics = [ordered] @{}
    foreach ($line in $Lines) {
        if ($line -match "^\s*(ThisTime|TotalTime|WaitTime):\s*(\d+)") {
            $metrics[$Matches[1]] = [int] $Matches[2]
        }
    }
    return $metrics
}

function Convert-PerfMarkers {
    param([AllowEmptyString()] [string[]] $Lines = @())

    $markers = [ordered] @{}
    foreach ($line in $Lines) {
        if ($line -match "PROJECT_ATLAS_PERF\s+([a-z0-9_]+)\s+elapsed_ms=(\d+)") {
            $markers[$Matches[1]] = [int] $Matches[2]
        }
    }
    return $markers
}

function Convert-MemoryMetrics {
    param([AllowEmptyString()] [string[]] $Lines = @())

    $metrics = [ordered] @{}
    foreach ($line in $Lines) {
        if ($line -match "^\s*TOTAL\s+(\d+)") {
            $metrics["totalPssKb"] = [int] $Matches[1]
        }
        if ($line -match "TOTAL PSS:\s+(\d+)") {
            $metrics["totalPssKb"] = [int] $Matches[1]
        }
        if ($line -match "TOTAL RSS:\s+(\d+)") {
            $metrics["totalRssKb"] = [int] $Matches[1]
        }
    }
    return $metrics
}

function Convert-FrameMetrics {
    param(
        [AllowEmptyString()]
        [string[]] $Lines = @(),
        [Parameter(Mandatory = $true)]
        [int] $SampleSeconds
    )

    $header = $null
    $frameDurationsMs = New-Object System.Collections.Generic.List[double]
    $histogramDurationsMs = New-Object System.Collections.Generic.List[double]
    $aggregateFrames = $null
    $aggregateJankyFrames = $null
    $aggregateP90 = $null
    $aggregateP95 = $null
    $insideAggregate = $false

    foreach ($line in $Lines) {
        if ($line -match "^\*\* Graphics info for pid") {
            $insideAggregate = $true
            continue
        }

        if ($insideAggregate -and $line -match "^Pipeline=") {
            $insideAggregate = $false
        }

        if ($insideAggregate) {
            if ($line -match "^Total frames rendered:\s*(\d+)") {
                $aggregateFrames = [int] $Matches[1]
                continue
            }

            if ($line -match "^Janky frames:\s*(\d+)") {
                $aggregateJankyFrames = [int] $Matches[1]
                continue
            }

            if ($line -match "^90th percentile:\s*(\d+)ms") {
                $aggregateP90 = [double] $Matches[1]
                continue
            }

            if ($line -match "^95th percentile:\s*(\d+)ms") {
                $aggregateP95 = [double] $Matches[1]
                continue
            }

            if ($line -match "^HISTOGRAM:\s*(.+)$") {
                foreach ($bucket in ($Matches[1] -split "\s+")) {
                    if ($bucket -match "^(\d+)ms=(\d+)$") {
                        $bucketMs = [double] $Matches[1]
                        $count = [int] $Matches[2]
                        for ($index = 0; $index -lt $count; $index++) {
                            $histogramDurationsMs.Add($bucketMs)
                        }
                    }
                }
                continue
            }
        }

        if ($line -like "Flags,*FrameCompleted*") {
            $header = $line.Split(",")
            continue
        }

        if ($null -eq $header -or $line -notmatch "^\d+,") {
            continue
        }

        $columns = $line.Split(",")
        if ($columns.Length -lt $header.Length) {
            continue
        }

        $startIndex = [Array]::IndexOf($header, "IntendedVsync")
        $completeIndex = [Array]::IndexOf($header, "FrameCompleted")
        if ($startIndex -lt 0 -or $completeIndex -lt 0) {
            continue
        }

        $startNs = [int64] $columns[$startIndex]
        $completeNs = [int64] $columns[$completeIndex]
        if ($completeNs -le $startNs) {
            continue
        }

        $frameDurationsMs.Add(($completeNs - $startNs) / 1000000.0)
    }

    if ($null -ne $aggregateFrames -and $aggregateFrames -gt 0) {
        $average = 0
        $frozenFrames = 0
        if ($histogramDurationsMs.Count -gt 0) {
            $average = ($histogramDurationsMs | Measure-Object -Average).Average
            $frozenFrames = @($histogramDurationsMs | Where-Object { $_ -gt 700 }).Count
        }

        $p90 = if ($null -ne $aggregateP90) { $aggregateP90 } else { 0 }
        $p95 = if ($null -ne $aggregateP95) { $aggregateP95 } else { 0 }
        $jankyFrames = if ($null -ne $aggregateJankyFrames) { $aggregateJankyFrames } else { 0 }

        return [ordered] @{
            frameCount = $aggregateFrames
            estimatedFps = [Math]::Round($aggregateFrames / $SampleSeconds, 2)
            averageFrameMs = [Math]::Round($average, 2)
            p90FrameMs = [Math]::Round($p90, 2)
            p95FrameMs = [Math]::Round($p95, 2)
            jankyFrameCount = $jankyFrames
            frozenFrameCount = $frozenFrames
        }
    }

    if ($frameDurationsMs.Count -eq 0) {
        return [ordered] @{
            frameCount = 0
            estimatedFps = 0
            averageFrameMs = 0
            p90FrameMs = 0
            p95FrameMs = 0
            jankyFrameCount = 0
            frozenFrameCount = 0
        }
    }

    $sorted = @($frameDurationsMs | Sort-Object)
    $average = ($frameDurationsMs | Measure-Object -Average).Average
    $p90Index = [Math]::Min($sorted.Count - 1, [Math]::Floor($sorted.Count * 0.90))
    $p95Index = [Math]::Min($sorted.Count - 1, [Math]::Floor($sorted.Count * 0.95))
    $jankyFrames = @($frameDurationsMs | Where-Object { $_ -gt 16.67 })
    $frozenFrames = @($frameDurationsMs | Where-Object { $_ -gt 700 })

    return [ordered] @{
        frameCount = $frameDurationsMs.Count
        estimatedFps = [Math]::Round($frameDurationsMs.Count / $SampleSeconds, 2)
        averageFrameMs = [Math]::Round($average, 2)
        p90FrameMs = [Math]::Round($sorted[$p90Index], 2)
        p95FrameMs = [Math]::Round($sorted[$p95Index], 2)
        jankyFrameCount = $jankyFrames.Count
        frozenFrameCount = $frozenFrames.Count
    }
}

function Write-MarkdownSummary {
    param(
        [Parameter(Mandatory = $true)] [string] $Path,
        [Parameter(Mandatory = $true)] [object] $Result
    )

    function Get-Value {
        param(
            [Parameter(Mandatory = $true)] [object] $Map,
            [Parameter(Mandatory = $true)] [string] $Key
        )

        if ($Map.Contains($Key) -and $null -ne $Map[$Key]) {
            return $Map[$Key]
        }
        return "not captured"
    }

    $lines = @(
        "# P2-07 Anatomy Renderer Performance Measurement",
        "",
        "- Timestamp: $($Result.timestampUtc)",
        "- Device ID: $($Result.device.id)",
        "- Device: $($Result.device.manufacturer) $($Result.device.model)",
        "- Android: $($Result.device.androidRelease) API $($Result.device.androidSdk)",
        "- ABI: $($Result.device.abi)",
        "- Build mode: profile",
        "- Initial route: /anatomy",
        "- Sample window: $($Result.sampleSeconds) seconds",
        "- Sample mode: $($Result.sampleMode)",
        "",
        "## Load",
        "",
        "- Activity `ThisTime`: $(Get-Value -Map $Result.load -Key 'thisTimeMs') ms",
        "- Activity `TotalTime`: $(Get-Value -Map $Result.load -Key 'totalTimeMs') ms",
        "- Activity `WaitTime`: $(Get-Value -Map $Result.load -Key 'waitTimeMs') ms",
        "- App main marker: $(Get-Value -Map $Result.markers -Key 'app_main') ms",
        "- Anatomy panel first frame marker: $(Get-Value -Map $Result.markers -Key 'anatomy_panel_first_frame') ms",
        "- Native platform view marker: $(Get-Value -Map $Result.markers -Key 'anatomy_platform_view_created') ms",
        "",
        "## Frames",
        "",
        "- Frame count: $($Result.frames.frameCount)",
        "- Estimated FPS: $($Result.frames.estimatedFps)",
        "- Average frame: $($Result.frames.averageFrameMs) ms",
        "- P90 frame: $($Result.frames.p90FrameMs) ms",
        "- P95 frame: $($Result.frames.p95FrameMs) ms",
        "- Janky frames over 16.67 ms: $($Result.frames.jankyFrameCount)",
        "- Frozen frames over 700 ms: $($Result.frames.frozenFrameCount)",
        "",
        "## Memory",
        "",
        "- Total PSS: $(Get-Value -Map $Result.memory -Key 'totalPssKb') KB",
        "- Total RSS: $(Get-Value -Map $Result.memory -Key 'totalRssKb') KB",
        "",
        "Raw JSON, gfxinfo, meminfo, launch output, and performance logcat are stored beside this file."
    )

    Set-Content -Path $Path -Value $lines -Encoding UTF8
}

$selectedDevice = Get-AuthorizedDevice
$DeviceId = $selectedDevice

if (-not $SkipBuild) {
    Invoke-Checked -File "flutter" -Arguments @(
        "build",
        "apk",
        "--profile",
        "--dart-define=PROJECT_ATLAS_INITIAL_LOCATION=/anatomy",
        "--dart-define=PROJECT_ATLAS_PERF_LOGS=true"
    ) -WorkingDirectory $ProjectPath | Out-Null
}

$apkPath = Join-Path $ProjectPath "build\app\outputs\flutter-apk\app-profile.apk"
if (-not (Test-Path $apkPath)) {
    throw "Profile APK not found at '$apkPath'. Run without -SkipBuild or build the profile APK first."
}

if (-not $SkipInstall) {
    Invoke-Adb -Arguments @("install", "-r", $apkPath) | Out-Null
}

$component = "$PackageName/$ActivityName"
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
$outputDirectory = Join-Path $ProjectPath "build\performance\p2-07\$timestamp"
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

Invoke-Adb -Arguments @("logcat", "-c") | Out-Null
Invoke-Adb -Arguments @("shell", "am", "force-stop", $PackageName) | Out-Null
Invoke-Adb -Arguments @("shell", "dumpsys", "gfxinfo", $PackageName, "reset") | Out-Null

$startOutput = Invoke-Adb -Arguments @("shell", "am", "start", "-W", "-S", "-n", $component)
$sampleMode = if ($SkipInteraction) { "static" } else { "touch_swipe_rotation" }

if ($SkipInteraction) {
    Start-Sleep -Seconds $SampleSeconds
} else {
    $screenSize = Get-ScreenSize
    [int] $leftX = [Math]::Max(1, [Math]::Floor([double] $screenSize["width"] * 0.25))
    [int] $rightX = [Math]::Max(1, [Math]::Floor([double] $screenSize["width"] * 0.75))
    [int] $centerY = [Math]::Max(1, [Math]::Floor([double] $screenSize["height"] * 0.42))
    $sampleEndsAt = (Get-Date).AddSeconds($SampleSeconds)
    $swipeRight = $true

    while ((Get-Date) -lt $sampleEndsAt) {
        if ($swipeRight) {
            Invoke-Adb -Arguments @("shell", "input", "swipe", "$leftX", "$centerY", "$rightX", "$centerY", "220") | Out-Null
        } else {
            Invoke-Adb -Arguments @("shell", "input", "swipe", "$rightX", "$centerY", "$leftX", "$centerY", "220") | Out-Null
        }

        $swipeRight = -not $swipeRight
        Start-Sleep -Milliseconds 120
    }
}

$gfxinfo = Invoke-Adb -Arguments @("shell", "dumpsys", "gfxinfo", $PackageName, "framestats")
$meminfo = Invoke-Adb -Arguments @("shell", "dumpsys", "meminfo", $PackageName)
$logcat = Invoke-Adb -Arguments @("logcat", "-d")
$perfLogcat = @($logcat | Where-Object { $_ -match "PROJECT_ATLAS_PERF" })

$device = [ordered] @{
    id = $selectedDevice
    manufacturer = Get-DeviceProperty "ro.product.manufacturer"
    model = Get-DeviceProperty "ro.product.model"
    androidRelease = Get-DeviceProperty "ro.build.version.release"
    androidSdk = Get-DeviceProperty "ro.build.version.sdk"
    abi = Get-DeviceProperty "ro.product.cpu.abi"
    hardware = Get-DeviceProperty "ro.hardware"
}

$startMetrics = Convert-StartMetrics -Lines $startOutput
$frameMetrics = Convert-FrameMetrics -Lines $gfxinfo -SampleSeconds $SampleSeconds
$memoryMetrics = Convert-MemoryMetrics -Lines $meminfo
$perfMarkers = Convert-PerfMarkers -Lines $perfLogcat

$result = [ordered] @{
    timestampUtc = (Get-Date).ToUniversalTime().ToString("o")
    packageName = $PackageName
    activityName = $ActivityName
    sampleSeconds = $SampleSeconds
    sampleMode = $sampleMode
    device = $device
    load = [ordered] @{
        thisTimeMs = $startMetrics["ThisTime"]
        totalTimeMs = $startMetrics["TotalTime"]
        waitTimeMs = $startMetrics["WaitTime"]
    }
    markers = $perfMarkers
    frames = $frameMetrics
    memory = $memoryMetrics
}

$jsonPath = Join-Path $outputDirectory "summary.json"
$markdownPath = Join-Path $outputDirectory "summary.md"
$result | ConvertTo-Json -Depth 8 | Set-Content -Path $jsonPath -Encoding UTF8
$startOutput | Set-Content -Path (Join-Path $outputDirectory "am_start.txt") -Encoding UTF8
$gfxinfo | Set-Content -Path (Join-Path $outputDirectory "gfxinfo_framestats.txt") -Encoding UTF8
$meminfo | Set-Content -Path (Join-Path $outputDirectory "meminfo.txt") -Encoding UTF8
$perfLogcatPath = Join-Path $outputDirectory "perf_logcat.txt"
New-Item -ItemType File -Force -Path $perfLogcatPath | Out-Null
if ($perfLogcat.Count -gt 0) {
    $perfLogcat | Set-Content -Path $perfLogcatPath -Encoding UTF8
}
Write-MarkdownSummary -Path $markdownPath -Result $result

Write-Output "P2-07 measurement written to $outputDirectory"
