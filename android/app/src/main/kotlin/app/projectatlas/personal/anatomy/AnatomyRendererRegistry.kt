package app.projectatlas.personal.anatomy

internal object AnatomyRendererRegistry {
    private val views = mutableMapOf<Int, AnatomyRendererView>()

    fun register(viewId: Int, view: AnatomyRendererView) {
        views[viewId] = view
    }

    fun unregister(viewId: Int) {
        views.remove(viewId)
    }

    fun view(viewId: Int): AnatomyRendererView? = views[viewId]
}
