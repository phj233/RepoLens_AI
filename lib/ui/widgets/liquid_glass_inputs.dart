part of 'liquid_glass_controls.dart';

class LiquidGlassSwitchTile extends StatelessWidget {
  const LiquidGlassSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class LiquidGlassSlider extends StatelessWidget {
  const LiquidGlassSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.label,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      );
    }

    return CupertinoSlider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: onChanged,
    );
  }
}

class LiquidGlassProgressBar extends StatelessWidget {
  const LiquidGlassProgressBar({
    super.key,
    required this.value,
    this.height = 8,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return LinearProgressIndicator(
        value: value,
        minHeight: height,
        borderRadius: BorderRadius.circular(8),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: scheme.surface.withValues(alpha: 0.46)),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              alignment: Alignment.centerLeft,
              child: ColoredBox(color: scheme.primary.withValues(alpha: 0.72)),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidGlassSpinner extends StatelessWidget {
  const LiquidGlassSpinner({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return CupertinoActivityIndicator(radius: size / 2);
  }
}
