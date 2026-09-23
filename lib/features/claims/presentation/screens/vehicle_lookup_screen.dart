import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/license_plate_format.dart';
import 'package:insurflow/features/claims/domain/usecases/lookup_vehicle.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_progress.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_information_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/vehicle_lookup_animation.dart';
import 'package:insurflow/features/claims/presentation/widgets/vehicle_lookup_checks.dart';

class VehicleLookupArgs {
  const VehicleLookupArgs({required this.claimId, required this.plateNumber});

  final String claimId;
  final String plateNumber;
}

class VehicleLookupScreen extends StatefulWidget {
  const VehicleLookupScreen({
    super.key,
    required this.args,
    this.lookupDuration = const Duration(milliseconds: 3800),
    this.onComplete,
  });

  final VehicleLookupArgs args;
  final Duration lookupDuration;
  final VoidCallback? onComplete;

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    required String plateNumber,
  }) {
    return context.pushNamed(
      Routes.vehicleLookupScreen,
      arguments: VehicleLookupArgs(claimId: claimId, plateNumber: plateNumber),
    );
  }

  @override
  State<VehicleLookupScreen> createState() => _VehicleLookupScreenState();
}

class _VehicleLookupScreenState extends State<VehicleLookupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timeline;
  var _notifiedComplete = false;
  VehicleLookupResult? _lookupResult;
  Future<VehicleLookupResult?>? _lookupFuture;

  @override
  void initState() {
    super.initState();
    _timeline = AnimationController(
      vsync: this,
      duration: widget.lookupDuration,
    );
    _timeline.addStatusListener(_onStatus);
    _lookupFuture = _lookupVehicle();
    _lookupFuture!.then((value) {
      if (mounted) _lookupResult = value;
    });
    if (widget.lookupDuration == Duration.zero) {
      _timeline.value = 1;
      _notifyComplete();
    } else {
      _timeline.forward();
    }
  }

  Future<VehicleLookupResult?> _lookupVehicle() async {
    if (widget.onComplete != null) return null;
    if (_plate.isEmpty) {
      // Never query the lookup API with an invented plate number.
      return _plateOnlyResult();
    }
    try {
      final result = await AppDependencies.instance.lookupVehicleUseCase(
        LookupVehicleParams(claimId: widget.args.claimId, plateNumber: _plate),
      );
      return result.fold((_) => _plateOnlyResult(), (value) => value);
    } catch (_) {
      return _plateOnlyResult();
    }
  }

  String get _plate => widget.args.plateNumber.trim();

  VehicleLookupResult _plateOnlyResult() {
    return VehicleLookupResult(
      claimId: widget.args.claimId,
      makeModel: '',
      year: 0,
      colorKey: '',
      licensePlate: _plate,
      customerName: '',
      customerPhone: '',
      policyNumber: '',
      policyStatus: PolicyStatus.unknown,
      policyStart: DateTime.fromMillisecondsSinceEpoch(0),
      policyEnd: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _notifyComplete();
    }
  }

  void _notifyComplete() {
    if (_notifiedComplete) return;
    _notifiedComplete = true;
    if (widget.onComplete != null) {
      widget.onComplete!();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final result = _lookupResult ?? await _lookupFuture ?? _plateOnlyResult();
      if (!mounted) return;
      VehicleInformationScreen.open(context, result: result, replace: true);
    });
  }

  @override
  void dispose() {
    _timeline.removeStatusListener(_onStatus);
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final plate = widget.args.plateNumber.trim().isEmpty
        ? strings.notAvailable
        : widget.args.plateNumber.trim();
    final lottieSize = context.isSmallScreen
        ? context.height(168)
        : context.height(196);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.cardColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey(widget.args.claimId),
        backgroundColor: colors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: colors.textPrimaryColor,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                strings.findingVehicle,
                                textAlign: TextAlign.center,
                                style: context.font22Bold?.copyWith(
                                  color: colors.textPrimaryColor,
                                  fontWeight: FontWeightHelper.bold,
                                  height: 1.2,
                                ),
                              ),
                              context.addVerticalSpace(12),
                              Text(
                                plate,
                                textAlign: TextAlign.center,
                                style: context.font34Bold?.copyWith(
                                  color: colors.textPrimaryColor,
                                  fontWeight: FontWeightHelper.bold,
                                  letterSpacing: 2.4,
                                  height: 1.05,
                                  fontSize: context.width(32),
                                ),
                              ),
                              context.addVerticalSpace(10),
                              Text(
                                strings.checkingVehicleAndPolicy,
                                textAlign: TextAlign.center,
                                style: context.font16Regular?.copyWith(
                                  color: colors.textSecondaryColor,
                                  height: 1.4,
                                ),
                              ),
                              context.addVerticalSpace(20),
                              VehicleLookupAnimation(size: lottieSize),
                              context.addVerticalSpace(28),
                              AnimatedBuilder(
                                animation: _timeline,
                                builder: (context, _) {
                                  return VehicleLookupChecks(
                                    progress: VehicleLookupProgress(
                                      t: _timeline.value,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
