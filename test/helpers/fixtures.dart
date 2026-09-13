import 'package:insurflow/features/authentication/domain/entities/auth_session.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';

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

Claim testClaim({
  String id = '6a91ab09c9ff1dc54fabf15b',
  ClaimStatus status = ClaimStatus.assigned,
  String? claimNumber = 'CLM-0001',
  String? customerName = 'Ahmed Ali',
}) {
  return Claim(
    id: id,
    status: status,
    claimNumber: claimNumber,
    customerName: customerName,
    customerPhone: '0590000000',
    vehicleMake: 'Toyota',
    vehicleModel: 'Corolla',
    initialPlateNumber: 'ABC-1234',
    incidentLocation: 'Al-Quds Street, Tulkarm',
  );
}
