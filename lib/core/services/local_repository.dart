import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/repolens_models.dart';

class LocalRepository {
  // ignore: prefer_initializing_formals
  LocalRepository({Database? database}) : _database = database;

  Database? _database;
  bool _ready = false;

  Future<List<AiToolProject>> loadProjects() async {
    final database = await _open();
    final rows = database.select(
      'SELECT json FROM projects ORDER BY updated_at DESC',
    );

    return rows
        .map((row) => AiToolProject.fromJson(_decodeMap(row['json'])))
        .toList(growable: false);
  }

  Future<void> saveProjects(List<AiToolProject> projects) async {
    final database = await _open();
    final statement = database.prepare('''
      INSERT INTO projects(full_name, json, updated_at)
      VALUES (?, ?, ?)
      ON CONFLICT(full_name) DO UPDATE SET
        json = excluded.json,
        updated_at = excluded.updated_at
      ''');
    try {
      for (final project in projects) {
        statement.execute([
          project.fullName,
          jsonEncode(project.toJson()),
          DateTime.now().toIso8601String(),
        ]);
      }
    } finally {
      statement.close();
    }
  }

  Future<List<AiToolAnalysis>> loadAnalyses() async {
    final database = await _open();
    final rows = database.select(
      'SELECT json FROM analyses ORDER BY updated_at DESC',
    );

    return rows
        .map((row) => AiToolAnalysis.fromJson(_decodeMap(row['json'])))
        .toList(growable: false);
  }

  Future<void> saveAnalysis(AiToolAnalysis analysis) async {
    final database = await _open();
    database.execute(
      '''
      INSERT INTO analyses(project_full_name, json, updated_at)
      VALUES (?, ?, ?)
      ON CONFLICT(project_full_name) DO UPDATE SET
        json = excluded.json,
        updated_at = excluded.updated_at
      ''',
      [
        analysis.projectFullName,
        jsonEncode(analysis.toJson()),
        DateTime.now().toIso8601String(),
      ],
    );
  }

  Future<AppSettings> loadSettings() async {
    final database = await _open();
    final rows = database.select(
      'SELECT json FROM settings WHERE id = ? LIMIT 1',
      ['default'],
    );

    if (rows.isEmpty) {
      return AppSettings.defaults();
    }

    return AppSettings.fromJson(_decodeMap(rows.first['json']));
  }

  Future<void> saveSettings(AppSettings settings) async {
    final database = await _open();
    database.execute(
      '''
      INSERT INTO settings(id, json)
      VALUES (?, ?)
      ON CONFLICT(id) DO UPDATE SET json = excluded.json
      ''',
      ['default', jsonEncode(settings.toJson())],
    );
  }

  Future<List<ExportBundle>> loadExports() async {
    final database = await _open();
    final rows = database.select(
      'SELECT json FROM exports ORDER BY created_at DESC',
    );

    return rows
        .map((row) => ExportBundle.fromJson(_decodeMap(row['json'])))
        .toList(growable: false);
  }

  Future<void> saveExport(ExportBundle bundle) async {
    final database = await _open();
    database.execute(
      '''
      INSERT INTO exports(id, json, created_at)
      VALUES (?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        json = excluded.json,
        created_at = excluded.created_at
      ''',
      [
        bundle.id,
        jsonEncode(bundle.toJson()),
        bundle.createdAt.toIso8601String(),
      ],
    );
  }

  Future<void> deleteExport(String id) async {
    final database = await _open();
    database.execute('DELETE FROM exports WHERE id = ?', [id]);
  }

  Future<Directory> exportDirectory() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final directory = Directory(p.join(docs.path, 'RepoLens AI Exports'));
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      return directory;
    } catch (_) {
      final directory = Directory(
        p.join(Directory.systemTemp.path, 'repolens_ai_exports'),
      );
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      return directory;
    }
  }

  Future<Database> _open() async {
    if (_database != null && _ready) {
      return _database!;
    }

    _database ??= await _openDatabase();
    _migrate(_database!);
    _ready = true;
    return _database!;
  }

  Future<Database> _openDatabase() async {
    try {
      final support = await getApplicationSupportDirectory();
      final databasePath = p.join(support.path, 'repolens_ai.sqlite');
      return sqlite3.open(databasePath);
    } catch (_) {
      return sqlite3.openInMemory();
    }
  }

  void _migrate(Database database) {
    database.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        full_name TEXT PRIMARY KEY,
        json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
    database.execute('''
      CREATE TABLE IF NOT EXISTS analyses (
        project_full_name TEXT PRIMARY KEY,
        json TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
    database.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id TEXT PRIMARY KEY,
        json TEXT NOT NULL
      );
    ''');
    database.execute('''
      CREATE TABLE IF NOT EXISTS exports (
        id TEXT PRIMARY KEY,
        json TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');
  }

  Map<String, Object?> _decodeMap(Object? value) {
    final decoded = jsonDecode(value as String? ?? '{}');
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry('$key', value));
    }
    return const {};
  }
}
