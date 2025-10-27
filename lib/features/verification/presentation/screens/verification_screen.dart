import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/icon_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/secondary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/text_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:kasi_hustle/main_layout.dart';

// ==================== EVENTS ====================

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

class StartVerification extends VerificationEvent {}

class SelfieCaptured extends VerificationEvent {
  final XFile selfieImage;
  const SelfieCaptured(this.selfieImage);

  @override
  List<Object> get props => [selfieImage];
}

class IdCaptured extends VerificationEvent {
  final XFile idImage;
  const IdCaptured(this.idImage);

  @override
  List<Object> get props => [idImage];
}

class RetakeSelfie extends VerificationEvent {}

class RetakeId extends VerificationEvent {}

class SubmitVerification extends VerificationEvent {}

class GoToPreviousStep extends VerificationEvent {}

// ==================== STATES ====================

enum VerificationStatus {
  initial,
  instructions,
  selfieCapture,
  selfiePreview,
  idCapture,
  idPreview,
  uploading,
  success,
  failure,
}

class VerificationState extends Equatable {
  final VerificationStatus status;
  final XFile? selfieImage;
  final XFile? idImage;
  final String? errorMessage;

  const VerificationState({
    this.status = VerificationStatus.initial,
    this.selfieImage,
    this.idImage,
    this.errorMessage,
  });

  VerificationState copyWith({
    VerificationStatus? status,
    XFile? selfieImage,
    XFile? idImage,
    String? errorMessage,
  }) {
    return VerificationState(
      status: status ?? this.status,
      selfieImage: selfieImage ?? this.selfieImage,
      idImage: idImage ?? this.idImage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selfieImage, idImage, errorMessage];
}

// ==================== BLOC ====================

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc() : super(const VerificationState()) {
    on<StartVerification>(
      (event, emit) =>
          emit(state.copyWith(status: VerificationStatus.instructions)),
    );
    on<SelfieCaptured>(
      (event, emit) => emit(
        state.copyWith(
          status: VerificationStatus.selfiePreview,
          selfieImage: event.selfieImage,
        ),
      ),
    );
    on<IdCaptured>(
      (event, emit) => emit(
        state.copyWith(
          status: VerificationStatus.idPreview,
          idImage: event.idImage,
        ),
      ),
    );
    on<RetakeSelfie>(
      (event, emit) =>
          emit(state.copyWith(status: VerificationStatus.selfieCapture)),
    );
    on<RetakeId>(
      (event, emit) =>
          emit(state.copyWith(status: VerificationStatus.idCapture)),
    );
    on<SubmitVerification>(_onSubmitVerification);
    on<GoToPreviousStep>(_onGoToPreviousStep);
  }

  void _onGoToPreviousStep(
    GoToPreviousStep event,
    Emitter<VerificationState> emit,
  ) {
    switch (state.status) {
      case VerificationStatus.selfieCapture:
        emit(state.copyWith(status: VerificationStatus.instructions));
        break;
      case VerificationStatus.selfiePreview:
        emit(state.copyWith(status: VerificationStatus.selfieCapture));
        break;
      case VerificationStatus.idCapture:
        emit(state.copyWith(status: VerificationStatus.selfiePreview));
        break;
      case VerificationStatus.idPreview:
        emit(state.copyWith(status: VerificationStatus.idCapture));
        break;
      default:
        break;
    }
  }

  Future<void> _onSubmitVerification(
    SubmitVerification event,
    Emitter<VerificationState> emit,
  ) async {
    if (state.selfieImage != null && state.idImage != null) {
      emit(state.copyWith(status: VerificationStatus.uploading));

      try {
        // Simulate upload to Supabase Storage
        await Future.delayed(const Duration(seconds: 3));
        emit(state.copyWith(status: VerificationStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: VerificationStatus.failure,
            errorMessage: 'Upload failed. Please try again.',
          ),
        );
      }
    }
  }
}

// ==================== VERIFICATION SCREEN ====================

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerificationBloc()..add(StartVerification()),
      child: const VerificationScreenContent(),
    );
  }
}

class VerificationScreenContent extends StatelessWidget {
  const VerificationScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async {
        final bloc = context.read<VerificationBloc>();
        if (bloc.state.status == VerificationStatus.instructions) {
          return true;
        }
        bloc.add(GoToPreviousStep());
        return false;
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: BlocConsumer<VerificationBloc, VerificationState>(
          listener: (context, state) {
            if (state.status == VerificationStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Welcome to Kasi Hustle! 🎉'),
                  backgroundColor: colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainLayout()),
                );
              });
            }

            if (state.status == VerificationStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case VerificationStatus.instructions:
                return InstructionsScreen(
                  onCompleted: () => context.read<VerificationBloc>().add(
                    RetakeSelfie(),
                  ), // Go to selfie capture
                );
              case VerificationStatus.selfieCapture:
                return CameraScreen(
                  onCaptured: (image) => context.read<VerificationBloc>().add(
                    SelfieCaptured(image),
                  ),
                  isSelfie: true,
                );
              case VerificationStatus.selfiePreview:
                return PreviewScreen(
                  imageFile: state.selfieImage!,
                  onRetake: () =>
                      context.read<VerificationBloc>().add(RetakeSelfie()),
                  onConfirm: () => context.read<VerificationBloc>().add(
                    RetakeId(),
                  ), // Go to ID capture
                  confirmButtonText: 'Capture ID',
                  isSelfie: true,
                );
              case VerificationStatus.idCapture:
                return CameraScreen(
                  onCaptured: (image) =>
                      context.read<VerificationBloc>().add(IdCaptured(image)),
                  isSelfie: false,
                );
              case VerificationStatus.idPreview:
                return PreviewScreen(
                  imageFile: state.idImage!,
                  onRetake: () =>
                      context.read<VerificationBloc>().add(RetakeId()),
                  onConfirm: () => context.read<VerificationBloc>().add(
                    SubmitVerification(),
                  ),
                  confirmButtonText: 'Verify',
                  isSelfie: false,
                );
              case VerificationStatus.uploading:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StyledLoadSpinner(),
                      VSpace.lg,
                      UiText(
                        text: 'Submitting verification...',
                        style: TextStyles.bodyLarge,
                      ),
                    ],
                  ),
                );
              case VerificationStatus.success:
                return const VerificationSuccessScreen();
              default:
                return Center(
                  child: UiText(text: 'Welcome!', style: TextStyles.titleLarge),
                );
            }
          },
        ),
      ),
    );
  }
}

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.sparkles, color: colorScheme.primary, size: 100),
            VSpace.lg,
            UiText(
              text: 'Verification Successful!',
              style: TextStyles.headlineSmall,
            ),
            VSpace.sm,
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
          ],
        ),
      ),
    );
  }
}

// ==================== INSTRUCTIONS SCREEN ====================

class InstructionsScreen extends StatelessWidget {
  final VoidCallback onCompleted;

  const InstructionsScreen({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // appBar: AppBar(
      //   title: const UiText(text: 'Identity Verification'),
      //   backgroundColor: colorScheme.surface,
      //   elevation: 0,
      //   leading: IconBtn(
      //     Icons.arrow_back,
      //     onPressed: () => Navigator.of(context).pop(),
      //     color: colorScheme.onBackground,
      //   ),
      // ),
      body: Padding(
        padding: EdgeInsets.all(Insets.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VSpace.xxl,
            UiText(
              text: 'Verify Your Identity',
              style: TextStyles.headlineMedium,
            ),
            VSpace.med,
            UiText(
              text:
                  'We need to confirm you are who you say you are. This helps keep our community safe.',
              style: TextStyles.bodyLarge.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            VSpace.xxl,
            _buildInstructionItem(
              context,
              Ionicons.camera_outline,
              '1. Take a clear selfie',
              'Make sure your face is well-lit and centered.',
            ),
            VSpace.xl,
            _buildInstructionItem(
              context,
              Ionicons.card_outline,
              '2. Capture your ID document',
              'Use a valid government-issued ID (ID card, driver license, or passport).',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryBtn(
                onPressed: onCompleted,
                label: 'Get Started',
                icon: Ionicons.arrow_forward_outline,
                iconIsRight: true,
              ),
            ),
            VSpace.med,
            Center(
              child: TextBtn(
                'Maybe Later',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainLayout()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: IconSizes.lg),
        HSpace.lg,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiText(
                text: title,
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              VSpace.xs,
              UiText(
                text: subtitle,
                style: TextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  const _VerificationAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      title: UiText(text: title),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconBtn(
        Ionicons.arrow_back,
        onPressed: () =>
            context.read<VerificationBloc>().add(GoToPreviousStep()),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ==================== CAMERA SCREEN ====================

class CameraScreen extends StatefulWidget {
  final Function(XFile) onCaptured;
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
      final image = await _controller!.takePicture();
      widget.onCaptured(image);
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
      appBar: _VerificationAppBar(
        title: widget.isSelfie ? 'Take a Selfie' : 'Scan your ID',
      ),
      body: body,
    );
  }
}

class OvalCutoutOverlay extends StatelessWidget {
  const OvalCutoutOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OvalCutoutPainter(Theme.of(context).colorScheme),
      child: Container(),
    );
  }
}

class _OvalCutoutPainter extends CustomPainter {
  final ColorScheme colorScheme;

  _OvalCutoutPainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colorScheme.surface;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2 * 1.2,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addOval(rect),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(rect, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class RectangleCutoutOverlay extends StatelessWidget {
  const RectangleCutoutOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RectangleCutoutPainter(Theme.of(context).colorScheme),
      child: Container(),
    );
  }
}

class _RectangleCutoutPainter extends CustomPainter {
  final ColorScheme colorScheme;

  _RectangleCutoutPainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colorScheme.surface;
    final center = Offset(size.width / 2, size.height / 2);
    final rectHeight = size.height * 0.7;
    final rectWidth = rectHeight * 0.63; // Aspect ratio of a credit card
    final rect = Rect.fromCenter(
      center: center,
      width: rectWidth,
      height: rectHeight,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(rect, Corners.smRadius)),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Corners.smRadius),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// ==================== PREVIEW SCREEN ====================

class PreviewScreen extends StatelessWidget {
  final XFile imageFile;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;
  final String confirmButtonText;
  final bool isSelfie;

  const PreviewScreen({
    super.key,
    required this.imageFile,
    required this.onRetake,
    required this.onConfirm,
    required this.confirmButtonText,
    required this.isSelfie,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _VerificationAppBar(title: 'Preview'),
      body: Column(
        children: [
          Expanded(
            child: isSelfie
                ? Transform.scale(
                    scaleX: -1,
                    child: Image.file(File(imageFile.path)),
                  )
                : Image.file(File(imageFile.path)),
          ),
          Padding(
            padding: EdgeInsets.all(Insets.xl),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryBtn(onPressed: onRetake, label: 'Retake'),
                ),
                HSpace.lg,
                Expanded(
                  child: PrimaryBtn(
                    onPressed: onConfirm,
                    label: confirmButtonText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
