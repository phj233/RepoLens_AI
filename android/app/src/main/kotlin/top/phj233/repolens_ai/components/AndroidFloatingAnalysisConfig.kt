package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Close
import androidx.compose.material.icons.outlined.Tune
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.kyant.backdrop.Backdrop

@Composable
internal fun AndroidFloatingAnalysisConfig(
    shellState: AndroidNativeShellState,
    backdrop: Backdrop,
    modifier: Modifier = Modifier,
) {
    val snapshot = shellState.snapshot
    var expanded by remember(snapshot.selectedProjectFullName) { mutableStateOf(false) }

    Box(modifier = modifier, contentAlignment = Alignment.BottomEnd) {
        if (expanded) {
            KyantGlassPanel(
                backdrop = backdrop,
                modifier = Modifier.fillMaxWidth(),
                surfaceAlpha = 0.72f,
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        AppText(
                            snapshot.strings.analysisConfiguration,
                            RepoLensAndroidType.title(),
                            Modifier.weight(1f),
                        )
                        Spacer(Modifier.width(8.dp))
                        KyantGlassIconButton(
                            text = snapshot.strings.close,
                            icon = Icons.Outlined.Close,
                            backdrop = backdrop,
                            compact = true,
                            onClick = { expanded = false },
                        )
                    }
                    AndroidAnalysisProviderPanel(
                        shellState = shellState,
                        backdrop = backdrop,
                        showAnalyzeButton = true,
                        wrapPanel = false,
                        showTitle = false,
                    )
                }
            }
        } else {
            KyantGlassIconButton(
                text = snapshot.strings.analysisConfiguration,
                icon = Icons.Outlined.Tune,
                backdrop = backdrop,
                prominent = true,
                onClick = { expanded = true },
            )
        }
    }
}
