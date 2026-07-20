package app.projectatlas.personal.anatomy

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class AnatomyRendererBridge(binaryMessenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(binaryMessenger, AnatomyPlatformContract.METHOD_CHANNEL)

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCapabilities" -> result.success(capabilities())
            "setCameraPose" -> withRenderer(call, result) { view ->
                view.setCameraPose(
                    requiredDouble(call, "yawDegrees"),
                    requiredDouble(call, "pitchDegrees"),
                    requiredDouble(call, "zoom"),
                )
            }
            "setHeatmap" -> withRenderer(call, result) { view ->
                view.setHeatmap(readHeatmap(call.argument<Map<*, *>>("heatmap")))
            }
            "selectRegion" -> withRenderer(call, result) { view ->
                view.selectRegion(call.argument<String>("regionId"))
            }
            "pick" -> withRenderer(call, result) { view ->
                view.pick(
                    requiredDouble(call, "normalizedX"),
                    requiredDouble(call, "normalizedY"),
                )
            }
            "getState" -> withRenderer(call, result) { view ->
                view.rendererState()
            }
            else -> result.notImplemented()
        }
    }

    private fun capabilities(): Map<String, Any> = mapOf(
        "platform" to "android",
        "backend" to "filament",
        "viewType" to AnatomyPlatformContract.VIEW_TYPE,
        "supportsGlb" to true,
        "supportsOrbitCamera" to true,
        "supportsZoom" to true,
        "supportsPicking" to true,
        "supportsHeatmap" to true,
        "assetBundled" to false,
        "requiredNodeExtras" to AnatomyPlatformContract.REQUIRED_NODE_EXTRAS,
        "supportsLod" to true,
        "supportedLodTiers" to AnatomyPlatformContract.SUPPORTED_LOD_TIERS,
        "defaultLodTier" to AnatomyPlatformContract.DEFAULT_LOD_TIER,
        "defaultRenderMode" to AnatomyPlatformContract.DEFAULT_RENDER_MODE,
        "renderLoopMode" to AnatomyPlatformContract.RENDER_LOOP_MODE,
    )

    private fun withRenderer(
        call: MethodCall,
        result: MethodChannel.Result,
        action: (AnatomyRendererView) -> Map<String, Any?>,
    ) {
        val viewId = call.argument<Int>("viewId")
        if (viewId == null) {
            result.error("missing_view_id", "Renderer viewId is required.", null)
            return
        }

        val view = AnatomyRendererRegistry.view(viewId)
        if (view == null) {
            result.error("renderer_not_found", "No anatomy renderer is registered for viewId $viewId.", null)
            return
        }

        try {
            result.success(action(view))
        } catch (error: IllegalArgumentException) {
            result.error("invalid_arguments", error.message, null)
        }
    }

    private fun requiredDouble(call: MethodCall, key: String): Double {
        val value = call.argument<Number>(key)
        require(value != null) { "$key is required." }
        return value.toDouble()
    }

    private fun readHeatmap(value: Map<*, *>?): Map<String, Double> {
        if (value == null) {
            return emptyMap()
        }
        return value
            .mapNotNull { (key, rawValue) ->
                val regionId = key as? String ?: return@mapNotNull null
                val score = (rawValue as? Number)?.toDouble() ?: return@mapNotNull null
                regionId to score
            }
            .toMap()
    }
}
