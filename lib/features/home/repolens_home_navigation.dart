part of 'repolens_home.dart';

class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({
    required this.selectedIndex,
    required this.usesLiquidGlass,
    required this.onSelected,
  });

  final int selectedIndex;
  final bool usesLiquidGlass;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      _NavigationItem(
        icon: Icons.radar_outlined,
        selectedIcon: Icons.radar,
        label: l10n.t('navDiscoveryShort'),
      ),
      _NavigationItem(
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
        label: l10n.t('navProjectsShort'),
      ),
      _NavigationItem(
        icon: Icons.psychology_alt_outlined,
        selectedIcon: Icons.psychology_alt,
        label: l10n.t('navAnalysisShort'),
      ),
      _NavigationItem(
        icon: Icons.ios_share_outlined,
        selectedIcon: Icons.ios_share,
        label: l10n.t('navExportsShort'),
      ),
      _NavigationItem(
        icon: Icons.tune_outlined,
        selectedIcon: Icons.tune,
        label: l10n.t('navSettingsShort'),
      ),
    ];

    if (!usesLiquidGlass) {
      return NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      );
    }

    return NativeGlassSurface(
      enabled: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      borderRadius: 22,
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _LiquidGlassTabButton(
                  item: items[index],
                  selected: selectedIndex == index,
                  onPressed: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _LiquidGlassTabButton extends StatelessWidget {
  const _LiquidGlassTabButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiquidGlassSymbol(
                    icon: selected ? item.selectedIcon : item.icon,
                    size: 22,
                    color: foreground,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({required this.state, required this.controller});

  final AppState state;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final usesLiquidGlass =
        resolveVisualStyleForPlatform(state.settings.visualStyle) ==
        VisualStyle.liquidGlass;
    return SizedBox(
      width: 248,
      child: NativeGlassSurface(
        enabled: usesLiquidGlass,
        margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Center(
                      child: LiquidGlassSymbol(
                        icon: Icons.travel_explore,
                        color: Color(0xFFF5F7F2),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RepoLens AI',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l10n.t('appSubtitle'),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            _NavButton(
              selected: state.navigationIndex == 0,
              usesLiquidGlass: usesLiquidGlass,
              icon: Icons.radar_outlined,
              label: l10n.t('navDiscovery'),
              onPressed: () => controller.setNavigationIndex(0),
            ),
            _NavButton(
              selected: state.navigationIndex == 1,
              usesLiquidGlass: usesLiquidGlass,
              icon: Icons.folder_outlined,
              label: l10n.t('navProjects'),
              onPressed: () => controller.setNavigationIndex(1),
            ),
            _NavButton(
              selected: state.navigationIndex == 2,
              usesLiquidGlass: usesLiquidGlass,
              icon: Icons.psychology_alt_outlined,
              label: l10n.t('navAnalysis'),
              onPressed: () => controller.setNavigationIndex(2),
            ),
            _NavButton(
              selected: state.navigationIndex == 3,
              usesLiquidGlass: usesLiquidGlass,
              icon: Icons.ios_share_outlined,
              label: l10n.t('navExports'),
              onPressed: () => controller.setNavigationIndex(3),
            ),
            _NavButton(
              selected: state.navigationIndex == 4,
              usesLiquidGlass: usesLiquidGlass,
              icon: Icons.tune_outlined,
              label: l10n.t('navSettings'),
              onPressed: () => controller.setNavigationIndex(4),
            ),
            const Spacer(),
            Text(
              usesLiquidGlass ? 'Liquid Glass' : 'Material 3',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.projectCountSummary(
                state.projects.length,
                state.analyses.length,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.selected,
    required this.usesLiquidGlass,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool selected;
  final bool usesLiquidGlass;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (usesLiquidGlass) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Semantics(
          button: true,
          selected: selected,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                height: 42,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    LiquidGlassSymbol(
                      icon: icon,
                      size: 19,
                      color: selected ? scheme.primary : scheme.onSurface,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(label),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: const Size(double.infinity, 42),
          foregroundColor: selected ? scheme.onPrimary : scheme.onSurface,
          backgroundColor: selected ? scheme.primary : Colors.transparent,
        ),
      ),
    );
  }
}
