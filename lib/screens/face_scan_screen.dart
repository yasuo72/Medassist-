import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart'; // for WriteBuffer
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import '../providers/user_profile_provider.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class OvalGuidePainter extends CustomPainter {
  OvalGuidePainter({this.radiusScale = 0.45});
  final double radiusScale;

  @override
  void paint(Canvas canvas, Size size) {
    final ovalRadius = min(size.width, size.height) * radiusScale;
    final ovalRect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: ovalRadius,
    );

    // Create an even-odd path: outer rect minus inner oval
    final path =
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addOval(ovalRect);

    // Semi-transparent overlay everywhere except inside the oval
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.55);
    canvas.drawPath(path, overlayPaint);

    // Blue border for the oval
    final borderPaint =
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant OvalGuidePainter oldDelegate) =>
      oldDelegate.radiusScale != radiusScale;
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  // Helper to safely call setState only when mounted
  void _updateState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }
  // Backend configuration
  final String _backendUrl =
      'https://medassistbackend-production.up.railway.app/';
  final String _registerEndpoint = 'api/face/register';
  final String _verifyEndpoint = 'api/face/identify';

  // Camera and face detection
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  late final FaceDetector _faceDetector;

  // State management
  bool _isScanning = false;
  bool _matchFound = false;
  bool _isRearCameraSelected = false;
  String _feedbackText = '';
  String _statusText = '';
  bool _isCameraInitialized = false;
  String? _userId;
  String? _matchUserId;
  double? _confidence;

  @override
  void initState() {
  super.initState();
  _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableTracking: true,
      ),
    );
    debugPrint('[FaceScan] FaceDetector initialized');
  _initializeCamera();
}


  Future<void> _initializeCamera() async {
    if (_cameras == null) {
      _cameras = await availableCameras();
    }

    final camera = _cameras!.firstWhere(
      (c) =>
          (_isRearCameraSelected &&
              c.lensDirection == CameraLensDirection.back) ||
          (!_isRearCameraSelected &&
              c.lensDirection == CameraLensDirection.front),
      orElse: () => _cameras!.first,
    );
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      _updateState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    if (_cameraController?.value.isStreamingImages == true) {
      _cameraController?.stopImageStream();
    }
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  // Convert YUV_420_888 (three plane) to NV21 byte array as required by ML Kit
  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = width * height ~/ 4;

    final Uint8List nv21 = Uint8List(ySize + uvSize * 2);

    // Y plane copy (no padding expected but use bytesPerRow in case)
    int offset = 0;
    for (int row = 0; row < height; row++) {
      nv21.setRange(offset, offset + width,
          image.planes[0].bytes, row * image.planes[0].bytesPerRow);
      offset += width;
    }

    // V and U planes are swapped for NV21 (VU interleaved)
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!; // should be 2

    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        int uvIndex = row * uvRowStride + col * uvPixelStride;
        // NV21 expects V first then U
        nv21[offset++] = vPlane[uvIndex];
        nv21[offset++] = uPlane[uvIndex];
      }
    }
    return nv21;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = _cameraController;
    if (controller == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(controller.description.sensorOrientation);
    if (rotation == null) return null;

        final bytes = _yuv420ToNv21(image);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> _processCameraImage(CameraImage image) async {
    debugPrint('[FaceScan] Frame received');
  if (!mounted) return; // ensure widget still active
    if (!_cameraController!.value.isInitialized) return;
    if (!_cameraController!.value.isStreamingImages) return;

    _updateState(() {
      _statusText = 'Processing...';
    });

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      debugPrint('[FaceScan] Faces detected: ${faces.length}');
      if (faces.isEmpty) {
        _updateState(() {
          _feedbackText = '🔍 No face detected';
          _statusText = '';
        });
        return;
      }

      _updateState(() {
        _feedbackText = '✅ Face detected and centered';
        _statusText = '';
      });

      // Take picture and process
      final photoFile = await _cameraController!.takePicture();
      final rawBytes = await photoFile.readAsBytes();
      // Compress to keep payload <1 MB
            final img.Image? decoded = img.decodeImage(rawBytes);
      Uint8List bytes;
      if (decoded != null) {
                final resized = img.copyResize(decoded, width: 320);
        bytes = Uint8List.fromList(img.encodeJpg(resized, quality: 50));
        debugPrint('[FaceScan] compressed bytes: \\${bytes.length}');
      } else {
        bytes = rawBytes;
      }
      final base64Image = base64Encode(bytes);

      final userProfile = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );
      _userId = userProfile.userId;

      // If the face isn't registered yet, register first; otherwise verify
      if (!_matchFound) {
        final maxRetries = 3;
        int retryCount = 0;
        bool success = false;

        while (retryCount < maxRetries && !success) {
          try {
            final registerResponse = await http.post(
              Uri.parse('$_backendUrl$_registerEndpoint'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'user_id': _userId,
                'image_data': base64Image,
                'metadata': {
                  'name': userProfile.name,
                  'emergency_contacts': userProfile.emergencyContacts,
                  'medical_conditions': userProfile.medicalConditions,
                },
              }),
            );

            if (registerResponse.statusCode == 200) {
              await _cameraController?.stopImageStream();
              _updateState(() {
                _matchFound = true;
                _isScanning = false;
                _feedbackText = '✅ Face registered successfully!';
                _statusText = '';
              });
              success = true;
            } else {
              throw Exception(
                'Failed to register face scan: ${registerResponse.statusCode}',
              );
            }
          } catch (e) {
            if (retryCount < maxRetries - 1) {
              await Future.delayed(Duration(seconds: 2));
              retryCount++;
              continue;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to register face scan after multiple attempts',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              throw Exception(
                'Failed to register face scan: ${e.toString()}',
              );
            }
          }
        }
      } else {
        final verifyResponse = await http.post(
          Uri.parse('$_backendUrl$_verifyEndpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'image_data': base64Image,
            'min_confidence': 0.7,
          }),
        );

        if (verifyResponse.statusCode == 200) {
          final data = jsonDecode(verifyResponse.body);
          await _cameraController?.stopImageStream();
          _updateState(() {
            _matchFound = true;
            _isScanning = false;
            _matchUserId = data['user_id'] as String?;
            _confidence = double.tryParse(data['confidence'].toString());
            _feedbackText = '✅ Face verified successfully!';
            _statusText = 'Face matched successfully!';
          });
          if (mounted) {
            Future.microtask(() => Navigator.of(context).pushReplacementNamed('/face-success'));
          }
        } else {
          _updateState(() {
            _feedbackText = 'No match found';
            _statusText = '';
          });
        }
      }

    } catch (error) {
      _updateState(() {
        _feedbackText = 'Error processing face: $error';
        _statusText = '';
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (_isCameraInitialized) {
      await _cameraController?.dispose();
      _isCameraInitialized = false;
    }
    _updateState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
    });
    await _initializeCamera();
  }

  Future<void> _startScan() async {
    debugPrint('[FaceScan] Start scan pressed');
    if (!_isScanning) {
      _updateState(() {
        _isScanning = true;
        _feedbackText = "🔍 Please position your face in the oval";
        _statusText = '';
      });

      if (_cameraController!.value.isInitialized &&
          !_cameraController!.value.isStreamingImages) {
        debugPrint('[FaceScan] Starting image stream');
      _cameraController!.startImageStream(_processCameraImage);
      } else {
        _updateState(() {
          _feedbackText = 'Camera not initialized or already streaming';
          _statusText = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCamera,
        child: Icon(
          _isRearCameraSelected ? Icons.camera_rear : Icons.camera_front,
        ),
      ),
      appBar: AppBar(
        title: const Text('Face Scan'),
        actions: [
          IconButton(
            icon: Icon(
              _isRearCameraSelected ? Icons.camera_rear : Icons.camera_front,
            ),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                (_cameraController != null && _cameraController!.value.isInitialized)
                    ? Stack(
                      children: [
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraController!.value.previewSize!.height,
                              height: _cameraController!.value.previewSize!.width,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(painter: OvalGuidePainter()),
                        ),
                      ],
                    )
                    : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(_statusText, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text(
                  _feedbackText,
                  style: TextStyle(
                    color: _matchFound ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startScan,
                  child: const Text('Start Scan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
