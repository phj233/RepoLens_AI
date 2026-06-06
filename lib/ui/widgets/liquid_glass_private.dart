part of 'liquid_glass_controls.dart';

Widget _controlIcon(
  BuildContext context,
  Widget icon, {
  required double size,
  required Color color,
}) {
  if (icon case Icon(:final icon?)) {
    return LiquidGlassSymbol(icon: icon, size: size, color: color);
  }
  return IconTheme.merge(
    data: IconThemeData(size: size, color: color),
    child: icon,
  );
}

String _glyphForIcon(IconData icon) {
  if (icon == Icons.radar || icon == Icons.radar_outlined) return '◎';
  if (icon == Icons.folder || icon == Icons.folder_outlined) return '▣';
  if (icon == Icons.psychology_alt || icon == Icons.psychology_alt_outlined) {
    return '◇';
  }
  if (icon == Icons.ios_share || icon == Icons.ios_share_outlined) return '↗';
  if (icon == Icons.tune || icon == Icons.tune_outlined) return '⌘';
  if (icon == Icons.travel_explore) return '◉';
  if (icon == Icons.star ||
      icon == Icons.star_rate ||
      icon == Icons.check_circle) {
    return '★';
  }
  if (icon == Icons.star_border || icon == Icons.radio_button_unchecked) {
    return '☆';
  }
  if (icon == Icons.speed) return '◌';
  if (icon == Icons.search) return '⌕';
  if (icon == Icons.sync) return '↻';
  if (icon == Icons.sell_outlined) return '#';
  if (icon == Icons.check_circle_outline || icon == Icons.check) return '✓';
  if (icon == Icons.code) return '<>';
  if (icon == Icons.data_object) return '{}';
  if (icon == Icons.table_chart) return '▦';
  if (icon == Icons.article_outlined) return '¶';
  if (icon == Icons.picture_as_pdf) return 'PDF';
  if (icon == Icons.image_outlined) return '▧';
  if (icon == Icons.integration_instructions) return 'TS';
  if (icon == Icons.translate) return '文';
  if (icon == Icons.blur_on || icon == Icons.lens_blur) return '◌';
  if (icon == Icons.layers_outlined) return '▤';
  if (icon == Icons.chat_bubble_outline) return '…';
  if (icon == Icons.forum_outlined) return '◫';
  if (icon == Icons.save_outlined) return '↓';
  if (icon == Icons.key || icon == Icons.vpn_key_outlined) return '⌑';
  if (icon == Icons.android) return 'A';
  if (icon == Icons.info) return 'i';
  if (icon == Icons.auto_awesome) return '✦';
  if (icon == Icons.close) return '×';
  if (icon == Icons.expand_more) return '⌄';
  return '•';
}

class _LiquidGlassPressable extends StatelessWidget {
  const _LiquidGlassPressable({
    required this.child,
    this.onPressed,
    this.selected = false,
    this.prominent = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    this.minHeight = 38,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool selected;
  final bool prominent;
  final EdgeInsetsGeometry padding;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final borderColor = prominent || selected
        ? scheme.primary.withValues(alpha: 0.58)
        : scheme.outlineVariant.withValues(alpha: 0.74);
    final fillColor = prominent || selected
        ? scheme.primary.withValues(alpha: 0.14)
        : scheme.surface.withValues(alpha: 0.30);
    final button = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.46,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: button,
        ),
      ),
    );
  }
}
