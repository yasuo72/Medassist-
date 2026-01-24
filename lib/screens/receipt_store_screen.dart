import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/user_profile_provider.dart';
import '../services/receipt_service.dart';

class ReceiptStoreScreen extends StatefulWidget {
  const ReceiptStoreScreen({super.key});

  @override
  State<ReceiptStoreScreen> createState() => _ReceiptStoreScreenState();
}

class _ReceiptStoreScreenState extends State<ReceiptStoreScreen> {
  final List<Map<String, dynamic>> _receipts = <Map<String, dynamic>>[];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId =
          Provider.of<UserProfileProvider>(context, listen: false).userId;

      if (userId.isEmpty) {
        setState(() {
          _errorMessage =
              'No Emergency ID found. Please complete your profile first.';
          _receipts.clear();
        });
        return;
      }

      final receipts = await ReceiptService.instance.listReceipts(userId);
      if (!mounted) return;
      setState(() {
        _receipts
          ..clear()
          ..addAll(receipts);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load receipts. Please try again.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startNewReceiptFlow() async {
    if (_isCreating) return;

    final userId =
        Provider.of<UserProfileProvider>(context, listen: false).userId;
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please set your Emergency ID in your profile before saving receipts.',
          ),
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      return;
    }

    final file = File(result.files.single.path!);

    if (!mounted) return;
    setState(() {
      _isCreating = true;
    });

    String cloudinaryUrl;
    try {
      cloudinaryUrl = await ReceiptService.instance.uploadFile(file);
      if (cloudinaryUrl.isEmpty) {
        throw Exception('Empty URL from upload service');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload file. Please try again.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCreating = false;
    });

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return _NewReceiptForm(userId: userId, cloudinaryUrl: cloudinaryUrl);
      },
    );

    if (!mounted) return;
    await _loadReceipts();
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateValue.toString());
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      return dateValue.toString();
    }
  }

  String _formatAmount(dynamic amountValue) {
    if (amountValue == null) return '₹0.00';
    try {
      final numValue =
          amountValue is num
              ? amountValue.toDouble()
              : double.parse(amountValue.toString());
      return '₹${numValue.toStringAsFixed(2)}';
    } catch (_) {
      return amountValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Store')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreating ? null : _startNewReceiptFlow,
        icon: const Icon(Icons.add),
        label: const Text('New Receipt'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReceipts,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading && _receipts.isEmpty) {
      return ListView(
        children: const <Widget>[
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _loadReceipts,
            ),
          ),
        ],
      );
    }

    if (_receipts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Icon(
            MdiIcons.fileDocumentOutline,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No receipts found yet.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a medical or pharmacy receipt to see it here with an AI summary.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (BuildContext context, int index) {
        final receipt = _receipts[index];
        final vendor = (receipt['vendor'] ?? 'Unknown vendor').toString();
        final date = _formatDate(receipt['date']);
        final total = _formatAmount(receipt['totalAmount']);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                MdiIcons.fileDocumentOutline,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(vendor, style: theme.textTheme.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text('Date: $date'),
                Text('Total: $total'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final id = receipt['id']?.toString();
              if (id == null || id.isEmpty) return;
              Navigator.of(context).pushNamed('/receipt-detail', arguments: id);
            },
          ),
        );
      },
      separatorBuilder:
          (BuildContext context, int index) => const SizedBox(height: 8),
      itemCount: _receipts.length,
    );
  }
}

class _NewReceiptForm extends StatefulWidget {
  const _NewReceiptForm({required this.userId, required this.cloudinaryUrl});

  final String userId;
  final String cloudinaryUrl;

  @override
  State<_NewReceiptForm> createState() => _NewReceiptFormState();
}

class _NewReceiptFormState extends State<_NewReceiptForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _vendorController = TextEditingController();
  late final TextEditingController _dateController;
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _itemsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _dateController.dispose();
    _totalController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final List<String> items =
        _itemsController.text
            .split('\n')
            .map((String e) => e.trim())
            .where((String e) => e.isNotEmpty)
            .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one item line.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ReceiptService.instance.createReceipt(
        userId: widget.userId,
        vendor: _vendorController.text.trim(),
        date: _dateController.text.trim(),
        items: items,
        total: _totalController.text.trim(),
        cloudinaryFileUrl: widget.cloudinaryUrl,
        documentType: 'Medical Receipt',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt saved with AI summary.')),
        );
        Navigator.of(context).pop();
      } else {
        final String message =
            result['message']?.toString() ??
            'Failed to save receipt. Please try again.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save receipt. Please try again.'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('New Receipt', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor / Pharmacy / Hospital',
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a vendor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (e.g. 2026-01-20)',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _totalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Total Amount (e.g. 1245.50 or ₹1245.50)',
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the total amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _itemsController,
                decoration: const InputDecoration(
                  labelText: 'Items (one per line)',
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
