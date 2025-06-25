import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/qr_service.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter/rendering.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';


import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// User-selectable QR positions when composing wallpaper
enum QrPosition { topLeft, topRight, center, bottomLeft, bottomRight, bottomCenter }


class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  // List of bundled wallpapers (user can extend this list or load from gallery later)
  final List<String> _bundledWallpapers = const [
    'assets/wallpapers/wallpaper1.jpg',
    'assets/wallpapers/wallpaper2.jpg',
    'assets/wallpapers/wallpaper3.jpg',
  ];
  int _selectedWallpaperIndex = 0;
  String? _emergencyId;
  String? _emergencyUrl;
  bool _isLoading = true;
  bool _showNfcOptions = false;

  // Custom wallpaper path when user picks from gallery
  String? _customWallpaperPath;

  // Allow user to choose QR placement
  QrPosition _qrPosition = QrPosition.bottomCenter;
  final GlobalKey _qrKey = GlobalKey();

  

  @override
  void initState() {
    super.initState();
    _generateQr();
  }

  Future<void> _generateQr() async {
    setState(() => _isLoading = true);
    try {
      final data = await QrService.instance.generateQr();
      _emergencyId = data['emergencyId'];
      _emergencyUrl = data['emergencyUrl'];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate QR: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _writeToNfcTag() async {
    if (_emergencyUrl == null) return;
    try {
      final payload = _emergencyUrl!;
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) throw 'NFC not available';
      // Simplified write example
      NfcManager.instance.startSession(
        onDiscovered: (tag) async {
          // Build NDEF record
          final ndef = Ndef.from(tag);
          if (ndef == null) return;
          await ndef.write(NdefMessage([NdefRecord.createText(payload)]));
          NfcManager.instance.stopSession();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('NFC tag written successfully')),
            );
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('NFC write failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency QR & NFC',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Emergency Medical ID',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Present this QR code or use an NFC-enabled device in case of an emergency for quick access to your vital medical information.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Poppins',
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_emergencyId != null)
              Center(
                child: Builder(
                  builder: (context) {
                    final qrSize =
                        MediaQuery.of(context).size.width *
                        0.9; // 90% of screen width

                    final Widget qrWidget = QrImageView(
                      data: _emergencyId!,
                      version: QrVersions.auto,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      size: qrSize,
                      gapless: false,
                      foregroundColor:
                          theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      backgroundColor: Colors.transparent,
                    );

                    return RepaintBoundary(key: _qrKey, child: qrWidget)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .shimmer(
                          delay: 400.ms,
                          duration: 1800.ms,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        );
                  },
                ),
              )
            else
              const Text('Unable to load QR data'),
            const SizedBox(height: 16),
            _buildWallpaperSelector(theme),
            const SizedBox(height: 24),
            Text(
              'Scan this code with any QR scanner.',
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(MdiIcons.wallpaper),
              label: const Text('Set as Lock Screen QR'),
              onPressed: _setAsLockScreen,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(
              thickness: 1,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                MdiIcons.nfcVariant,
                size: 30,
                color: theme.colorScheme.secondary,
              ),
              title: Text(
                'NFC Tag Options',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Switch(
                value: _showNfcOptions,
                onChanged: (value) {
                  setState(() {
                    _showNfcOptions = value;
                  });
                },
              ),
            ),
            if (_showNfcOptions)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child:
                    Column(
                      children: [
                        Text(
                          'Tap an NFC tag to your device to write your emergency ID. Ensure NFC is enabled on your device.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: Icon(MdiIcons.cellphoneNfc),
                          label: const Text('Write to NFC Tag'),
                          onPressed: _writeToNfcTag,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
              ),
            const SizedBox(height: 24),
            TextButton.icon(
              icon: Icon(
                MdiIcons.shieldLockOutline,
                color: theme.colorScheme.error,
              ),
              label: Text(
                'Emergency Access Settings',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontFamily: 'Poppins',
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/emergency-access-settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Loads an image from assets and optionally downsizes it to avoid exceeding
/// device wallpaper size limits (large bitmaps may fail silently on some OEMs).
/// [targetWidth] defaults to 1080px which is safe for most devices.
Future<ui.Image> _loadAssetImage(
  String assetPath, {
  int targetWidth = 1080,
}) async {
  final ByteData data = await rootBundle.load(assetPath);
  // Down-sample large images on decode to save memory / binder size.
  final codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: targetWidth,
  );
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

// Load image from file system
Future<ui.Image> _loadFileImage(String filePath, {int targetWidth = 1080}) async {
  final Uint8List bytes = await File(filePath).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: targetWidth);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

// Pick an image from gallery to use as wallpaper
Future<void> _pickCustomWallpaper() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null && result.files.single.path != null) {
    setState(() {
      _customWallpaperPath = result.files.single.path;
      _selectedWallpaperIndex = 0; // reset
    });
  }
}

  Widget _buildWallpaperSelector(ThemeData theme) {
  final borderColor = theme.colorScheme.primary;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...List.generate(_bundledWallpapers.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedWallpaperIndex = index;
                    _customWallpaperPath = null;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedWallpaperIndex == index && _customWallpaperPath == null
                          ? borderColor
                          : Colors.grey.withOpacity(0.3),
                      width: _selectedWallpaperIndex == index && _customWallpaperPath == null ? 3 : 1,
                    ),
                  ),
                  child: Image.asset(
                    _bundledWallpapers[index],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
            // '+' tile for gallery pick
            GestureDetector(
              onTap: _pickCustomWallpaper,
              child: Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  border: Border.all(
                    color: _customWallpaperPath != null ? borderColor : Colors.grey.withOpacity(0.3),
                    width: _customWallpaperPath != null ? 3 : 1,
                  ),
                ),
                child: _customWallpaperPath == null
                    ? const Icon(Icons.add_photo_alternate_rounded)
                    : Image.file(File(_customWallpaperPath!), fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      // QR position dropdown
      Row(
        children: [
          const Text('QR position: '),
          const SizedBox(width: 8),
          DropdownButton<QrPosition>(
            value: _qrPosition,
            onChanged: (val) => setState(() => _qrPosition = val!),
            items: QrPosition.values
                .map(
                  (pos) => DropdownMenuItem(
                    value: pos,
                    child: Text(pos.name.replaceAll(RegExp(r'([A-Z])'), ' \\1').trim()),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ],
  );
}


  Future<Uint8List> _composeWallpaperBytes(
    ui.Image wallpaper,
    ui.Image qrImage,
  ) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // Draw wallpaper as the background
    final paint = ui.Paint();
    canvas.drawImage(wallpaper, ui.Offset.zero, paint);

    // Determine size for QR (25% of width)
    final double qrTargetWidth = wallpaper.width * 0.25;
    final double scale = qrTargetWidth / qrImage.width;
    final double qrTargetHeight = qrImage.height * scale;

        // Choose placement based on user choice
    const double marginFactor = 0.08; // 8% padding
    final double margin = wallpaper.width * marginFactor;
    double dx;
    double dy;
    switch (_qrPosition) {
      case QrPosition.topLeft:
        dx = margin;
        dy = margin;
        break;
      case QrPosition.topRight:
        dx = wallpaper.width - qrTargetWidth - margin;
        dy = margin;
        break;
      case QrPosition.center:
        dx = (wallpaper.width - qrTargetWidth) / 2;
        dy = (wallpaper.height - qrTargetHeight) / 2;
        break;
      case QrPosition.bottomLeft:
        dx = margin;
        dy = wallpaper.height - qrTargetHeight - margin;
        break;
      case QrPosition.bottomRight:
        dx = wallpaper.width - qrTargetWidth - margin;
        dy = wallpaper.height - qrTargetHeight - margin;
        break;
      case QrPosition.bottomCenter:
      default:
        dx = (wallpaper.width - qrTargetWidth) / 2;
        dy = wallpaper.height - qrTargetHeight - margin;
        break;
    }

    final ui.Rect dstRect = ui.Rect.fromLTWH(
      dx,
      dy,
      qrTargetWidth,
      qrTargetHeight,
    );
    final ui.Rect srcRect = ui.Rect.fromLTWH(
      0,
      0,
      qrImage.width.toDouble(),
      qrImage.height.toDouble(),
    );
    canvas.drawImageRect(qrImage, srcRect, dstRect, paint);

    final ui.Image composedImage = await recorder.endRecording().toImage(
      wallpaper.width,
      wallpaper.height,
    );
    final byteData = await composedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  Future<void> _setAsLockScreen() async {
    try {
      // 1. Capture QR widget as image
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image qrUiImage = await boundary.toImage(pixelRatio: 3.0);

            // 2. Load selected or custom wallpaper
      late ui.Image wallpaperImage;
      String wallpaperPath;
      if (_customWallpaperPath != null) {
        wallpaperPath = _customWallpaperPath!;
        wallpaperImage = await _loadFileImage(wallpaperPath);
      } else {
        wallpaperPath = _bundledWallpapers[_selectedWallpaperIndex];
        wallpaperImage = await _loadAssetImage(wallpaperPath);
      }

      // 3. Compose
      final Uint8List composedBytes = await _composeWallpaperBytes(
        wallpaperImage,
        qrUiImage,
      );

      // 4. Save to temp file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/qr_lock_composite.png';
      final file = File(filePath);
      await file.writeAsBytes(composedBytes);
      bool success = await WallpaperManagerFlutter().setWallpaper(
        file,
        WallpaperManagerFlutter.lockScreen,
      );
      if (!success) {
        // Fallback through both screens attempt
        success = await WallpaperManagerFlutter().setWallpaper(
          file,
          WallpaperManagerFlutter.bothScreens,
        );
      }

      if (!success) {
        // Final fallback: launch system wallpaper chooser so user can confirm.
        final intent = AndroidIntent(
          action: 'android.intent.action.ATTACH_DATA',
          data: Uri.file(file.path).toString(),
          type: 'image/png',
          package:
              'com.android.wallpaper', // Hint for AOSP picker; non-critical
          flags: <int>[
            // FLAG_GRANT_READ_URI_PERMISSION
            1 << 1,
          ],
          arguments: <String, dynamic>{
            'mimeType': 'image/png',
            'android.intent.extra.STREAM': Uri.file(file.path).toString(),
          },
        );
        await intent.launch();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Wallpaper applied${success == true ? '' : ' (fallback both screens)'}'
                  : 'Device prevented wallpaper change',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to set wallpaper: $e')));
    }
  }
}
