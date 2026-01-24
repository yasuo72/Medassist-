import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../services/receipt_service.dart';

class ReceiptDetailScreen extends StatefulWidget {
  const ReceiptDetailScreen({super.key});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  Map<String, dynamic>? _receipt;
  String? _summary;
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      final id = args is String ? args : null;
      if (id == null || id.isEmpty) {
        setState(() {
          _errorMessage = 'No receipt selected.';
        });
      } else {
        _loadReceipt(id);
      }
    }
  }

  Future<void> _loadReceipt(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ReceiptService.instance.getReceipt(id);
      if (!mounted) return;
      if (data == null || data['success'] != true) {
        setState(() {
          _errorMessage = 'Failed to load receipt details.';
        });
        return;
      }

      setState(() {
        _receipt = Map<String, dynamic>.from(data['receipt'] as Map);
        _summary = data['summary']?.toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load receipt details. Please try again.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Unknown date';
    try {
      final dt = DateTime.parse(value.toString());
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return value.toString();
    }
  }

  String _formatAmount(dynamic value) {
    if (value == null) return '₹0.00';
    try {
      final numValue =
          value is num ? value.toDouble() : double.parse(value.toString());
      return '₹${numValue.toStringAsFixed(2)}';
    } catch (_) {
      return value.toString();
    }
  }

  Future<void> _copySummary() async {
    final text = _summary;
    if (text == null || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No summary available to copy.')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard.')),
    );
  }

  Future<void> _openOriginalFile() async {
    final url = _receipt?['cloudinaryUrl']?.toString();
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No original file attached to this receipt.'),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the file URL.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid file URL.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Summary'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Summary',
            onPressed: _summary == null ? null : _copySummary,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_receipt == null) {
      return const Center(child: Text('No receipt data available.'));
    }

    final vendor = _receipt!['vendor']?.toString() ?? 'Unknown vendor';
    final date = _formatDate(_receipt!['date']);
    final total = _formatAmount(_receipt!['totalAmount']);
    final items = _receipt!['rawItems'] as List?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: Icon(
                          MdiIcons.fileDocumentOutline,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(vendor, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('Date: $date'),
                            Text('Total: $total'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Original File'),
                      onPressed: _openOriginalFile,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Medical Summary (Hindi + English)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_summary == null || _summary!.trim().isEmpty)
                    Text(
                      'No summary available.',
                      style: theme.textTheme.bodyMedium,
                    )
                  else
                    MarkdownBody(
                      data: _summary!,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        h1: theme.textTheme.titleLarge,
                        h2: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        h3: theme.textTheme.titleMedium,
                        p: theme.textTheme.bodyMedium,
                        listBullet: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (items != null && items.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Items', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...items.map<Widget>((dynamic item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('• '),
                            Expanded(child: Text(item.toString())),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
