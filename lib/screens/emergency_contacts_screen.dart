import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/emergency_contact_service.dart';
import '../models/emergency_contact.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _service = EmergencyContactService();
  List<EmergencyContact> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _service.fetchContacts();
      setState(() => _emergencyContacts = contacts);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contacts: $e')),
      );
    }
  }

  Future<void> _showContactFormDialog({EmergencyContact? contact}) async {
    final _formKey = GlobalKey<FormState>();
    String _name = contact?.name ?? '';
    String _relationship = contact?.relationship ?? '';
    String _phoneNumber = contact?.phoneNumber ?? '';
    bool _isPriority = contact?.isPriority ?? false;
    bool _shareMedicalSummary = contact?.shareMedicalSummary ?? false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            contact == null
                ? 'Add Emergency Contact'
                : 'Edit Emergency Contact',
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          icon: Icon(MdiIcons.account),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onSaved: (value) => _name = value!,
                      ),
                      TextFormField(
                        initialValue: _relationship,
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          icon: Icon(MdiIcons.accountHeart),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a relationship';
                          }
                          return null;
                        },
                        onSaved: (value) => _relationship = value!,
                      ),
                      TextFormField(
                        initialValue: _phoneNumber,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          icon: Icon(MdiIcons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          // Basic phone number validation (can be improved)
                          if (!RegExp(r'^[0-9\-\+\s\(\)]+$').hasMatch(value)) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                        onSaved: (value) => _phoneNumber = value!,
                      ),
                      SwitchListTile(
                        title: const Text('Mark as Priority'),
                        value: _isPriority,
                        onChanged: (bool value) {
                          setStateDialog(() {
                            _isPriority = value;
                          });
                        },
                        secondary: Icon(
                          _isPriority ? MdiIcons.star : MdiIcons.starOutline,
                          color: Colors.amber,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Share Medical Summary'),
                        value: _shareMedicalSummary,
                        onChanged: (bool value) {
                          setStateDialog(() {
                            _shareMedicalSummary = value;
                          });
                        },
                        secondary: Icon(
                          _shareMedicalSummary
                              ? MdiIcons.fileAccount
                              : MdiIcons.fileCancelOutline,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: Text(contact == null ? 'Add' : 'Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  try {
                    if (contact == null) {
                      await _service.addContact(
                        name: _name,
                        relationship: _relationship,
                        phone: _phoneNumber,
                        isPriority: _isPriority,
                        shareMedicalSummary: _shareMedicalSummary,
                      );
                    } else {
                      final updated = contact.copyWith(
                        name: _name,
                        relationship: _relationship,
                        phoneNumber: _phoneNumber,
                        isPriority: _isPriority,
                        shareMedicalSummary: _shareMedicalSummary,
                      );
                      await _service.updateContact(updated);
                    }
                    await _loadContacts();
                    Navigator.of(dialogContext).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(EmergencyContact contactToDelete) async {
    await _service.deleteContact(contactToDelete.id);
    await _loadContacts();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${contactToDelete.name} deleted')));
  }

  Future<void> _showDeleteConfirmationDialog(EmergencyContact contact) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete ${contact.name}?'),
          content: const Text(
            'Are you sure you want to delete this emergency contact? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
              onPressed: () {
                _deleteContact(contact);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrlHelper(Uri url, String actionDescription) async {
    if (!await launchUrl(url)) {
      if (mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not $actionDescription. Please check if you have a supported app.')),
        );
      }
    } else {
        // Optionally, add a success message or log
        print('$actionDescription launched successfully for $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await _launchUrlHelper(launchUri, 'make call to $phoneNumber');
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    await _launchUrlHelper(launchUri, 'send SMS to $phoneNumber');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine if current theme is dark for high-contrast considerations
    // bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        // Potentially add actions like 'Sync Contacts' or 'Test Alert' here later
      ),
      body: _emergencyContacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.accountMultipleOutline,
                    size: 80,
                    color: theme.disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No emergency contacts added yet.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first contact.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = _emergencyContacts[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0] : '?',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${contact.relationship}\n${contact.phoneNumber}',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (contact.shareMedicalSummary)
                          Tooltip(
                            message: 'Medical summary will be shared',
                            child: Icon(MdiIcons.fileAccount, color: theme.colorScheme.tertiary, size: 18),
                          ),
                        if (contact.isPriority)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0), // Add some spacing if both icons are present
                            child: Tooltip(
                              message: 'Priority Contact',
                              child: Icon(MdiIcons.star, color: Colors.amber, size: 20),
                            ),
                          ),
                        IconButton(
                          icon: Icon(MdiIcons.phone, color: theme.colorScheme.primary),
                          onPressed: () {
                            _makePhoneCall(contact.phoneNumber);
                          },
                          tooltip: 'Call ${contact.name}',
                        ),
                        IconButton(
                          icon: Icon(MdiIcons.messageText, color: theme.colorScheme.secondary),
                          onPressed: () {
                            _sendSMS(contact.phoneNumber);
                          },
                          tooltip: 'Message ${contact.name}',
                        ),
                        IconButton(
                          icon: Icon(MdiIcons.deleteOutline, color: theme.colorScheme.error),
                          onPressed: () {
                            _showDeleteConfirmationDialog(contact);
                          },
                          tooltip: 'Delete ${contact.name}',
                        ),
                      ],
                    ),
                    onTap: () {
                      _showContactFormDialog(contact: contact);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showContactFormDialog();
        },
        label: const Text('Add Contact', style: TextStyle(fontFamily: 'Poppins')),
        icon: Icon(MdiIcons.plus),
        // backgroundColor: isDarkMode ? theme.colorScheme.surface : theme.colorScheme.primary,
        // foregroundColor: isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
      ),
    );
  }
}
