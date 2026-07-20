param(
    [Parameter(Mandatory = $true)]
    [string]$SourceArchive,

    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,

    [string]$BlenderExecutable,

    [string]$ReductionManifest,

    [string]$Ontology,

    [string]$Config
)

$ErrorActionPreference = 'Stop'
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$anatomyDirectory = Split-Path -Parent $scriptDirectory

if (-not $ReductionManifest) {
    $ReductionManifest = Join-Path $anatomyDirectory 'bodyparts3d_region_reduction.v1.json'
}
if (-not $Ontology) {
    $Ontology = Join-Path $anatomyDirectory 'muscle_region_ontology.v1.json'
}
if (-not $Config) {
    $Config = Join-Path $scriptDirectory 'pipeline_config.v1.json'
}
if (-not $BlenderExecutable) {
    $command = Get-Command blender -ErrorAction SilentlyContinue
    if ($command) {
        $BlenderExecutable = $command.Source
    } else {
        $candidate = Get-ChildItem `
            -LiteralPath 'C:\Program Files\Blender Foundation' `
            -Recurse `
            -Filter blender.exe `
            -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if ($candidate) {
            $BlenderExecutable = $candidate.FullName
        }
    }
}

foreach ($path in @(
    $BlenderExecutable,
    $SourceArchive,
    $ReductionManifest,
    $Ontology,
    $Config
)) {
    if (-not $path -or -not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required pipeline input is missing: $path"
    }
}

$pipeline = Join-Path $scriptDirectory 'anatomy_pipeline.py'
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

$arguments = @(
    '--background',
    '--factory-startup',
    '--python', $pipeline,
    '--',
    '--source-archive', $SourceArchive,
    '--reduction-manifest', $ReductionManifest,
    '--ontology', $Ontology,
    '--config', $Config,
    '--output-directory', $OutputDirectory
)
& $BlenderExecutable @arguments

if ($LASTEXITCODE -ne 0) {
    throw "Blender anatomy pipeline failed with exit code $LASTEXITCODE"
}

$blenderDirectory = Split-Path -Parent (Resolve-Path -LiteralPath $BlenderExecutable)
$python = Get-ChildItem `
    -LiteralPath $blenderDirectory `
    -Recurse `
    -Filter python.exe `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '[\\/]python[\\/]bin[\\/]python\.exe$' } |
    Select-Object -First 1
if (-not $python) {
    throw 'Blender bundled Python executable was not found'
}

$validator = Join-Path $scriptDirectory 'validate_outputs.py'
$validatorArguments = @(
    $validator,
    '--output-directory', $OutputDirectory,
    '--source-archive', $SourceArchive,
    '--reduction-manifest', $ReductionManifest,
    '--ontology', $Ontology,
    '--config', $Config,
    '--pipeline-script', $pipeline
)
& $python.FullName @validatorArguments
if ($LASTEXITCODE -ne 0) {
    throw "Anatomy output validation failed with exit code $LASTEXITCODE"
}
