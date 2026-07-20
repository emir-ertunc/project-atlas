package app.projectatlas.personal.anatomy

import android.content.Context
import android.view.Choreographer
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.widget.FrameLayout
import com.google.android.filament.Camera
import com.google.android.filament.Engine
import com.google.android.filament.EntityManager
import com.google.android.filament.Filament
import com.google.android.filament.Renderer
import com.google.android.filament.Scene
import com.google.android.filament.SwapChain
import com.google.android.filament.Viewport
import com.google.android.filament.View as FilamentView
import io.flutter.plugin.platform.PlatformView
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.min
import kotlin.math.sin

internal class AnatomyRendererView(
    context: Context,
    private val viewId: Int,
    creationParams: Map<*, *>,
) : PlatformView, SurfaceHolder.Callback, Choreographer.FrameCallback {
    private val container = FrameLayout(context)
    private val surfaceView = SurfaceView(context)
    private val expectedNodeExtras =
        (creationParams["expectedNodeExtras"] as? List<*>)
            ?.mapNotNull { it as? String }
            ?.takeIf { it.isNotEmpty() }
            ?: AnatomyPlatformContract.REQUIRED_NODE_EXTRAS
    private val contentDescription =
        creationParams["contentDescription"] as? String ?: "Anatomy renderer"
    private val lodTier = readSupportedValue(
        creationParams,
        "lodTier",
        AnatomyPlatformContract.DEFAULT_LOD_TIER,
        AnatomyPlatformContract.SUPPORTED_LOD_TIERS,
    )
    private val renderMode = readSupportedValue(
        creationParams,
        "renderMode",
        AnatomyPlatformContract.DEFAULT_RENDER_MODE,
        AnatomyPlatformContract.SUPPORTED_RENDER_MODES,
    )
    private var pickableRegionIds =
        (creationParams["pickableRegionIds"] as? List<*>)
            ?.mapNotNull { it as? String }
            ?.takeIf { it.isNotEmpty() }
            ?: emptyList()

    private val engine: Engine
    private val renderer: Renderer
    private val scene: Scene
    private val filamentView: FilamentView
    private val cameraEntity: Int
    private val camera: Camera

    private var swapChain: SwapChain? = null
    private var disposed = false
    private var frameCallbackPosted = false
    private var viewportWidth = 1
    private var viewportHeight = 1
    private var yawDegrees = readPose(creationParams, "yawDegrees", 0.0)
    private var pitchDegrees = readPose(creationParams, "pitchDegrees", 8.0)
    private var zoom = readPose(creationParams, "zoom", 4.0)
    private var selectedRegionId: String? = null
    private var heatmapScores = readHeatmap(creationParams)

    init {
        Filament.init()

        engine = Engine.create()
        renderer = engine.createRenderer()
        scene = engine.createScene()
        filamentView = engine.createView()
        cameraEntity = EntityManager.get().create()
        camera = engine.createCamera(cameraEntity)

        filamentView.scene = scene
        filamentView.camera = camera
        surfaceView.holder.addCallback(this)
        surfaceView.contentDescription = contentDescription
        AnatomyRendererRegistry.register(viewId, this)
        container.addView(
            surfaceView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )
    }

    override fun getView(): android.view.View = container

    override fun dispose() {
        if (disposed) {
            return
        }
        disposed = true
        AnatomyRendererRegistry.unregister(viewId)
        surfaceView.holder.removeCallback(this)
        cancelRenderFrame()
        destroySwapChain()
        engine.destroyCameraComponent(cameraEntity)
        EntityManager.get().destroy(cameraEntity)
        engine.destroyView(filamentView)
        engine.destroyScene(scene)
        engine.destroyRenderer(renderer)
        engine.destroy()
    }

    override fun surfaceCreated(holder: SurfaceHolder) {
        if (disposed) {
            return
        }
        swapChain = engine.createSwapChain(holder.surface)
        requestRenderFrame()
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        if (disposed || width <= 0 || height <= 0) {
            return
        }

        viewportWidth = width
        viewportHeight = height
        updateViewportAndCamera()
        requestRenderFrame()
    }

    fun setCameraPose(
        nextYawDegrees: Double,
        nextPitchDegrees: Double,
        nextZoom: Double,
    ): Map<String, Any> {
        yawDegrees = normalizeYaw(nextYawDegrees)
        pitchDegrees = nextPitchDegrees.coerceIn(MIN_PITCH_DEGREES, MAX_PITCH_DEGREES)
        zoom = nextZoom.coerceIn(MIN_ZOOM, MAX_ZOOM)
        updateViewportAndCamera()
        requestRenderFrame()
        return cameraPose()
    }

    fun setHeatmap(scores: Map<String, Double>): Map<String, Any?> {
        heatmapScores = scores
            .filterKeys { it.isNotBlank() }
            .mapValues { (_, value) -> value.coerceIn(0.0, 1.0) }
        if (heatmapScores.isNotEmpty()) {
            pickableRegionIds = heatmapScores.keys.sorted()
        }
        requestRenderFrame()
        return rendererState()
    }

    fun selectRegion(regionId: String?): Map<String, Any?> {
        selectedRegionId = regionId?.takeIf { it.isNotBlank() }
        requestRenderFrame()
        return rendererState()
    }

    fun pick(normalizedX: Double, normalizedY: Double): Map<String, Any?> {
        val x = normalizedX.coerceIn(0.0, 1.0)
        val y = normalizedY.coerceIn(0.0, 1.0)
        selectedRegionId =
            if (pickableRegionIds.isEmpty()) {
                null
            } else {
                val index = min(
                    pickableRegionIds.lastIndex,
                    floor(x * pickableRegionIds.size).toInt(),
                )
                pickableRegionIds[index]
            }
        requestRenderFrame()
        return mapOf(
            "hit" to (selectedRegionId != null),
            "regionId" to selectedRegionId,
            "normalizedX" to x,
            "normalizedY" to y,
        )
    }

    fun rendererState(): Map<String, Any?> = mapOf(
        "viewId" to viewId,
        "cameraPose" to cameraPose(),
        "heatmap" to heatmapScores,
        "selectedRegionId" to selectedRegionId,
        "pickableRegionIds" to pickableRegionIds,
        "expectedNodeExtras" to expectedNodeExtras,
        "lodTier" to lodTier,
        "renderMode" to renderMode,
        "renderLoopMode" to AnatomyPlatformContract.RENDER_LOOP_MODE,
    )

    private fun updateViewportAndCamera() {
        filamentView.viewport = Viewport(0, 0, viewportWidth, viewportHeight)
        val aspect = viewportWidth.toDouble() / viewportHeight.toDouble()
        camera.setProjection(45.0, aspect, 0.05, 100.0, Camera.Fov.VERTICAL)
        updateCamera()
    }

    private fun updateCamera() {
        val yaw = yawDegrees * PI / 180.0
        val pitch = pitchDegrees * PI / 180.0
        val horizontalRadius = zoom * cos(pitch)
        val eyeX = TARGET_X + horizontalRadius * sin(yaw)
        val eyeY = TARGET_Y + zoom * sin(pitch)
        val eyeZ = TARGET_Z + horizontalRadius * cos(yaw)
        camera.lookAt(
            eyeX,
            eyeY,
            eyeZ,
            TARGET_X,
            TARGET_Y,
            TARGET_Z,
            0.0,
            1.0,
            0.0,
        )
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        cancelRenderFrame()
        destroySwapChain()
    }

    override fun doFrame(frameTimeNanos: Long) {
        frameCallbackPosted = false
        if (disposed) {
            return
        }

        val currentSwapChain = swapChain
        if (currentSwapChain != null && renderer.beginFrame(currentSwapChain, frameTimeNanos)) {
            renderer.render(filamentView)
            renderer.endFrame()
        }

    }

    private fun requestRenderFrame() {
        if (disposed || frameCallbackPosted || swapChain == null) {
            return
        }
        frameCallbackPosted = true
        Choreographer.getInstance().postFrameCallback(this)
    }

    private fun cancelRenderFrame() {
        if (frameCallbackPosted) {
            frameCallbackPosted = false
            Choreographer.getInstance().removeFrameCallback(this)
        }
    }

    private fun destroySwapChain() {
        swapChain?.let {
            engine.destroySwapChain(it)
            swapChain = null
        }
    }

    fun metadataContract(): Map<String, Any> = mapOf(
        "viewId" to viewId,
        "expectedNodeExtras" to expectedNodeExtras,
    )

    private fun cameraPose(): Map<String, Double> = mapOf(
        "yawDegrees" to yawDegrees,
        "pitchDegrees" to pitchDegrees,
        "zoom" to zoom,
    )

    private fun normalizeYaw(value: Double): Double {
        var result = value % 360.0
        if (result < -180.0) {
            result += 360.0
        }
        if (result > 180.0) {
            result -= 360.0
        }
        return result
    }

    private fun readPose(params: Map<*, *>, key: String, fallback: Double): Double {
        val pose = params["initialCameraPose"] as? Map<*, *>
        return (pose?.get(key) as? Number)?.toDouble() ?: fallback
    }

    private fun readSupportedValue(
        params: Map<*, *>,
        key: String,
        fallback: String,
        supportedValues: List<String>,
    ): String {
        val value = params[key] as? String
        return value?.takeIf { supportedValues.contains(it) } ?: fallback
    }

    private fun readHeatmap(params: Map<*, *>): Map<String, Double> {
        val map = params["initialHeatmap"] as? Map<*, *> ?: return emptyMap()
        return map
            .mapNotNull { (key, value) ->
                val regionId = key as? String ?: return@mapNotNull null
                val score = (value as? Number)?.toDouble() ?: return@mapNotNull null
                regionId to score.coerceIn(0.0, 1.0)
            }
            .toMap()
    }

    companion object {
        private const val TARGET_X = 0.0
        private const val TARGET_Y = 0.85
        private const val TARGET_Z = 0.0
        private const val MIN_PITCH_DEGREES = -70.0
        private const val MAX_PITCH_DEGREES = 70.0
        private const val MIN_ZOOM = 1.2
        private const val MAX_ZOOM = 8.0
    }
}
