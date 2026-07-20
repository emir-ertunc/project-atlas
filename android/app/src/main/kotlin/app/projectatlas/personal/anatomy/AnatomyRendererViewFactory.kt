package app.projectatlas.personal.anatomy

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

internal class AnatomyRendererViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<*, *> ?: emptyMap<Any, Any>()
        return AnatomyRendererView(context, viewId, creationParams)
    }
}
