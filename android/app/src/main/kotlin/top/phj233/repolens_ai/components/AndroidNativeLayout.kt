package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
internal fun PageHeader(
    title: String,
    subtitle: String,
    action: @Composable (() -> Unit)? = null,
) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            AppText(title, RepoLensAndroidType.pageTitle())
            AppText(subtitle, RepoLensAndroidType.bodyMuted(), maxLines = 3)
        }
        if (action != null) {
            Spacer(Modifier.width(10.dp))
            action()
        }
    }
}
