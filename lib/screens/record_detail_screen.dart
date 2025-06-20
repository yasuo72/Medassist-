import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/medical_record.dart';
import '../providers/medical_record_provider.dart';

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({super.key, required this.record});

  final MedicalRecord record;

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  String? _localPdfPath;
  bool get _isPdf => widget.record.mimeType.toLowerCase().contains('pdf') ||
      widget.record.downloadUrl.toLowerCase().endsWith('.pdf');

  @override
  void initState() {
    super.initState();
    if (_isPdf) _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      final bytes = await http.readBytes(Uri.parse(widget.record.downloadUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.record.id}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      if (mounted) setState(() => _localPdfPath = file.path);
    } catch (e) {
      debugPrint('PDF download failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record.title),
      ),
      body: _isPdf && _localPdfPath != null
          ? (_localPdfPath == null
              ? const Center(child: CircularProgressIndicator())
              : PDFView(
                  filePath: _localPdfPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: true,
                  pageSnap: true,
                ))
          : _isPdf
              ? Center(
                  child: TextButton(
                    onPressed: () async {
                      final url = Uri.parse(widget.record.downloadUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text('Open PDF'),
                  ),
                )
              : InteractiveViewer(
                  child: Center(
                    child: Image.network(widget.record.downloadUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (c, w, p) => p == null
                            ? w
                            : const CircularProgressIndicator()),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_isPdf) {
            // Launch external viewer for better handling if user prefers
            final url = Uri.parse(widget.record.downloadUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
              return;
            }
          }
          final summary = await _showLoadingAndFetchSummary(context);
          if (summary != null && context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('AI Summary'),
                content: Text(summary),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close')),
                ],
              ),
            );
          }
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI Summary'),
      ),
    );
  }

  Future<String?> _showLoadingAndFetchSummary(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final prov = context.read<MedicalRecordProvider>();
      final summary = await prov.fetchAiSummary(widget.record.id);
      return summary;
    } finally {
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }
}
