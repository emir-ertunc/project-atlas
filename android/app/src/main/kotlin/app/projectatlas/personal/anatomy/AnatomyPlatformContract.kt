package app.projectatlas.personal.anatomy

internal object AnatomyPlatformContract {
    const val VIEW_TYPE = "project_atlas/anatomy_renderer"
    const val METHOD_CHANNEL = "project_atlas/anatomy_renderer_bridge"
    const val DEFAULT_LOD_TIER = "lod2"
    const val DEFAULT_RENDER_MODE = "interactive_lite"
    const val RENDER_LOOP_MODE = "dirty_frame"

    val SUPPORTED_LOD_TIERS = listOf("lod2")
    val SUPPORTED_RENDER_MODES = listOf(DEFAULT_RENDER_MODE)

    val REQUIRED_NODE_EXTRAS = listOf(
        "muscle_region_id",
        "semantic_group_id",
        "side",
        "reduction_slot",
        "source_element_ids",
    )
}
