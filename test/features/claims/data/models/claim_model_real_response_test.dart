import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/data/models/claim_model.dart';
import 'package:insurflow/features/claims/domain/claim_review_summary.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';

/// Parses responses captured verbatim from the live backend
/// (`https://insurflow-backend.onrender.com/api/v1`) so the model is
/// pinned to the real contract rather than an assumed one.
///
/// Fixtures in `test/fixtures/api/` are unedited API output.
dynamic _fixture(String name) {
  final file = File('test/fixtures/api/$name.json');
  return jsonDecode(file.readAsStringSync());
}

void main() {
  group('GET /claims (list response)', () {
    test('parses every summary field the backend sends', () {
      final claims = ClaimModel.listFromResponse(_fixture('claims_list'));

      expect(claims, isNotEmpty);
      for (final claim in claims) {
        expect(claim.id, isNotEmpty);
        expect(claim.isDetailed, isFalse);
        // Unknown would mean the backend sent a status we do not map.
        expect(claim.status, isNot(ClaimStatus.unknown));
      }

      final withAssignee = claims.firstWhere(
        (claim) => claim.assignedTo != null,
      );
      expect(withAssignee.assignedTo!.id, isNotEmpty);
      expect(withAssignee.assignedTo!.name, isNotNull);
      expect(withAssignee.claimNumber, isNotNull);
      expect(withAssignee.customerName, isNotNull);
      expect(withAssignee.plateNumber, isNotNull);
      expect(withAssignee.createdAt, isNotNull);
    });

    test('reads the nested incidentCoordinates object', () {
      final claims = ClaimModel.listFromResponse(_fixture('claims_list'));
      final located = claims.where((c) => c.incidentCoordinates != null);

      expect(located, isNotEmpty);
      for (final claim in located) {
        final fix = claim.incidentCoordinates!;
        expect(fix.latitude, isNot(0));
        expect(fix.longitude, isNot(0));
        expect(fix.label, contains(','));
      }
    });

    test('list claims carry no detail sections', () {
      final claim = ClaimModel.listFromResponse(_fixture('claims_list')).first;

      expect(claim.accident, isNull);
      expect(claim.location, isNull);
      expect(claim.policy, isNull);
      expect(claim.evidence, isEmpty);
      expect(claim.timeline, isEmpty);
      // make/model only arrive with GET /claims/{id}.
      expect(claim.vehicleMakeModel, isNull);
    });
  });

  group('GET /claims/{id} (fully captured claim)', () {
    test('parses every nested section', () {
      final claim = ClaimModel.fromResponse(
        _fixture('claim_detail_complete'),
      )!;

      expect(claim.isDetailed, isTrue);
      expect(claim.claimNumber, isNotNull);
      expect(claim.status, ClaimStatus.submitted);

      // customer {name, phone}
      expect(claim.customerName, isNotNull);
      expect(claim.customerPhone, isNotNull);

      // vehicle {plateNumber, make, model, year, color}
      expect(claim.vehicle, isNotNull);
      expect(claim.plateNumber, isNotNull);
      expect(claim.vehicle!.make, isNotNull);
      expect(claim.vehicle!.model, isNotNull);
      expect(claim.vehicle!.year, isNotNull);
      expect(claim.vehicle!.color, isNotNull);
      expect(claim.vehicleMakeModel, contains(claim.vehicle!.make!));

      // assignment {assignedTo, assignedBy, assignedAt, priority, notes}
      expect(claim.assignment, isNotNull);
      expect(claim.assignedTo?.name, isNotNull);
      expect(claim.assignedTo?.employeeCode, isNotNull);
      expect(claim.assignedBy?.name, isNotNull);
      expect(claim.assignedAt, isNotNull);
      expect(claim.priority, isNotNull);

      // accident {...}
      expect(claim.accident, isNotNull);
      expect(claim.accident!.accidentType, isNotNull);
      expect(claim.accident!.accidentDate, isNotNull);
      expect(claim.accident!.accidentTime, isNotNull);
      expect(claim.accident!.description, isNotNull);
      expect(claim.accident!.damageDescription, isNotNull);

      // location {latitude, longitude, address, capturedAt}
      expect(claim.location, isNotNull);
      expect(claim.location!.hasCoordinates, isTrue);
      expect(claim.location!.address, isNotNull);
      expect(claim.location!.capturedAt, isNotNull);

      // evidence[] with a populated uploadedBy object
      expect(claim.evidencePhotos, isNotEmpty);
      final photo = claim.evidencePhotos.first;
      expect(photo.url, startsWith('http'));
      expect(photo.imageType, isNotNull);
      expect(photo.uploadedAt, isNotNull);
      expect(photo.uploadedBy?.name, isNotNull);

      // signature {url, capturedBy, capturedAt}
      expect(claim.signature, isNotNull);
      expect(claim.signature!.hasImage, isTrue);
      expect(claim.signature!.capturedAt, isNotNull);

      // Verified live against a claim taken through the whole flow:
      // `capturedBy` is a bare id string here, not the {id, name}
      // object the assignment fields use, and the detail read omits
      // the `publicId` that the upload response carries.
      final signature = ClaimModel.fromJson({
        'id': 'c1',
        'signature': {
          'url': 'https://res.cloudinary.com/x/signatures/abc.png',
          'capturedBy': '6ab558c8a170b120d93a5f96',
          'capturedAt': '2026-09-25T14:33:53.299Z',
        },
      }, detailed: true).entity.signature;
      expect(signature!.hasImage, isTrue);
      expect(signature.capturedBy?.id, '6ab558c8a170b120d93a5f96');
      expect(signature.capturedAt, isNotNull);

      // timeline[] audit trail
      expect(claim.timeline.length, greaterThan(1));
      expect(claim.timeline.first.action, isNotNull);
      expect(claim.timeline.first.timestamp, isNotNull);
      expect(
        claim.timeline.any((entry) => entry.hasStatusTransition),
        isTrue,
      );
      expect(
        claim.timeline.any((entry) => entry.performedBy?.role != null),
        isTrue,
      );

      expect(claim.createdBy?.name, isNotNull);
    });

    test('humanises backend enums without altering unknown values', () {
      final claim = ClaimModel.fromResponse(
        _fixture('claim_detail_complete'),
      )!;

      expect(claim.accident!.accidentTypeLabel, 'Rear End Collision');
      expect(claim.evidencePhotos.first.imageTypeLabel, isNotNull);
      expect(claim.assignment!.priorityLabel, isNotNull);
    });
  });

  group('GET /claims/{id} (nothing captured yet)', () {
    test('null sections stay null instead of becoming empty objects', () {
      final claim = ClaimModel.fromResponse(_fixture('claim_detail_sparse'))!;

      expect(claim.isDetailed, isTrue);
      expect(claim.status, ClaimStatus.pendingAcceptance);

      // The backend returns these as all-null objects before the
      // adjuster records anything.
      expect(claim.accident, isNull);
      expect(claim.location, isNull);
      expect(claim.signature, isNull);
      expect(claim.evidencePhotos, isEmpty);

      // The vehicle exists but only as the reported plate.
      expect(claim.plateNumber, isNotNull);
      expect(claim.vehicle!.hasSpecification, isFalse);
      expect(claim.vehicleMakeModel, isNull);

      // Closure fields are untouched on an open claim.
      expect(claim.closedAt, isNull);
      expect(claim.closedBy, isNull);
      expect(claim.closingNotes, isNull);
      expect(claim.decisionNotes, isNull);
    });

    test('still reads the sections the backend did populate', () {
      final claim = ClaimModel.fromResponse(_fixture('claim_detail_sparse'))!;

      expect(claim.customerName, isNotNull);
      expect(claim.assignment, isNotNull);
      expect(claim.assignmentNotes, isNotNull);
      expect(claim.incidentType, isNotNull);
      expect(claim.incidentLocation, isNotNull);
      expect(claim.timeline, isNotEmpty);
    });
  });

  group('GET /vehicles/lookup', () {
    test('keeps the ids PUT /claims/{id}/vehicle requires', () {
      final result = VehicleLookupResult.fromResponse(
        _fixture('vehicle_lookup'),
        claimId: 'claim-1',
        plateNumber: 'ABC-1234',
      );

      expect(result.vehicleId, isNotNull);
      expect(result.customerId, isNotNull);
      expect(result.policyId, isNotNull);
      expect(result.canLinkToClaim, isTrue);
    });

    test('reads vehicle, customer and policy', () {
      final result = VehicleLookupResult.fromResponse(
        _fixture('vehicle_lookup'),
        claimId: 'claim-1',
        plateNumber: 'ABC-1234',
      );

      expect(result.makeModel, 'Toyota Camry');
      expect(result.year, 2022);
      expect(result.color, 'White');
      expect(result.licensePlate, 'ABC-1234');
      // This endpoint spells it `fullName`, unlike the claim payload.
      expect(result.customerName, isNotNull);
      expect(result.customerPhone, isNotNull);
      expect(result.policyNumber, isNotNull);
      expect(result.isPolicyActive, isTrue);
      expect(result.policyStart, isNotNull);
      expect(result.policyEnd, isNotNull);
    });

    test('empty result invents nothing', () {
      final result = VehicleLookupResult.empty(
        claimId: 'claim-1',
        plateNumber: 'XYZ-1',
      );

      expect(result.licensePlate, 'XYZ-1');
      expect(result.makeModel, isNull);
      expect(result.customerName, isNull);
      expect(result.policyNumber, isNull);
      expect(result.year, isNull);
      expect(result.canLinkToClaim, isFalse);
    });
  });

  group('ClaimReviewSummary mirrors backend completeness', () {
    test('a fully captured claim is ready to submit', () {
      final claim = ClaimModel.fromResponse(
        _fixture('claim_detail_complete'),
      )!;
      final summary = ClaimReviewSummary.fromClaim(claim);

      expect(summary.isReady, isTrue);
      expect(summary.missingSections, isEmpty);
      expect(summary.makeModel, isNotNull);
      expect(summary.customerName, isNotNull);
      expect(summary.accidentDescription, isNotNull);
      expect(summary.locationCoordinates, isNotNull);
      expect(summary.evidenceCount, greaterThan(0));
      expect(summary.signatureCaptured, isTrue);
    });

    test('an untouched claim reports exactly what the backend misses', () {
      final claim = ClaimModel.fromResponse(_fixture('claim_detail_sparse'))!;
      final summary = ClaimReviewSummary.fromClaim(claim);

      expect(summary.isReady, isFalse);
      // Matches the submit endpoint's own
      // "Missing: vehicle, accident, location, evidence, signature".
      expect(summary.missingSections, [
        ClaimReviewSectionId.vehicle,
        ClaimReviewSectionId.accident,
        ClaimReviewSectionId.location,
        ClaimReviewSectionId.evidence,
        ClaimReviewSectionId.signature,
      ]);
    });
  });
}
