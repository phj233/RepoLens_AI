import 'dart:io';

import 'package:flutter/services.dart';

class FileOpeningService {
  static const _channel = MethodChannel('repolens.ai/file_opener');

  Future<void> open(String filePath) async {
    final path = filePath.trim();
    if (path.isEmpty || !File(path).existsSync()) {
      throw const FileOpeningException('missing_file');
    }

    try {
      await _channel.invokeMethod<void>('openFile', {'path': path});
      return;
    } on MissingPluginException {
      await _openWithDesktopProcess(path);
    } on PlatformException catch (error) {
      if (_canFallbackToDesktopProcess) {
        await _openWithDesktopProcess(path);
        return;
      }
      throw FileOpeningException(error.code);
    }
  }

  bool get _canFallbackToDesktopProcess {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  Future<void> _openWithDesktopProcess(String path) async {
    if (Platform.isMacOS) {
      await _run('open', [path]);
      return;
    }
    if (Platform.isWindows) {
      await _run('cmd', ['/c', 'start', '', path]);
      return;
    }
    if (Platform.isLinux) {
      await _run('xdg-open', [path]);
      return;
    }
    throw const FileOpeningException('unsupported_platform');
  }

  Future<void> _run(String executable, List<String> arguments) async {
    final result = await Process.run(executable, arguments);
    if (result.exitCode != 0) {
      throw FileOpeningException('process_${result.exitCode}');
    }
  }
}

class FileOpeningException implements Exception {
  const FileOpeningException(this.code);

  final String code;

  @override
  String toString() => 'FileOpeningException($code)';
}
