import 'package:dio/dio.dart';
import 'package:insurflow/features/claims/data/models/claim_model.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_result.dart';

abstract class ClaimsRemoteDataSource {
  Future<List<Claim>> getMyClaims({String? status});

  Future<Claim> getClaimDetails(String claimId);

  Future<Claim> acceptAssignment(String claimId);

  Future<Claim> declineAssignment(String claimId, String reason);

  Future<Claim> startClaim(String claimId);

  Future<Claim> submitClaim(String claimId);

  Future<VehicleLookupResult> lookupVehicle({
    required String claimId,
    required String plateNumber,
  });

  Future<void> updateClaimVehicle({
    required String claimId,
    required String vehicleId,
    required String policyId,
    required String customerId,
    required String plateNumber,
  });

  Future<void> updateClaimAccident({
    required String claimId,
    required String accidentType,
    required String accidentDate,
    required String accidentTime,
    required String description,
    required String damageDescription,
  });

  Future<void> updateClaimLocation({
    required String claimId,
    required double latitude,
    required double longitude,
    required String address,
    DateTime? capturedAt,
  });

  Future<dynamic> uploadClaimEvidence({
    required String claimId,
    required String filePath,
    required String imageType,
  });

  Future<dynamic> uploadClaimSignature({
    required String claimId,
    required String filePath,
  });

  Future<Map<String, dynamic>> getAdjusterStats({DateTime? from, DateTime? to});
}

class ClaimsRemoteDataSourceImpl implements ClaimsRemoteDataSource {
  const ClaimsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Claim>> getMyClaims({String? status}) async {
    final response = await _dio.get<dynamic>(
      '/claims',
      queryParameters: (status != null && status.isNotEmpty)
          ? {'status': status}
          : null,
    );
    return ClaimModel.listFromResponse(response.data);
  }

  @override
  Future<Claim> getClaimDetails(String claimId) async {
    final response = await _dio.get<dynamic>('/claims/$claimId');
    final claim = ClaimModel.fromResponse(response.data);
    if (claim == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Claim details response did not include an id.',
      );
    }
    return claim;
  }

  /// `POST /claims/{id}/accept-assignment`
  ///
  /// Verified against the live backend as a FIELD_ADJUSTER:
  /// * no request body is required;
  /// * 200 -> `{success, message: "Assignment accepted successfully",
  ///   data: {id, claimNumber, status: "ASSIGNED", assignedTo,
  ///   assignedBy, assignedAt}}` — note `assignedTo`/`assignedBy` are
  ///   bare id strings here, unlike the nested objects the claim
  ///   endpoints return;
  /// * 409 `INVALID_STATUS_TRANSITION` when the claim is not in
  ///   PENDING_ACCEPTANCE;
  /// * 401 without a bearer token.
  ///
  /// The response is a partial claim, so the full record is re-read —
  /// the same approach `startClaim` and `submitClaim` use.
  @override
  Future<Claim> acceptAssignment(String claimId) async {
    await _dio.post<dynamic>('/claims/$claimId/accept-assignment');
    return getClaimDetails(claimId);
  }

  /// `POST /claims/{id}/decline-assignment`
  ///
  /// Verified live: `reason` is required (400 "Reason is required"
  /// without it). The claim leaves this adjuster, so the full record is
  /// re-read the same way accept does.
  @override
  Future<Claim> declineAssignment(String claimId, String reason) async {
    await _dio.post<dynamic>(
      '/claims/$claimId/decline-assignment',
      data: {'reason': reason},
    );
    return getClaimDetails(claimId);
  }

  @override
  Future<Claim> startClaim(String claimId) async {
    // The start response carries only `{status}` — re-read the claim
    // so callers get the full detail payload.
    await _dio.post<dynamic>('/claims/$claimId/inspection/start');
    return getClaimDetails(claimId);
  }

  @override
  Future<Claim> submitClaim(String claimId) async {
    // The submit response carries only `{status}` — re-read the claim.
    await _dio.post<dynamic>('/claims/$claimId/inspection/submit');
    return getClaimDetails(claimId);
  }

  @override
  Future<VehicleLookupResult> lookupVehicle({
    required String claimId,
    required String plateNumber,
  }) async {
    // The backend allow-lists query params and rejects anything else
    // with 400 ("plate" is not allowed) — send `plateNumber` only.
    final response = await _dio.get<dynamic>(
      '/vehicles/lookup',
      queryParameters: {'plateNumber': plateNumber},
    );
    return VehicleLookupResult.fromResponse(
      response.data,
      claimId: claimId,
      plateNumber: plateNumber,
    );
  }

  @override
  Future<void> updateClaimVehicle({
    required String claimId,
    required String vehicleId,
    required String policyId,
    required String customerId,
    required String plateNumber,
  }) async {
    await _dio.put<dynamic>(
      '/claims/$claimId/vehicle',
      data: {
        'vehicleId': vehicleId,
        'policyId': policyId,
        'customerId': customerId,
        'plateNumber': plateNumber,
      },
    );
  }

  @override
  Future<void> updateClaimAccident({
    required String claimId,
    required String accidentType,
    required String accidentDate,
    required String accidentTime,
    required String description,
    required String damageDescription,
  }) async {
    await _dio.put<dynamic>(
      '/claims/$claimId/accident',
      data: {
        'accidentType': accidentType,
        'accidentDate': accidentDate,
        'accidentTime': accidentTime,
        'description': description,
        'damageDescription': damageDescription,
      },
    );
  }

  @override
  Future<void> updateClaimLocation({
    required String claimId,
    required double latitude,
    required double longitude,
    required String address,
    DateTime? capturedAt,
  }) async {
    await _dio.put<dynamic>(
      '/claims/$claimId/location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'capturedAt': (capturedAt ?? DateTime.now().toUtc()).toIso8601String(),
      },
    );
  }

  @override
  Future<dynamic> uploadClaimEvidence({
    required String claimId,
    required String filePath,
    required String imageType,
  }) async {
    // Multer expects the file under `file`; any other field name is
    // rejected with 500 LIMIT_UNEXPECTED_FILE.
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'imageType': imageType,
    });
    final response = await _dio.post<dynamic>(
      '/claims/$claimId/evidence',
      data: formData,
    );
    return response.data;
  }

  @override
  Future<dynamic> uploadClaimSignature({
    required String claimId,
    required String filePath,
  }) async {
    // Same multipart field name as the evidence upload.
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post<dynamic>(
      '/claims/$claimId/signature',
      data: formData,
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getAdjusterStats({
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String, String>{};
    if (from != null) query['from'] = from.toIso8601String().split('T').first;
    if (to != null) query['to'] = to.toIso8601String().split('T').first;

    final response = await _dio.get<dynamic>(
      '/claims/stats',
      queryParameters: query.isEmpty ? null : query,
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }
}
