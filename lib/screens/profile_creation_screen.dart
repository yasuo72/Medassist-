import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/user_profile_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization if needed for titles/buttons


class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  List<String> _reportFilePaths = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _bloodGroupController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _surgeriesController = TextEditingController();
  final _nameController = TextEditingController();
  final _medicationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing profile data into controllers when the screen initializes
    // Ensure provider is listened to, but only read initial values here to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      final profile = profileProvider.userProfile;
      _bloodGroupController.text = profile.bloodGroup;
      // For lists, join them into a string or handle as needed for your UI
      _conditionsController.text = profile.medicalConditions.join(', '); 
      _nameController.text = profile.name;
      _allergiesController.text = profile.allergies.join(', ');
      _surgeriesController.text = profile.pastSurgeries.join(', ');
      _medicationsController.text = profile.currentMedications.join(', ');
      setState(() {
        _reportFilePaths = List<String>.from(profile.reportFilePaths);
      });
    });
  }

  @override
  void dispose() {
    _bloodGroupController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _surgeriesController.dispose();
    _nameController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      
      // Helper to convert comma-separated string to list, trimming whitespace
      List<String> _stringToList(String? text) {
        if (text == null || text.trim().isEmpty) return [];
        return text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      final updatedProfile = profileProvider.userProfile.copyWith(
        name: _nameController.text.trim(),
        bloodGroup: _bloodGroupController.text.trim(),
        medicalConditions: _stringToList(_conditionsController.text),
        allergies: _stringToList(_allergiesController.text),
        pastSurgeries: _stringToList(_surgeriesController.text),
        currentMedications: _stringToList(_medicationsController.text),
        reportFilePaths: _reportFilePaths, // Already updated by _pickFiles and _removeFile
      );

      await profileProvider.updateProfile(updatedProfile);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)?.profileUpdated ?? 'Profile Updated!')),
        );
        // Optionally navigate away or give other feedback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfileProvider = context.watch<UserProfileProvider>();
    final isFingerprintEnrolled = userProfileProvider.userProfile.fingerprintData != null && 
                                userProfileProvider.userProfile.fingerprintData!.isNotEmpty;
    final isFaceScanEnrolled = userProfileProvider.userProfile.faceScanPath != null && 
                             userProfileProvider.userProfile.faceScanPath!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Your Profile', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Secure Your Identity',
                style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildScanOption(
                theme,
                icon: isFaceScanEnrolled ? MdiIcons.checkCircleOutline : MdiIcons.faceRecognition,
                title: 'Face Scan',
                subtitle: isFaceScanEnrolled 
                    ? 'Face scan successfully added!' 
                    : 'Add a secure face scan for identification.',
                onTap: () async {
                  if (isFaceScanEnrolled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Face scan already set up.')),
                    );
                  } else {
                    final result = await Navigator.pushNamed(context, '/face-scan');
                    if (result == true) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Face scan enrollment successful!')),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildScanOption(
                theme,
                icon: isFingerprintEnrolled ? MdiIcons.checkCircleOutline : MdiIcons.fingerprint,
                title: 'Fingerprint Scan',
                subtitle: isFingerprintEnrolled 
                    ? 'Fingerprint successfully added!' 
                    : 'Add your fingerprint for quick access.',
                onTap: () async {
                  if (isFingerprintEnrolled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fingerprint already set up.')),
                    );
                  } else {
                    final result = await Navigator.pushNamed(context, '/fingerprint-scan');
                    if (result == true) {
                      // UserProfileProvider is already updated by FingerprintScanScreen.
                      // The UI will rebuild due to context.watch.
                      // Optionally, show a success message here if desired.
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fingerprint enrollment successful!')),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Personal Information',
                style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'e.g., John Doe',
                icon: MdiIcons.accountCircleOutline,
              ),
              const SizedBox(height: 24),
              Text(
                'Medical Information',
                style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _bloodGroupController,
                labelText: 'Blood Group',
                hintText: 'e.g., O+, A-, B+',
                icon: MdiIcons.waterOutline, // Changed from bloodDrop as it's not available
              ),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _conditionsController,
                labelText: 'Medical Conditions',
                hintText: 'e.g., Diabetes, Hypertension',
                icon: MdiIcons.heartPulse,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _allergiesController,
                labelText: 'Allergies',
                hintText: 'e.g., Peanuts, Pollen, Penicillin',
                icon: MdiIcons.alertCircleOutline,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _surgeriesController,
                labelText: 'Past Surgeries (Optional)',
                hintText: 'e.g., Appendectomy (2010)',
                icon: MdiIcons.medicalBag,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: _medicationsController,
                labelText: 'Current Medications (Optional)',
                hintText: 'e.g., Aspirin 75mg, Metformin 500mg',
                icon: MdiIcons.pill,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Text(
                'Medical Reports',
                style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.fileUploadOutline),
                label: const Text('Upload Reports (PDF/Image)'),
                onPressed: _isLoading ? null : _pickFiles,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                  side: BorderSide(color: theme.colorScheme.primary),
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
              _buildUploadedFilesList(theme), // Call the method to display uploaded files

              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(MdiIcons.checkCircleOutline),
                label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Profile'),
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption(ThemeData theme, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Poppins')),
        trailing: Icon(MdiIcons.chevronRight, color: theme.colorScheme.onSurfaceVariant),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (labelText.contains('Optional')) return null; // Allow optional fields to be empty
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _reportFilePaths.addAll(result.paths.where((path) => path != null).cast<String>());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _removeFile(String path) {
    setState(() {
      _reportFilePaths.remove(path);
    });
  }

  Widget _buildUploadedFilesList(ThemeData theme) {
    if (_reportFilePaths.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Uploaded Reports:', // Consider localizing
          style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reportFilePaths.length,
          itemBuilder: (context, index) {
            final filePath = _reportFilePaths[index];
            final fileName = filePath.split(Platform.pathSeparator).last;
            return Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(MdiIcons.fileDocumentOutline, color: theme.colorScheme.primary),
                title: Text(fileName, style: const TextStyle(fontFamily: 'Poppins')),
                trailing: IconButton(
                  icon: Icon(MdiIcons.closeCircleOutline, color: theme.colorScheme.error),
                  onPressed: () => _removeFile(filePath),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Original _buildScanOption and _buildTextFormField methods are already defined above in the class.
  // The duplicated definitions that were here have been removed.
}

