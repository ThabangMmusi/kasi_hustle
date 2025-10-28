import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/verification/presentation/widgets/oval_cutout_overlay.dart';
import 'package:kasi_hustle/features/verification/presentation/widgets/rectangle_cutout_overlay.dart';
import 'package:kasi_hustle/features/verification/presentation/widgets/verification_app_bar.dart';

class CameraScreen extends StatefulWidget {
  final Function(File) onCaptured;
  final bool isSelfie;

  const CameraScreen({
    super.key,
    required this.onCaptured,
    required this.isSelfie,
  });

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    if (mounted) {
      setState(() {
        _isInitializing = true;
        _error = null;
      });
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'No cameras available';
            _isInitializing = false;
          });
        }
        return;
      }

      CameraDescription camera;
      if (widget.isSelfie) {
        camera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );
      } else {
        camera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
      }

      final cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _controller = cameraController;

      await cameraController.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Camera error: $e';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _onTakePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final xFile = await _controller!.takePicture();
      final file = File(xFile.path);
      widget.onCaptured(file);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget body;
    if (_error != null) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UiText(text: 'Error: $_error'),
            VSpace.lg,
            PrimaryBtn(onPressed: _initializeCamera, label: 'Retry'),
          ],
        ),
      );
    } else if (_isInitializing) {
      body = const Center(child: StyledLoadSpinner());
    } else {
      body = Column(
        children: [
          Expanded(
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize!.height,
                  height: _controller!.value.previewSize!.width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_controller!),
                      if (widget.isSelfie)
                        const OvalCutoutOverlay()
                      else
                        const RectangleCutoutOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(Insets.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _onTakePicture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Icon(
                      Ionicons.camera,
                      color: colorScheme.onPrimary,
                      size: IconSizes.xl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: VerificationAppBar(
        title: widget.isSelfie ? 'Take a Selfie' : 'Scan your ID',
      ),
      body: body,
    );
  }
}
