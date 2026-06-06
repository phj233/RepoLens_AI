part of 'liquid_glass_controls.dart';

class LiquidGlassTextField extends StatelessWidget {
  const LiquidGlassTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixTooltip,
    this.onSuffixPressed,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? suffixTooltip;
  final VoidCallback? onSuffixPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
                  tooltip: suffixTooltip,
                  onPressed: onSuffixPressed,
                  icon: Icon(suffixIcon),
                ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      );
    }

    return _LiquidGlassEditableField(
      controller: controller,
      label: label,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffixTooltip: suffixTooltip,
      onSuffixPressed: onSuffixPressed,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

class _LiquidGlassEditableField extends StatefulWidget {
  const _LiquidGlassEditableField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.keyboardType,
    required this.onChanged,
    required this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixTooltip,
    this.onSuffixPressed,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? suffixTooltip;
  final VoidCallback? onSuffixPressed;

  @override
  State<_LiquidGlassEditableField> createState() =>
      _LiquidGlassEditableFieldState();
}

class _LiquidGlassEditableFieldState extends State<_LiquidGlassEditableField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleStateChanged);
    _focusNode.addListener(_handleStateChanged);
  }

  @override
  void didUpdateWidget(_LiquidGlassEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleStateChanged);
      widget.controller.addListener(_handleStateChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChanged);
    _focusNode
      ..removeListener(_handleStateChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle =
        Theme.of(context).textTheme.bodyMedium ??
        DefaultTextStyle.of(context).style;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focusNode.requestFocus,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _focusNode.hasFocus
                ? scheme.primary.withValues(alpha: 0.78)
                : scheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                LiquidGlassSymbol(
                  icon: widget.prefixIcon!,
                  size: 18,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (widget.controller.text.isEmpty)
                      IgnorePointer(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    EditableText(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      style: textStyle.copyWith(color: scheme.onSurface),
                      cursorColor: scheme.primary,
                      backgroundCursorColor: scheme.primary.withValues(
                        alpha: 0.24,
                      ),
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      textInputAction: TextInputAction.done,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              if (widget.suffixIcon != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: widget.suffixTooltip,
                  onPressed: widget.onSuffixPressed,
                  icon: Icon(widget.suffixIcon, size: 20),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
