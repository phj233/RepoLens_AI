part of 'liquid_glass_controls.dart';

class LiquidGlassSegment<T> {
  const LiquidGlassSegment({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class LiquidGlassSegmentedControl<T> extends StatelessWidget {
  const LiquidGlassSegmentedControl({
    super.key,
    required this.selected,
    required this.segments,
    required this.onChanged,
  });

  final T selected;
  final List<LiquidGlassSegment<T>> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return SegmentedButton<T>(
        selected: {selected},
        segments: [
          for (final segment in segments)
            ButtonSegment<T>(
              value: segment.value,
              icon: Icon(segment.icon),
              label: Text(segment.label),
            ),
        ],
        onSelectionChanged: (selection) => onChanged(selection.first),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final segment in segments)
          _LiquidGlassPressable(
            selected: selected == segment.value,
            prominent: selected == segment.value,
            onPressed: () => onChanged(segment.value),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LiquidGlassSymbol(
                  icon: segment.icon,
                  size: 18,
                  color: selected == segment.value
                      ? scheme.primary
                      : scheme.onSurface,
                ),
                const SizedBox(width: 7),
                Text(
                  segment.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected == segment.value
                        ? scheme.primary
                        : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class LiquidGlassFilterChip extends StatelessWidget {
  const LiquidGlassFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onChanged,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return _LiquidGlassPressable(
      selected: selected,
      onPressed: () => onChanged(!selected),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiquidGlassSymbol(
            icon: selected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 17,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
