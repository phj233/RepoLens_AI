part of 'liquid_glass_controls.dart';

class LiquidGlassSymbol extends StatelessWidget {
  const LiquidGlassSymbol({
    super.key,
    required this.icon,
    this.size = 18,
    this.color,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return Icon(icon, size: size, color: color);
    }

    final glyph = _glyphForIcon(icon);
    final symbolColor = color ?? Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: glyph.length > 1 ? size * 1.58 : size,
      height: size,
      child: Center(
        child: Text(
          glyph,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: symbolColor,
            fontSize: glyph.length > 1 ? size * 0.66 : size * 0.92,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class LiquidGlassActionButton extends StatelessWidget {
  const LiquidGlassActionButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.prominent = false,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return prominent
          ? FilledButton.icon(onPressed: onPressed, icon: icon, label: label)
          : OutlinedButton.icon(onPressed: onPressed, icon: icon, label: label);
    }

    final scheme = Theme.of(context).colorScheme;
    final color = prominent ? scheme.primary : scheme.onSurface;
    return _LiquidGlassPressable(
      onPressed: onPressed,
      prominent: prominent,
      minHeight: 42,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _controlIcon(context, icon, size: 18, color: color),
          const SizedBox(width: 8),
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            child: label,
          ),
        ],
      ),
    );
  }
}

class LiquidGlassIconButton extends StatelessWidget {
  const LiquidGlassIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.selected = false,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: icon,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final tokens = context.repoLensTokens;
    final button = Semantics(
      button: true,
      label: tooltip,
      child: _LiquidGlassPressable(
        onPressed: onPressed,
        selected: selected,
        padding: EdgeInsets.zero,
        minHeight: 34,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: _controlIcon(
              context,
              icon,
              size: 19,
              color: selected ? tokens.warning : scheme.onSurface,
            ),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
