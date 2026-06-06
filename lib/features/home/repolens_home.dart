import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_controller.dart';
import '../../app/app_state.dart';
import '../../app/native_shell_bridge.dart';
import '../../app/providers.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/models/repolens_models.dart';
import '../../ui/theme.dart';
import '../../ui/visual_style_resolver.dart';
import '../../ui/widgets/liquid_glass_controls.dart';
import '../../ui/widgets/native_glass_surface.dart';
import 'pages/analysis_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/export_page.dart';
import 'pages/project_library_page.dart';
import 'pages/settings_page.dart';
import 'widgets/floating_analysis_config.dart';

part 'repolens_home_frame.dart';
part 'repolens_home_navigation.dart';

const _nativeShellChannel = MethodChannel('repolens.ai/native_shell');

class RepoLensHome extends ConsumerStatefulWidget {
  const RepoLensHome({super.key});

  @override
  ConsumerState<RepoLensHome> createState() => _RepoLensHomeState();
}

class _RepoLensHomeState extends ConsumerState<RepoLensHome> {
  @override
  void initState() {
    super.initState();
    _nativeShellChannel.setMethodCallHandler(_handleNativeShellCall);
  }

  @override
  void dispose() {
    _nativeShellChannel.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final usesLiquidGlass =
        resolveVisualStyleForPlatform(state.settings.visualStyle) ==
        VisualStyle.liquidGlass;
    final usesNativeShell = _usesAppleNativeShell(state.settings.visualStyle);

    ref.listen<int>(
      appControllerProvider.select((state) => state.navigationIndex),
      (previous, next) {
        if (previous != next && usesNativeShell) {
          _nativeShellChannel.invokeMethod<void>(
            'navigationIndexChanged',
            next,
          );
        }
      },
    );

    if (state.isBootstrapping) {
      final loading = const Center(child: LiquidGlassSpinner(size: 24));
      return usesLiquidGlass
          ? _LiquidGlassAppFrame(child: loading)
          : Scaffold(body: loading);
    }

    if (usesNativeShell) {
      return _LiquidGlassAppFrame(
        message: state.errorMessage ?? state.noticeMessage,
        isError: state.errorMessage != null,
        previewImagePath: state.previewImagePath,
        onDismissMessage: controller.dismissMessage,
        onClosePreview: controller.closeImagePreview,
        child: _ContentSwitch(state: state, controller: controller),
      );
    }

    final workspace = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 860;
          final content = _ContentSwitch(state: state, controller: controller);

          if (isCompact) {
            return Column(
              children: [
                Expanded(child: content),
                _CompactNavigation(
                  selectedIndex: state.navigationIndex,
                  usesLiquidGlass: usesLiquidGlass,
                  onSelected: controller.setNavigationIndex,
                ),
              ],
            );
          }

          return Row(
            children: [
              _SideNavigation(state: state, controller: controller),
              Expanded(child: content),
            ],
          );
        },
      ),
    );

    final page = !usesLiquidGlass
        ? Scaffold(body: workspace)
        : _LiquidGlassAppFrame(
            message: state.errorMessage ?? state.noticeMessage,
            isError: state.errorMessage != null,
            previewImagePath: state.previewImagePath,
            onDismissMessage: controller.dismissMessage,
            onClosePreview: controller.closeImagePreview,
            child: workspace,
          );

    return PopScope<Object?>(
      canPop: !state.hasInAppBackDestination,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.handleSystemBack();
        }
      },
      child: page,
    );
  }

  Future<Object?> _handleNativeShellCall(MethodCall call) async {
    return handleNativeShellCall(call, ref);
  }
}

bool _usesAppleNativeShell(VisualStyle requestedStyle) {
  final visualStyle = resolveVisualStyleForPlatform(requestedStyle);
  return visualStyle == VisualStyle.liquidGlass &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
}
