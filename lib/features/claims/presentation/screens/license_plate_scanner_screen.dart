import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/presentation/screens/manual_plate_entry_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/license_plate_scan_overlay.dart';

class LicensePlateScannerScreen extends StatefulWidget {
  const LicensePlateScannerScreen({
    super.key,
    required this.claimId,
    this.preview,
    this.onCapture,
  });

  final String claimId;
  final Widget? preview;
  final VoidCallback? onCapture;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(
      Routes.licensePlateScannerScreen,
      arguments: claimId,
    );
  }

  @override
  State<LicensePlateScannerScreen> createState() =>
      _LicensePlateScannerScreenState();
}

class _LicensePlateScannerScreenState extends State<LicensePlateScannerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _camera;
  late final AnimationController _scan;
  late final Animation<double> _scanT;
  var _flashOn = false;
  var _flashSupported = false;
  var _capturing = false;
  String? _cameraError;

  bool get _useLiveCamera => widget.preview == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scanT = CurvedAnimation(parent: _scan, curve: Curves.easeInOut);
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
    final camera = _camera;
    if (camera != null && camera.value.isInitialized) {
      try {
        await camera.takePicture();
      } catch (_) {}
    }
    if (!mounted) return;

    // TODO(api): The Postman collection has no plate OCR endpoint, so a
    // captured photo yields no plate text. Replace this with the real
    // OCR call once the endpoint exists — never invent a detected plate.
    setState(() => _capturing = false);
    context.pushReplacementNamed(
      Routes.manualPlateEntryScreen,
      arguments: ManualPlateEntryArgs(claimId: widget.claimId),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scan.dispose();
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF05080F),
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey(widget.claimId),
        backgroundColor: const Color(0xFF05080F),
        body: Stack(
          fit: StackFit.expand,
          children: [
            widget.preview ?? _LivePreview(camera: _camera),
            AnimatedBuilder(
              animation: _scanT,
              builder: (context, _) {
                return LicensePlateScanOverlay(
                  scanProgress: _scanT.value,
                  flashOn: _flashOn,
                  flashEnabled: _flashSupported || !_useLiveCamera,
                  cameraMessage: _cameraError,
                  onBack: () => context.pop(),
                  onToggleFlash: _toggleFlash,
                  onCapture: _capture,
                );
              },
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
      return const ColoredBox(color: Color(0xFF05080F));
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
