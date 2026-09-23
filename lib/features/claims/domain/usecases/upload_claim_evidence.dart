import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class UploadClaimEvidenceUseCase {
  const UploadClaimEvidenceUseCase(this._repository);

  final ClaimsRepository _repository;

  Future<Either<Failure, dynamic>> call({
    required String claimId,
    required String filePath,
    required String imageType,
  }) {
    return _repository.uploadClaimEvidence(
      claimId: claimId,
      filePath: filePath,
      imageType: imageType,
    );
  }
}
