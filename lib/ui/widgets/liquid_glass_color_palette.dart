part of 'liquid_glass_controls.dart';

class LiquidGlassColorOption {
  const LiquidGlassColorOption({required this.label, required this.value});

  final String label;
  final String value;
}

class LiquidGlassColorPalette extends StatefulWidget {
  const LiquidGlassColorPalette({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
    this.allowDefault = false,
  });

  final String label;
  final String value;
  final List<LiquidGlassColorOption> options;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool allowDefault;

  @override
  State<LiquidGlassColorPalette> createState() =>
      _LiquidGlassColorPaletteState();
}

class _LiquidGlassColorPaletteState extends State<LiquidGlassColorPalette> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(LiquidGlassColorPalette oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalizedValue = _normalizeHex(widget.value);
    final options = widget.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        if (widget.hint != null) ...[
          const SizedBox(height: 4),
          Text(widget.hint!, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              _ColorSwatchButton(
                option: option,
                selected:
                    (_normalizeHex(option.value) == normalizedValue &&
                        option.value.isNotEmpty) ||
                    (option.value.isEmpty && widget.value.trim().isEmpty),
                onPressed: () {
                  _controller.text = option.value;
                  widget.onChanged(option.value);
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SelectedColorPreview(value: widget.value),
            const SizedBox(width: 10),
            Expanded(
              child: LiquidGlassTextField(
                controller: _controller,
                label: widget.allowDefault ? '#RRGGBB / default' : '#RRGGBB',
                prefixIcon: Icons.palette_outlined,
                onChanged: _handleCustomChanged,
                onSubmitted: _handleCustomChanged,
              ),
            ),
          ],
        ),
        if (_controller.text.trim().isNotEmpty &&
            _parseColor(_controller.text) == null) ...[
          const SizedBox(height: 6),
          Text(
            '#RRGGBB',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }

  void _handleCustomChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty && widget.allowDefault) {
      widget.onChanged('');
      return;
    }
    final normalized = _normalizeHex(trimmed);
    if (normalized != null) {
      widget.onChanged(normalized);
    }
  }
}

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final LiquidGlassColorOption option;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _parseColor(option.value);
    final child = SizedBox(
      width: 42,
      height: 42,
      child: Center(
        child: color == null
            ? LiquidGlassSymbol(
                icon: Icons.auto_awesome,
                size: 18,
                color: scheme.primary,
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.72),
                  ),
                ),
                child: const SizedBox(width: 25, height: 25),
              ),
      ),
    );

    return Tooltip(
      message: option.label,
      child: _LiquidGlassPressable(
        selected: selected,
        prominent: selected,
        padding: EdgeInsets.zero,
        minHeight: 42,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class _SelectedColorPreview extends StatelessWidget {
  const _SelectedColorPreview({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _parseColor(value);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? scheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: SizedBox(
        width: 48,
        height: 48,
        child: color == null
            ? Center(
                child: LiquidGlassSymbol(
                  icon: Icons.auto_awesome,
                  size: 18,
                  color: scheme.primary,
                ),
              )
            : null,
      ),
    );
  }
}

String? _normalizeHex(String value) {
  final cleaned = value.trim().replaceFirst('#', '');
  if (cleaned.length != 6 && cleaned.length != 8) {
    return null;
  }
  if (int.tryParse(cleaned, radix: 16) == null) {
    return null;
  }
  return '#${cleaned.toUpperCase()}';
}

Color? _parseColor(String value) {
  final normalized = _normalizeHex(value);
  if (normalized == null) {
    return null;
  }
  final cleaned = normalized.substring(1);
  final parsed = int.parse(cleaned, radix: 16);
  return Color(cleaned.length == 6 ? 0xFF000000 | parsed : parsed);
}
