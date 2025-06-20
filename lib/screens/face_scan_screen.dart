import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class OvalGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

    final ovalCenter = Offset(size.width / 2, size.height / 2);
    final ovalRadius = min(size.width, size.height) * 0.3;

    canvas.drawOval(
      Rect.fromCircle(center: ovalCenter, radius: ovalRadius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  // Backend configuration
  final String _backendUrl = 'https://api.medassistplus.com/';
  final String _registerEndpoint = 'face/register';
  final String _verifyEndpoint = 'face/verify';

  // Camera and face detection
  late CameraController _cameraController;
  List<CameraDescription>? _cameras;
  late FaceDetector _faceDetector;

  // State management
  bool _isScanning = false;
  bool _matchFound = false;
  bool _isRearCameraSelected = true;
  String _feedbackText = '';
  String _statusText = '';
  bool _isCameraInitialized = false;
  String? _userId;
  String? _matchUserId;
  double? _confidence;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_cameras == null) {
      _cameras = await availableCameras();
    }

    final camera = _cameras![_isRearCameraSelected ? 1 : 0];
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) {
      return null;
    }

    final camera = _cameraController.description;
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) {
      return null;
    }

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!_cameraController.value.isInitialized) return;
    if (!_cameraController.value.isStreamingImages) return;

    setState(() {
      _statusText = 'Processing...';
    });

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        setState(() {
          _feedbackText = '🔍 No face detected';
          _statusText = '';
        });
        return;
      }

      final face = faces.first;
      final faceCenter = Offset(
        face.boundingBox.center.dx,
        face.boundingBox.center.dy,
      );

      final previewSize = _cameraController.value.previewSize!;
      final previewCenter = Offset(
        previewSize.width / 2,
        previewSize.height / 2,
      );

      // Calculate distance from face center to preview center
      final distance = (faceCenter - previewCenter).distance;
      final maxDistance = previewSize.width * 0.3; // 30% of preview width

      if (distance <= maxDistance) {
        setState(() {
          _feedbackText = '✅ Face detected and centered';
          _statusText = '';
        });

        // Take picture and process
        final image = await _cameraController.takePicture();
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        final userProfile = Provider.of<UserProfileProvider>(
          context,
          listen: false,
        );
        _userId = userProfile.userId;

        if (_matchFound) {
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
                setState(() {
                  _matchFound = true;
                  _feedbackText = '✅ Face registered successfully!';
                  _statusText = '';
                });
                success = true;
              } else {
                throw Exception('Failed to register face scan: ${registerResponse.statusCode}');
              }
            } catch (e) {
              if (retryCount < maxRetries - 1) {
                await Future.delayed(Duration(seconds: 2));
                retryCount++;
                continue;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to register face scan after multiple attempts'),
                    backgroundColor: Colors.red,
                  )
                );
                throw Exception('Failed to register face scan: ${e.toString()}');
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
            setState(() {
              _matchFound = true;
              _matchUserId = data['user_id'] as String?;
              _confidence = double.tryParse(data['confidence'].toString());
              _feedbackText = '✅ Face verified successfully!';
              _statusText = 'Face matched successfully!';
              _feedbackText = '✅ Face verified successfully!';
              _statusText = 'Face matched successfully!';
            });
          } else {
            setState(() {
              _feedbackText = 'No match found';
              _statusText = '';
            });
          }
        }
      } else {
        setState(() {
          _feedbackText = '🔍 Center your face in the oval';
          _statusText = '';
        });
      }
    } catch (error) {
      setState(() {
        _feedbackText = 'Error processing face: $error';
        _statusText = '';
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (_isCameraInitialized) {
      await _cameraController.dispose();
      _isCameraInitialized = false;
    }
    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
    });
    await _initializeCamera();
  }

  Future<void> _startScan() async {
    if (!_isScanning) {
      setState(() {
        _isScanning = true;
        _feedbackText = "🔍 Please position your face in the oval";
        _statusText = '';
      });

      _faceDetector ??= FaceDetector(options: FaceDetectorOptions());

      if (_cameraController.value.isInitialized &&
          !_cameraController.value.isStreamingImages) {
        _cameraController.startImageStream(_processCameraImage);
      } else {
        setState(() {
          _feedbackText = 'Camera not initialized or already streaming';
          _statusText = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _cameraController.value.isInitialized
                    ? Stack(
                      children: [
                        CameraPreview(_cameraController),
                        Center(
                          child: CustomPaint(
                            painter: OvalGuidePainter(),
                            size: Size(
                              _cameraController.value.previewSize!.width,
                              _cameraController.value.previewSize!.height,
                            ),
                          ),
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
