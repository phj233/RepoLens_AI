part of 'repolens_home.dart';

class _LiquidGlassAppFrame extends StatelessWidget {
  const _LiquidGlassAppFrame({
    required this.child,
    this.message,
    this.isError = false,
    this.previewImagePath,
    this.onDismissMessage,
    this.onClosePreview,
  });

  final Widget child;
  final String? message;
  final bool isError;
  final String? previewImagePath;
  final VoidCallback? onDismissMessage;
  final VoidCallback? onClosePreview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: Stack(
        children: [
          child,
          if (previewImagePath != null)
            _ImagePreviewOverlay(
              path: previewImagePath!,
              onClose: onClosePreview,
            ),
          if (message != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: NativeGlassSurface(
                    enabled: true,
                    borderRadius: 22,
                    surfaceAlpha: 0.26,
                    tintAlpha: 0.12,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: (isError ? scheme.error : scheme.primary)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: Center(
                              child: Text(
                                isError ? '!' : 'i',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: isError
                                          ? scheme.error
                                          : scheme.primary,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            message!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (onDismissMessage != null) ...[
                          const SizedBox(width: 8),
                          _ToastCloseButton(
                            tooltip: context.l10n.t('close'),
                            onPressed: onDismissMessage,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToastCloseButton extends StatelessWidget {
  const _ToastCloseButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final button = Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surface.withValues(alpha: 0.22),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.60),
            ),
          ),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(Icons.close, size: 17, color: scheme.onSurface),
          ),
        ),
      ),
    );

    return Tooltip(message: tooltip, child: button);
  }
}

class _ContentSwitch extends StatelessWidget {
  const _ContentSwitch({required this.state, required this.controller});

  final AppState state;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final page = switch (state.navigationIndex) {
      0 => DashboardPage(state: state, controller: controller),
      1 => ProjectLibraryPage(state: state, controller: controller),
      2 => AnalysisPage(state: state, controller: controller),
      3 => ExportPage(state: state, controller: controller),
      _ => SettingsPage(state: state, controller: controller),
    };

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 112),
          child: page,
        ),
        FloatingAnalysisConfig(state: state, controller: controller),
      ],
    );
  }
}

class _ImagePreviewOverlay extends StatelessWidget {
  const _ImagePreviewOverlay({required this.path, required this.onClose});

  final String path;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: ColoredBox(
        color: scheme.scrim.withValues(alpha: 0.36),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980, maxHeight: 720),
              child: NativeGlassSurface(
                enabled: true,
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.t('imagePreview'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        LiquidGlassIconButton(
                          tooltip: context.l10n.t('close'),
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 620),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(path), fit: BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
