import 'package:flutter/material.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/authentication/presentation/screens/login_screen.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_details_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_location_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_evidence_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/evidence_camera_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/evidence_photo_preview_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/capturing_location_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/location_permission_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/customer_signature_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_review_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_validation_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_details_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_submitted_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claim_location_map_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/claims_list_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/new_assignment_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/license_plate_scanner_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/manual_plate_entry_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/plate_ocr_result_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_identification_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_information_screen.dart';
import 'package:insurflow/features/claims/presentation/screens/vehicle_lookup_screen.dart';
import 'package:insurflow/features/home/presentation/screens/main_screen.dart';
import 'package:insurflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:insurflow/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:insurflow/features/profile/presentation/screens/change_password_screen.dart';
import 'package:insurflow/features/splash/presentation/screens/splash_screen.dart';
import 'package:insurflow/core/l10n/app_strings.dart';

class AppRouter {
  const AppRouter();

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.mainScreen:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case Routes.claimsListScreen:
        return MaterialPageRoute(builder: (_) => const ClaimsListScreen());
      case Routes.newAssignmentScreen:
        final claimId = settings.arguments is String
            ? settings.arguments as String
            : '';
        return MaterialPageRoute(
          builder: (_) => NewAssignmentScreen(claimId: claimId),
        );
      case Routes.claimDetailsScreen:
        final claimId = settings.arguments is String
            ? settings.arguments as String
            : '';
        return MaterialPageRoute(
          builder: (_) => ClaimDetailsScreen(claimId: claimId),
        );
      case Routes.vehicleIdentificationScreen:
        final claimId = settings.arguments is String
            ? settings.arguments as String
            : '';
        return MaterialPageRoute(
          builder: (_) => VehicleIdentificationScreen(claimId: claimId),
        );
      case Routes.licensePlateScannerScreen:
        final claimId = settings.arguments is String
            ? settings.arguments as String
            : '';
        return MaterialPageRoute(
          builder: (_) => LicensePlateScannerScreen(claimId: claimId),
        );
      case Routes.plateOcrResultScreen:
        final args = settings.arguments;
        final result = args is PlateOcrResultArgs
            ? args
            : const PlateOcrResultArgs(claimId: '', plateNumber: '');
        return MaterialPageRoute(
          builder: (_) => PlateOcrResultScreen(args: result),
        );
      case Routes.manualPlateEntryScreen:
        final args = settings.arguments;
        final entry = args is ManualPlateEntryArgs
            ? args
            : const ManualPlateEntryArgs(claimId: '');
        return MaterialPageRoute(
          builder: (_) => ManualPlateEntryScreen(args: entry),
        );
      case Routes.vehicleLookupScreen:
        final args = settings.arguments;
        final lookup = args is VehicleLookupArgs
            ? args
            : const VehicleLookupArgs(claimId: '', plateNumber: '');
        return MaterialPageRoute(
          builder: (_) => VehicleLookupScreen(args: lookup),
        );
      case Routes.vehicleInformationScreen:
        final args = settings.arguments;
        final result = args is VehicleLookupResult
            ? args
            : VehicleLookupResult.empty(claimId: '');
        return MaterialPageRoute(
          builder: (_) => VehicleInformationScreen(result: result),
        );
      case Routes.accidentDetailsScreen:
        final args = settings.arguments;
        final accident = args is AccidentDetailsArgs
            ? args
            : const AccidentDetailsArgs(claimId: '');
        return MaterialPageRoute(
          builder: (_) => AccidentDetailsScreen(args: accident),
        );
      case Routes.locationPermissionScreen:
        final args = settings.arguments;
        final location = args is LocationPermissionArgs
            ? args
            : const LocationPermissionArgs(claimId: '');
        return MaterialPageRoute(
          builder: (_) => LocationPermissionScreen(args: location),
        );
      case Routes.capturingLocationScreen:
        final args = settings.arguments;
        final capturing = args is CapturingLocationArgs
            ? args
            : CapturingLocationArgs(claimId: args is String ? args : '');
        return MaterialPageRoute(
          builder: (_) => CapturingLocationScreen(args: capturing),
        );
      case Routes.accidentLocationScreen:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => AccidentLocationScreen(
            claimId: args is String ? args : '',
          ),
        );
      case Routes.vehicleEvidenceScreen:
        final args = settings.arguments;
        final evidence = args is VehicleEvidenceArgs
            ? args
            : VehicleEvidenceArgs(claimId: args is String ? args : '');
        return MaterialPageRoute(
          builder: (_) => VehicleEvidenceScreen(args: evidence),
        );
      case Routes.evidenceCameraScreen:
        final args = settings.arguments;
        final camera = args is EvidenceCameraArgs
            ? args
            : EvidenceCameraArgs(claimId: args is String ? args : '');
        return MaterialPageRoute(
          builder: (_) => EvidenceCameraScreen(args: camera),
        );
      case Routes.evidencePhotoPreviewScreen:
        final args = settings.arguments;
        final preview = args is EvidencePhotoPreviewArgs
            ? args
            : const EvidencePhotoPreviewArgs(
                claimId: '',
                category: EvidenceCategory.rear,
              );
        return MaterialPageRoute(
          builder: (_) => EvidencePhotoPreviewScreen(args: preview),
        );
      case Routes.customerSignatureScreen:
        final args = settings.arguments;
        final signature = args is CustomerSignatureArgs
            ? args
            : CustomerSignatureArgs(claimId: args is String ? args : '');
        return MaterialPageRoute(
          builder: (_) => CustomerSignatureScreen(args: signature),
        );
      case Routes.claimReviewScreen:
        final args = settings.arguments;
        final review = args is ClaimReviewArgs
            ? args
            : ClaimReviewArgs(claimId: args is String ? args : '');
        return MaterialPageRoute(
          builder: (_) => ClaimReviewScreen(args: review),
        );
      case Routes.claimValidationScreen:
        final args = settings.arguments;
        final validation = args is ClaimValidationArgs
            ? args
            : ClaimValidationArgs(claimId: args is String ? args : '');
        return MaterialPageRoute(
          builder: (_) => ClaimValidationScreen(args: validation),
        );
      case Routes.changePasswordScreen:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case Routes.notificationCenterScreen:
        return MaterialPageRoute(
          builder: (_) => const NotificationCenterScreen(),
        );

      case Routes.claimSubmittedScreen:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => ClaimSubmittedScreen(
            args: args is ClaimSubmittedArgs
                ? args
                : const ClaimSubmittedArgs(),
          ),
        );

      case Routes.claimLocationMapScreen:
        final args = settings.arguments;
        // The screen needs an already-validated point; without one
        // there is nothing to map, so fall through to the no-route
        // page rather than opening an empty map.
        if (args is ClaimLocationMapArgs) {
          return MaterialPageRoute(
            builder: (_) => ClaimLocationMapScreen(args: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Builder(
                builder: (context) =>
                    Text(AppStrings.of(context).routeNotFound),
              ),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Builder(
                builder: (context) =>
                    Text(AppStrings.of(context).routeNotFound),
              ),
            ),
          ),
        );
    }
  }
}
