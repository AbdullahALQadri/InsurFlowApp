import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/presentation/screens/evidence_photo_preview_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/evidence_camera_overlay.dart';

class EvidenceCameraArgs {
  const EvidenceCameraArgs({
    required this.claimId,
    this.category = EvidenceCategory.rear,
  });

  final String claimId;
  final EvidenceCategory category;
}

class EvidenceCameraScreen extends StatefulWidget {
  const EvidenceCameraScreen({
    super.key,
    required this.args,
    this.preview,
    this.onCapture,
    this.onGallery,
  });

  final EvidenceCameraArgs args;
  final Widget? preview;
  final VoidCallback? onCapture;
  final VoidCallback? onGallery;

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    required EvidenceCategory category,
  }) {
    return context.pushNamed(
      Routes.evidenceCameraScreen,
      arguments: EvidenceCameraArgs(claimId: claimId, category: category),
    );
  }

  @override
  State<EvidenceCameraScreen> createState() => _EvidenceCameraScreenState();
}

class _EvidenceCameraScreenState extends State<EvidenceCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _camera;
  var _flashOn = false;
  var _flashSupported = false;
  var _capturing = false;
  String? _cameraError;

  bool get _useLiveCamera => widget.preview == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_useLiveCamera) {
      _openCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_useLiveCamera) return;
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      if (state == AppLifecycleState.resumed) _openCamera();
      return;
    }
    if (state == AppLifecycleState.inactive) {
      camera.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed) {
      _openCamera();
    }
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted || cameras.isEmpty) {
        _setCameraError();
        return;
      }
      final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await _camera?.dispose();
      var flashSupported = false;
      try {
        await controller.setFlashMode(FlashMode.off);
        flashSupported = true;
      } catch (_) {
        flashSupported = false;
      }
      setState(() {
        _camera = controller;
        _flashSupported = flashSupported;
        _flashOn = false;
        _cameraError = null;
      });
    } catch (_) {
      if (mounted) _setCameraError();
    }
  }

  void _setCameraError() {
    setState(() {
      _cameraError = AppStrings.of(context).cameraUnavailable;
      _flashSupported = false;
    });
  }

  Future<void> _toggleFlash() async {
    final camera = _camera;
    if (camera == null || !_flashSupported) {
      setState(() => _flashOn = !_flashOn);
      return;
    }
    final next = !_flashOn;
    try {
      await camera.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashOn = next);
    } catch (_) {
      if (mounted) setState(() => _flashSupported = false);
    }
  }

  Future<void> _capture() async {
    if (_capturing) return;
    if (widget.onCapture != null) {
      widget.onCapture!();
      return;
    }

    setState(() => _capturing = true);
    String? imagePath;
    final camera = _camera;
    if (camera != null && camera.value.isInitialized) {
      try {
        final shot = await camera.takePicture();
        imagePath = shot.path;
      } catch (_) {}
    }
    if (!mounted) return;

    final accepted = await EvidencePhotoPreviewScreen.open(
      context,
      claimId: widget.args.claimId,
      category: widget.args.category,
      imagePath: imagePath,
    );
    if (!mounted) return;
    setState(() => _capturing = false);
    if (accepted == true) {
      Navigator.of(context).pop(true);
    }
  }

  void _gallery() {
    if (widget.onGallery != null) {
      widget.onGallery!();
      return;
    }
    // TODO(api): Pick from the device gallery once a local picker is
    // wired. Do not invent a backend upload route.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppSplashColors.abyss,
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey('${widget.args.claimId}-${widget.args.category.name}'),
        backgroundColor: AppSplashColors.abyss,
        body: Stack(
          fit: StackFit.expand,
          children: [
            widget.preview ?? _LivePreview(camera: _camera),
            EvidenceCameraOverlay(
              category: widget.args.category,
              flashOn: _flashOn,
              flashEnabled: _flashSupported || !_useLiveCamera,
              cameraMessage: _cameraError,
              onBack: () => context.pop(),
              onToggleFlash: _toggleFlash,
              onCapture: _capture,
              onGallery: _gallery,
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.camera});

  final CameraController? camera;

  @override
  Widget build(BuildContext context) {
    final controller = camera;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(color: AppSplashColors.abyss);
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize?.height ?? 1,
        height: controller.value.previewSize?.width ?? 1,
        child: CameraPreview(controller),
      ),
    );
  }
}
