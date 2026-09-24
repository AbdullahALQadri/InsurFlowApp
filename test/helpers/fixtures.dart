import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/entities/claim_assignee.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';

AuthSession testSession({
  String token = 'access-token',
  String? displayName = 'Omar',
}) {
  return AuthSession(
    accessToken: token,
    displayName: displayName,
    employeeCode: 'FA-001',
    organizationCode: 'DEMO-INS',
  );
}

/// Shaped like a `GET /claims/{id}` payload: nested sections, with the
/// plate mirrored into `vehicle` the way the backend returns it.
Claim testClaim({
  String id = '6a91ab09c9ff1dc54fabf15b',
  ClaimStatus status = ClaimStatus.assigned,
  String? claimNumber = 'CLM-0001',
  String? customerName = 'Ahmed Ali',
  bool detailed = true,
}) {
  return Claim(
    id: id,
    status: status,
    claimNumber: claimNumber,
    customer: ClaimCustomer(name: customerName, phone: '0590000000'),
    vehicle: const ClaimVehicleInfo(
      plateNumber: 'ABC-1234',
      make: 'Toyota',
      model: 'Corolla',
    ),
    assignment: const ClaimAssignmentInfo(
      assignedTo: ClaimAssignee(id: 'fa-1', name: 'Ahmed Adjuster'),
      priority: 'MEDIUM',
    ),
    incidentLocation: 'Al-Quds Street, Tulkarm',
    isDetailed: detailed,
  );
}
