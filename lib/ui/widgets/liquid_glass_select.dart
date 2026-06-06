part of 'liquid_glass_controls.dart';

class LiquidGlassSelectItem<T> {
  const LiquidGlassSelectItem({required this.value, required this.label});

  final T value;
  final String label;
}

class LiquidGlassSelect<T> extends StatelessWidget {
  const LiquidGlassSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  final String label;
  final T value;
  final List<LiquidGlassSelectItem<T>> items;
  final ValueChanged<T>? onChanged;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    if (!usesLiquidGlassControls(context)) {
      return DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        ),
        items: [
          for (final item in items)
            DropdownMenuItem(value: item.value, child: Text(item.label)),
        ],
        onChanged: (nextValue) {
          if (nextValue != null) {
            onChanged?.call(nextValue);
          }
        },
      );
    }

    final selected = _selectedItem;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        _LiquidGlassPressable(
          onPressed: onChanged == null || items.isEmpty
              ? null
              : () => _showMenu(context),
          minHeight: 44,
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                LiquidGlassSymbol(
                  icon: prefixIcon!,
                  size: 18,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  selected?.label ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              LiquidGlassSymbol(
                icon: Icons.expand_more,
                size: 18,
                color: scheme.onSurface,
              ),
            ],
          ),
        ),
      ],
    );
  }

  LiquidGlassSelectItem<T>? get _selectedItem {
    for (final item in items) {
      if (item.value == value) {
        return item;
      }
    }
    return items.isEmpty ? null : items.first;
  }

  void _showMenu(BuildContext context) {
    final selected = _selectedItem;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (modalContext) {
        return CupertinoActionSheet(
          title: Text(label),
          actions: [
            for (final item in items)
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(modalContext).pop();
                  onChanged?.call(item.value);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: Text(item.label)),
                    if (selected?.value == item.value) ...[
                      const SizedBox(width: 8),
                      LiquidGlassSymbol(
                        icon: Icons.check,
                        size: 17,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(modalContext).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        );
      },
    );
  }
}
