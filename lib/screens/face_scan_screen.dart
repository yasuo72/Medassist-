import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:medassist_plus/providers/user_profile_provider.dart';
import 'dart:math' as math;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:flutter_animate/flutter_animate.dart'; // For animations

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  String _instructionText = "Align your face within the frame";
  bool _isScanning = false;
  bool _scanCompleted = false;
  bool _matchFound = false;
  String _feedbackText = 'Align your face within the oval';

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = false; // Start with front camera

  FaceDetector? _faceDetector;
  bool _isProcessing = false; // To prevent concurrent processing

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera({bool useRearCamera = false}) async {
    WidgetsFlutterBinding.ensureInitialized(); // Required for camera plugin
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      setState(() {
        _feedbackText = 'No cameras found on this device.';
        _isCameraInitialized = false;
      });
      return;
    }

    CameraDescription selectedCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == (useRearCamera ? CameraLensDirection.back : CameraLensDirection.front),
      orElse: () => _cameras!.first, // Default to first camera if preferred not found
    );

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false, // No audio needed for face scan
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _feedbackText = 'Align your face within the oval';
      });

      // Initialize FaceDetector
      if (_faceDetector == null) { // Or re-initialize if needed after a previous close
        final options = FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
          performanceMode: FaceDetectorMode.fast,
        );
        _faceDetector = FaceDetector(options: options);
      }

      // Start image stream processing for face detection
      _cameraController?.startImageStream((CameraImage image) {
        if (_isProcessing || _scanCompleted) return; // Don't process if already processing or scan completed
        _isProcessing = true;
        _processCameraImage(image).whenComplete(() {
          _isProcessing = false;
        });
      });

    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _feedbackText = 'Error initializing camera: ${e.description}'; // Use e.description
        _isCameraInitialized = false;
      });
      debugPrint('Camera Error: ${e.code}\nError Message: ${e.description}');
    }
  }

  void _toggleCamera() {
    if (_cameras == null || _cameras!.length < 2) return; // Need at least 2 cameras to toggle
    _isRearCameraSelected = !_isRearCameraSelected;
    _cameraController?.dispose().then((_) {
       _initializeCamera(useRearCamera: _isRearCameraSelected);
    });
  }

  // This method will now be triggered by the image stream, not a button.
  // The concept of "starting a scan" changes to continuous processing.
  // We'll keep _isScanning to control feedback and border, triggered by face presence.

  Future<void> _processCameraImage(CameraImage image) async {
    if (_faceDetector == null || _cameraController == null || !_cameraController!.value.isInitialized) {
      _isProcessing = false;
      return;
    }

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isProcessing = false;
      return;
    }

    try {
      final List<Face> faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        // For simplicity, consider any detected face as a "scan in progress"
        // More complex logic can be added to check if face is centered, eyes open, etc.
        final face = faces.first; // Process the first detected face
        final faceRect = face.boundingBox;

        // Get dimensions for coordinate transformation
        // Size of the image processed by ML Kit (after rotation for upright processing)
        final Size imageSize = _cameraController!.value.previewSize ?? Size(image.width.toDouble(), image.height.toDouble());
        final double imageProcessingWidth = imageSize.width;
        final double imageProcessingHeight = imageSize.height;

        // Size of the preview container in the UI
        const double previewContainerWidth = 300.0;
        const double previewContainerHeight = 380.0;

        // Calculate scaling factors for BoxFit.cover behavior
        // The faceRect coordinates are relative to the imageProcessingWidth/Height
        // If image aspect ratio is different from preview container aspect ratio, one dimension will be cropped.
        // If using math.max, it means we scale up to fill. If using math.min, it's like BoxFit.contain.
        // For BoxFit.cover, the logic is: if source is wider than target (aspect ratio), scale by height. Else scale by width.
        double actualScale;
        final double sourceAspectRatio = imageProcessingWidth / imageProcessingHeight;
        final double targetAspectRatio = previewContainerWidth / previewContainerHeight;

        if (sourceAspectRatio > targetAspectRatio) { // Source is wider or less tall than target
          actualScale = previewContainerHeight / imageProcessingHeight; // Fit height, width will be cropped
        } else { // Source is taller or less wide than target
          actualScale = previewContainerWidth / imageProcessingWidth; // Fit width, height will be cropped
        }

        final double scaledImageWidth = imageProcessingWidth * actualScale;
        final double scaledImageHeight = imageProcessingHeight * actualScale;

        final double offsetX = (scaledImageWidth - previewContainerWidth) / 2.0;
        final double offsetY = (scaledImageHeight - previewContainerHeight) / 2.0;

        // Transform face bounding box center to UI preview container coordinates
        final double transformedFaceCenterX = (faceRect.center.dx * actualScale) - offsetX;
        final double transformedFaceCenterY = (faceRect.center.dy * actualScale) - offsetY;

        // Define the target oval in the UI (centered in the 300x380 container)
        const double ovalCenterX = previewContainerWidth / 2.0; // 150.0
        const double ovalCenterY = previewContainerHeight / 2.0; // 190.0
        const double ovalRadiusX = previewContainerWidth / 2.0; // 150.0
        const double ovalRadiusY = previewContainerHeight / 2.0; // 190.0

        // Check if the transformed face center is within the UI oval
        // ((x - cx)^2 / rx^2) + ((y - cy)^2 / ry^2) <= 1
        final bool isCentered = 
            (math.pow(transformedFaceCenterX - ovalCenterX, 2) / math.pow(ovalRadiusX, 2)) + 
            (math.pow(transformedFaceCenterY - ovalCenterY, 2) / math.pow(ovalRadiusY, 2)) <= 1;

        bool wasCentered = isCentered; // Store the result before setState

        if (mounted) {
          setState(() {
            _isScanning = true; // Indicate that a face is being actively processed
            if (wasCentered) {
              _matchFound = true;
              _scanCompleted = true; // Consider scan complete once a centered face is found
              _feedbackText = "✅ Face detected!";
            } else {
              _matchFound = false;
              _scanCompleted = false;
              _feedbackText = "Center your face in the oval";
            }
          });
        }

        if (wasCentered && mounted) { // Perform async operations if centered and widget is still mounted
          _cameraController?.stopImageStream();
          if (_faceDetector != null) {
            await _faceDetector!.close();
            _faceDetector = null;
            debugPrint("FaceDetector closed on successful scan.");
          }
          HapticFeedback.lightImpact();
          // Ensure context is still valid for Provider and Navigator calls
          if (mounted) {
            Provider.of<UserProfileProvider>(context, listen: false).setFaceScanEnrolled(true);
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isScanning = false;
            _matchFound = false;
            _scanCompleted = false;
            _feedbackText = "No face detected. Align your face.";
          });
        }
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      if (mounted) {
        setState(() {
          _feedbackText = "Error detecting face.";
        });
      }
    }
    _isProcessing = false;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameras![_isRearCameraSelected ? 1 : 0]; // Adjust index based on front/rear
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    // Determine rotation based on device orientation and camera sensor orientation
    // This is crucial for ML Kit to correctly process the image.
    // This logic might need adjustment based on how device orientation is handled/locked in your app.
    // For simplicity, assuming portrait mode and front camera often needs 270 or 90 deg rotation.
    // For rear camera, it might be 90.
    // This is a common point of failure and needs careful testing.
    switch (sensorOrientation) {
      case 90:
        rotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        rotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        rotation = InputImageRotation.rotation270deg;
        break;
      default:
        rotation = InputImageRotation.rotation0deg;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || (format != InputImageFormat.nv21 && format != InputImageFormat.yuv_420_888)) {
      debugPrint('Unsupported image format: ${image.format}');
      return null;
    }

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes, // This might need adjustment based on format (NV21 vs YUV_420_888)
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, 
        format: format, 
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream().catchError((e) {
      debugPrint("Error stopping image stream on dispose: $e");
    });
    _cameraController?.dispose();
    _faceDetector?.close(); // Ensure detector is closed
    debugPrint("FaceScanScreen disposed: Camera and FaceDetector resources released.");
    super.dispose();
  }

  // The _startScan button is no longer primary, but we can keep the UI element for manual trigger if needed
  // or remove it if continuous detection is preferred.
  // For now, let's assume continuous detection once camera is ready.
  void _startScan() async { 
    setState(() {
      _scanCompleted = false;
      _matchFound = false;
      _isScanning = false; // Reset scanning visual state
      _feedbackText = 'Align your face within the oval';
      _instructionText = "Align your face within the frame"; // Reset instruction text
    });

    // Ensure FaceDetector is ready (it might have been closed on a previous successful scan)
    if (_faceDetector == null) {
      final options = FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
      );
      _faceDetector = FaceDetector(options: options);
      debugPrint("FaceDetector re-initialized in _startScan");
    }

    // Ensure camera stream is running
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      if (!_cameraController!.value.isStreamingImages) {
        _cameraController!.startImageStream((CameraImage image) {
          if (_isProcessing || _scanCompleted) return; // Check _scanCompleted here too
          _isProcessing = true;
          _processCameraImage(image).whenComplete(() {
            _isProcessing = false;
          });
        });
        debugPrint("Image stream started in _startScan");
      } else {
        debugPrint("Image stream was already running or re-confirmed.");
      }
    } else {
      debugPrint("Camera not ready in _startScan. Attempting to re-initialize camera.");
      // If camera is not initialized (e.g., initial error), try to initialize again.
      // This makes the Start/Retry button more robust if the initial auto-start failed.
      await _initializeCamera(useRearCamera: _isRearCameraSelected);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Face Scan Help'),
        content: const Text('Your face scan is used to securely access your medical profile. This data is processed locally on your device and is not shared without your consent. Ensure good lighting and hold your phone steady.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Face to Unlock'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.helpCircleOutline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Help / Info Button
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(MdiIcons.helpCircleOutline, color: Colors.white, size: 30),
              onPressed: _showHelpDialog,
            ),
          ),
          // Toggle Camera Button
          if (_cameras != null && _cameras!.length > 1)
            Positioned(
              top: 16, 
              left: 16,
              child: IconButton(
                icon: Icon(
                  _isRearCameraSelected ? MdiIcons.cameraFlipOutline : MdiIcons.cameraFlipOutline, 
                  color: Colors.white, 
                  size: 30
                ),
                onPressed: _toggleCamera,
                tooltip: 'Switch Camera',
              ),
            ),
          // Instructions, Face Detection Guide, and Real-time Feedback
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _instructionText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, backgroundColor: Colors.black54, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Camera Preview with border feedback
                Container(
                  width: 300, // Constrain the preview size
                  height: 380,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(190),
                    border: Border.all(
                      color: _scanCompleted
                          ? (_matchFound ? Colors.greenAccent.shade700 : Colors.redAccent.shade700)
                          : (_isScanning ? theme.colorScheme.primary : Colors.white54),
                      width: _isScanning || _scanCompleted ? 4 : 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(186), // Slightly smaller to show border
                    child: _isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized
                        ? CameraPreview(_cameraController!)
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              // borderRadius is handled by parent Container's ClipRRect for the preview itself
                            ),
                            child: Center(
                              child: _cameras == null
                                  ? const CircularProgressIndicator()
                                  : Text(_feedbackText, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _feedbackText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, backgroundColor: Colors.black45),
                ),
              ],
            ),
          ),
          // Bottom Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isScanning && !_scanCompleted)
                    ElevatedButton.icon(
                      icon: Icon(MdiIcons.faceRecognition),
                      label: const Text('Start Scan'),
                      onPressed: _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                  if (_scanCompleted)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(MdiIcons.refresh),
                          label: const Text('Retry Scan'),
                          onPressed: _startScan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          child: const Text('Switch to QR/Fingerprint'),
                          onPressed: () {
                            // TODO: Implement navigation to QR or Fingerprint options
                            // For now, just pop
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
