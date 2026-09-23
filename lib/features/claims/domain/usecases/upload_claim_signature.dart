import 'package:dartz/dartz.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';

class UploadClaimSignatureUseCase {
  const UploadClaimSignatureUseCase(this._repository);

  final ClaimsRepository _repository;

  Future<Either<Failure, dynamic>> call({
    required String claimId,
    required String filePath,
  }) {
    return _repository.uploadClaimSignature(
      claimId: claimId,
      filePath: filePath,
    );
  }
}
