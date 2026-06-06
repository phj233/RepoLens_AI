package top.phj233.repolens_ai.components

import top.phj233.repolens_ai.*

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp

@Composable
internal fun AppText(
    text: String,
    style: TextStyle,
    modifier: Modifier = Modifier,
    maxLines: Int = Int.MAX_VALUE,
) {
    BasicText(
        text = text,
        modifier = modifier,
        style = style,
        maxLines = maxLines,
        overflow = TextOverflow.Ellipsis,
    )
}

@Composable
internal fun TextSection(title: String, values: List<String>) {
    if (values.isNotEmpty()) {
        Column(verticalArrangement = Arrangement.spacedBy(5.dp)) {
            AppText(title, RepoLensAndroidType.bodyStrong())
            values.take(5).forEach { value ->
                AppText("• $value", RepoLensAndroidType.bodyMuted())
            }
        }
    }
}

@Composable
internal fun DetailLine(label: String, value: String) {
    Row {
        AppText(
            text = label,
            style = RepoLensAndroidType.caption(),
            modifier = Modifier.width(96.dp),
            maxLines = 1,
        )
        AppText(
            text = value,
            style = RepoLensAndroidType.body(),
            modifier = Modifier.weight(1f),
            maxLines = 3,
        )
    }
}
