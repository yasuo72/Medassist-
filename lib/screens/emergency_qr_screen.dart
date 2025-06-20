import 'dart:typed_data';
import 'package:flutter/rendering.dart'; // For RenderRepaintBoundary
import 'dart:ui' as ui;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EmergencyQrScreen extends StatefulWidget {
  @override
  _EmergencyQrScreenState createState() => _EmergencyQrScreenState();
}

class _EmergencyQrScreenState extends State<EmergencyQrScreen> {
  final GlobalKey _qrImageKey = GlobalKey();
  final String userId = 'user123abc';
  final String bloodGroup = 'O+';
  final List<String> allergies = ['Peanuts', 'Pollen'];
  final List<Map<String, String>> emergencyContacts = [
    {'name': 'Jane Doe', 'phone': '555-1234'},
    {'name': 'Dr. Smith', 'phone': '555-8765'},
  ];

  bool _setAsLockScreen = false;
  bool _showLockScreenPreview = false;

  String _getQrData() {
    String qrData = '';
    qrData += 'V1:ID:$userId,BG:$bloodGroup\n';
    if (allergies.isNotEmpty) {
      qrData +=
          'V2:ALL:${allergies.join(',')}|CNT:${emergencyContacts.length}\n';
    }
    if (emergencyContacts.isNotEmpty) {
      String contactsStr = emergencyContacts
          .map((c) => '${c['name']}*${c['phone']}')
          .join(',');
      qrData += 'V3:CNT:$contactsStr';
    }
    return qrData;
  }

  Future<void> _saveQrCodeAsImage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      try {
        RenderRepaintBoundary boundary =
            _qrImageKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        final result = await ImageGallerySaverPlus.saveImage(
          pngBytes,
          quality: 100,
          name: 'emergency_qr_code_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (mounted) {
          if (result['isSuccess']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'QR Code saved to Gallery as ${result['filePath']?.split('/').last ?? 'image'}',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save QR Code.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving QR Code: $e')));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied. Cannot save image.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrData = _getQrData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency QR Code'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Scan in Case of Emergency',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.blue.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: RepaintBoundary(
                key: _qrImageKey,
                child: QrImageView(
                  data: qrData,
                  version: 2,
                  size: 300.0,
                  gapless: true,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              context,
              'Blood Group',
              bloodGroup,
              MdiIcons.waterOpacity,
            ),
            _buildInfoSection(
              context,
              'Allergies',
              allergies.join(', '),
              MdiIcons.alertCircleOutline,
            ),
            _buildInfoSection(
              context,
              'Emergency Contacts',
              emergencyContacts
                  .map((c) => '${c['name']} (${c['phone']})')
                  .join('\n'),
              MdiIcons.phoneInTalk,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(MdiIcons.contentCopy, color: Colors.white),
                  label: const Text(
                    'Copy QR Data',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: qrData));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR data copied to clipboard!'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(MdiIcons.contentSave, color: Colors.white),
                  label: const Text(
                    'Save as Image',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _saveQrCodeAsImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text(
                'Set as Lock Screen',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Allow quick access from lock screen'),
              value: _setAsLockScreen,
              onChanged: (bool value) {
                setState(() {
                  _setAsLockScreen = value;
                  _showLockScreenPreview = value;
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'To set as lock screen: Save the QR image, then set it as your wallpaper via phone settings.',
                        ),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                });
              },
              secondary: Icon(
                MdiIcons.cellphoneLock,
                color: Colors.blue.shade800,
              ),
              activeColor: Colors.blue.shade700,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    MdiIcons.informationOutline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Doctors can scan this QR code even if your phone is locked to get vital information quickly.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            ..._showLockScreenPreview
                ? [_buildLockScreenPreview(context, qrData)]
                : [],
          ],
        ),
      ),
    );
  }

  Widget _buildLockScreenPreview(BuildContext context, String qrData) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200, width: 2),
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey.shade800,
      ),
      child: Column(
        children: [
          Text(
            'Lock Screen Preview',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10:30 AM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(MdiIcons.signalCellular3, color: Colors.white70, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 100.0,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.blue.shade900,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"Doctor can scan this even if screen is locked"',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
