package app.projectatlas.personal

import app.projectatlas.personal.anatomy.AnatomyPlatformContract
import app.projectatlas.personal.anatomy.AnatomyRendererBridge
import app.projectatlas.personal.anatomy.AnatomyRendererViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var anatomyRendererBridge: AnatomyRendererBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                AnatomyPlatformContract.VIEW_TYPE,
                AnatomyRendererViewFactory(),
            )
        anatomyRendererBridge = AnatomyRendererBridge(flutterEngine.dartExecutor.binaryMessenger)
    }
}
