import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/medical_record_provider.dart';
import '../models/medical_record.dart';
import 'record_detail_screen.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  late MedicalRecordProvider _recordProvider;

  @override
  void initState() {
    super.initState();
    // Access provider without listening to avoid unwanted rebuilds here
    _recordProvider =
        Provider.of<MedicalRecordProvider>(context, listen: false);
    // Fetch once after first frame
    Future.microtask(() => _recordProvider.fetchRecords());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Just grab provider so that Consumer widgets below work; no fetch here
    _recordProvider = Provider.of<MedicalRecordProvider>(context);
  }

  Future<void> _addRecord() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;
    final filePath = result.files.single.path!;

    final titleController = TextEditingController();
    String recordType = 'Lab Report';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: recordType,
                    items: const [
                      DropdownMenuItem(value: 'Lab Report', child: Text('Lab Report')),
                      DropdownMenuItem(value: 'Prescription', child: Text('Prescription')),
                      DropdownMenuItem(value: 'Imaging', child: Text('Imaging')),
                      DropdownMenuItem(value: 'Clinical Note', child: Text('Clinical Note')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) => recordType = val!,
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Upload'),
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((confirmed) async {
      if (confirmed == true) {
        final success = await _recordProvider.uploadRecord(
          title: titleController.text.trim(),
          recordType: recordType,
          filePath: filePath,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Uploaded' : 'Upload failed')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Records')),
      body: RefreshIndicator(
        onRefresh: _recordProvider.fetchRecords,
        child: Consumer<MedicalRecordProvider>(
          builder: (ctx, prov, _) {
            if (prov.isLoading && prov.records.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (prov.records.isEmpty) {
              return const Center(child: Text('No records yet'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prov.records.length,
              itemBuilder: (ctx, i) {
                final record = prov.records[i];
                return _buildRecordCard(record, theme).animate().fadeIn().slideY(begin: 0.1);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: ListTile(
        leading: Icon(MdiIcons.fileDocumentOutline, color: theme.colorScheme.primary),
        title: Text(record.title, style: const TextStyle(fontFamily: 'Poppins')),
        subtitle: Text(record.recordType),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Record'),
                  content: const Text('Are you sure you want to delete this record?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                final ok = await _recordProvider.deleteRecord(record.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Deleted' : 'Failed to delete')),
                );
              }
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record)),
          );
        },
      ),
    );
  }
}
