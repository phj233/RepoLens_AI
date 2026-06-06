import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:csv/csv.dart' as csv_lib;
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;

import '../models/repolens_models.dart';
import 'local_repository.dart';

class ExportService {
  Future<ExportBundle> export({
    required ExportFormat format,
    required List<AiToolProject> projects,
    required List<AiToolAnalysis> analyses,
    required LocalRepository repository,
  }) async {
    final directory = await repository.exportDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final extension = _extension(format);
    final file = File(p.join(directory.path, 'repolens-$timestamp.$extension'));

    switch (format) {
      case ExportFormat.json:
        await file.writeAsString(_json(projects, analyses));
      case ExportFormat.csv:
        await file.writeAsString(_csv(projects, analyses));
      case ExportFormat.markdown:
        await file.writeAsString(_markdown(projects, analyses));
      case ExportFormat.pdf:
        await file.writeAsBytes(await _pdf(projects, analyses));
      case ExportFormat.png:
        await file.writeAsBytes(await _png(projects, analyses));
      case ExportFormat.typeScriptModule:
        await file.writeAsString(_typeScript(projects, analyses));
    }

    final bundle = ExportBundle(
      id: timestamp,
      format: format,
      filePath: file.path,
      createdAt: DateTime.now(),
      projectCount: projects.length,
    );
    await repository.saveExport(bundle);
    return bundle;
  }

  String _json(List<AiToolProject> projects, List<AiToolAnalysis> analyses) {
    return const JsonEncoder.withIndent('  ').convert({
      'schema': 'repolens.ai/export/v1',
      'createdAt': DateTime.now().toIso8601String(),
      'projects': projects.map((project) => project.toJson()).toList(),
      'analyses': analyses.map((analysis) => analysis.toJson()).toList(),
    });
  }

  String _csv(List<AiToolProject> projects, List<AiToolAnalysis> analyses) {
    final analysisByProject = {
      for (final analysis in analyses) analysis.projectFullName: analysis,
    };
    final rows = <List<Object?>>[
      [
        'full_name',
        'stars',
        'forks',
        'language',
        'license',
        'pushed_at',
        'category',
        'score',
        'risk_count',
        'recommendation',
        'business_fit',
        'dimension_scores',
      ],
      for (final project in projects)
        [
          project.fullName,
          project.stars,
          project.forks,
          project.language,
          project.license,
          project.pushedAt.toIso8601String(),
          analysisByProject[project.fullName]?.category ?? '',
          analysisByProject[project.fullName]?.score ?? '',
          analysisByProject[project.fullName]?.risks.length ?? '',
          analysisByProject[project.fullName]?.recommendation ?? '',
          analysisByProject[project.fullName]?.businessFit ?? '',
          _dimensionScores(analysisByProject[project.fullName]),
        ],
    ];

    return csv_lib.csv.encode(rows);
  }

  String _markdown(
    List<AiToolProject> projects,
    List<AiToolAnalysis> analyses,
  ) {
    final analysisByProject = {
      for (final analysis in analyses) analysis.projectFullName: analysis,
    };
    final buffer = StringBuffer()
      ..writeln('# RepoLens AI Report')
      ..writeln()
      ..writeln('Generated at ${DateTime.now().toIso8601String()}')
      ..writeln()
      ..writeln('| Project | Stars | Category | Score | License |')
      ..writeln('|---|---:|---|---:|---|');

    for (final project in projects) {
      final analysis = analysisByProject[project.fullName];
      buffer.writeln(
        '| [${project.fullName}](${project.htmlUrl}) | ${project.stars} | '
        '${analysis?.category ?? 'Pending'} | ${analysis?.score.toStringAsFixed(1) ?? '-'} | '
        '${project.license} |',
      );
    }

    for (final analysis in analyses) {
      buffer
        ..writeln()
        ..writeln('## ${analysis.projectFullName}')
        ..writeln()
        ..writeln(analysis.summary)
        ..writeln()
        ..writeln('- Recommendation: ${analysis.recommendation}')
        ..writeln('- Business fit: ${analysis.businessFit}')
        ..writeln('- Model: ${analysis.modelId}')
        ..writeln()
        ..writeln('| Dimension | Score | Summary |')
        ..writeln('|---|---:|---|');
      for (final dimension in analysis.dimensions) {
        buffer.writeln(
          '| ${dimension.title} | ${dimension.score.toStringAsFixed(0)} | ${dimension.summary} |',
        );
      }
    }

    return buffer.toString();
  }

  Future<Uint8List> _pdf(
    List<AiToolProject> projects,
    List<AiToolAnalysis> analyses,
  ) async {
    final document = pw.Document();
    final analysisByProject = {
      for (final analysis in analyses) analysis.projectFullName: analysis,
    };

    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'RepoLens AI Report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Projects: ${projects.length}'),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: [
              'Project',
              'Stars',
              'Category',
              'Score',
              'Recommendation',
            ],
            data: [
              for (final project in projects.take(24))
                [
                  project.fullName,
                  '${project.stars}',
                  analysisByProject[project.fullName]?.category ?? 'Pending',
                  analysisByProject[project.fullName]?.score.toStringAsFixed(
                        1,
                      ) ??
                      '-',
                  analysisByProject[project.fullName]?.recommendation ?? '-',
                ],
            ],
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<Uint8List> _png(
    List<AiToolProject> projects,
    List<AiToolAnalysis> analyses,
  ) async {
    const width = 1200;
    const height = 720;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final background = ui.Paint()..color = const ui.Color(0xFFF5F7F2);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      background,
    );

    final title =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(fontSize: 36, fontWeight: ui.FontWeight.w700),
          )
          ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF202924)))
          ..addText('RepoLens AI Trend Snapshot');
    final titleParagraph = title.build()
      ..layout(const ui.ParagraphConstraints(width: width - 96));
    canvas.drawParagraph(titleParagraph, const ui.Offset(48, 42));

    final topProjects = projects.take(8).toList(growable: false);
    final maxStars = topProjects.fold<int>(
      1,
      (maxValue, project) => max(maxValue, project.stars),
    );
    const chartLeft = 70.0;
    const chartTop = 140.0;
    const barHeight = 42.0;
    const gap = 22.0;
    final barPaint = ui.Paint()..color = const ui.Color(0xFF2F7D5F);
    final trackPaint = ui.Paint()..color = const ui.Color(0xFFE3E9E0);

    for (var index = 0; index < topProjects.length; index++) {
      final project = topProjects[index];
      final y = chartTop + index * (barHeight + gap);
      final barWidth = (project.stars / maxStars) * 780;
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(chartLeft + 300, y, 780, barHeight),
          const ui.Radius.circular(12),
        ),
        trackPaint,
      );
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(chartLeft + 300, y, barWidth, barHeight),
          const ui.Radius.circular(12),
        ),
        barPaint,
      );

      final label =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(fontSize: 22, fontWeight: ui.FontWeight.w600),
            )
            ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF29332E)))
            ..addText(project.fullName);
      final labelParagraph = label.build()
        ..layout(const ui.ParagraphConstraints(width: 280));
      canvas.drawParagraph(labelParagraph, ui.Offset(chartLeft, y + 7));

      final value = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 20))
        ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF29332E)))
        ..addText('${project.stars}');
      final valueParagraph = value.build()
        ..layout(const ui.ParagraphConstraints(width: 120));
      canvas.drawParagraph(valueParagraph, ui.Offset(chartLeft + 315, y + 8));
    }

    final footer = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 18))
      ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF61706A)))
      ..addText(
        '${projects.length} projects, ${analyses.length} structured analyses',
      );
    final footerParagraph = footer.build()
      ..layout(const ui.ParagraphConstraints(width: width - 96));
    canvas.drawParagraph(footerParagraph, const ui.Offset(48, 666));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  String _typeScript(
    List<AiToolProject> projects,
    List<AiToolAnalysis> analyses,
  ) {
    final payload = {
      'schema': 'repolens.ai/typescript-module/v1',
      'projects': projects.map((project) => project.toJson()).toList(),
      'analyses': analyses.map((analysis) => analysis.toJson()).toList(),
    };

    return '''
export const repoLensAiTools = ${const JsonEncoder.withIndent('  ').convert(payload)} as const;

export type RepoLensAiTools = typeof repoLensAiTools;
export type RepoLensAiToolProject = RepoLensAiTools["projects"][number];
export type RepoLensAiToolAnalysis = RepoLensAiTools["analyses"][number];
''';
  }

  String _extension(ExportFormat format) {
    return switch (format) {
      ExportFormat.json => 'json',
      ExportFormat.csv => 'csv',
      ExportFormat.markdown => 'md',
      ExportFormat.pdf => 'pdf',
      ExportFormat.png => 'png',
      ExportFormat.typeScriptModule => 'ts',
    };
  }

  String _dimensionScores(AiToolAnalysis? analysis) {
    if (analysis == null) {
      return '';
    }
    return analysis.dimensions
        .map((dimension) => '${dimension.key}:${dimension.score.round()}')
        .join('; ');
  }
}
