package top.phj233.repolens_ai

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.staticCompositionLocalOf
import top.phj233.repolens_ai.components.KyantGlassSelectOption

internal data class AndroidSelectOverlayState(
    val id: Any,
    val options: List<KyantGlassSelectOption>,
    val selected: String,
    val anchorLeftPx: Float,
    val anchorTopPx: Float,
    val anchorWidthPx: Int,
    val onSelected: (String) -> Unit,
)

internal class AndroidSelectOverlayController {
    var state by mutableStateOf<AndroidSelectOverlayState?>(null)
        private set

    fun toggle(
        id: Any,
        options: List<KyantGlassSelectOption>,
        selected: String,
        anchorLeftPx: Float,
        anchorTopPx: Float,
        anchorWidthPx: Int,
        onSelected: (String) -> Unit,
    ) {
        state = if (state?.id === id) {
            null
        } else {
            AndroidSelectOverlayState(
                id = id,
                options = options,
                selected = selected,
                anchorLeftPx = anchorLeftPx,
                anchorTopPx = anchorTopPx,
                anchorWidthPx = anchorWidthPx,
                onSelected = onSelected,
            )
        }
    }

    fun dismiss() {
        state = null
    }

    fun select(value: String) {
        val current = state ?: return
        current.onSelected(value)
        state = null
    }
}

internal val LocalAndroidSelectOverlayController =
    staticCompositionLocalOf<AndroidSelectOverlayController?> { null }
