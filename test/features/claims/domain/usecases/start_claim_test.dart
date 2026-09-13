import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';
import 'package:insurflow/features/claims/domain/usecases/start_claim.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockClaimsRepository extends Mock implements ClaimsRepository {}

void main() {
  late _MockClaimsRepository repository;
  late StartClaimUseCase useCase;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    repository = _MockClaimsRepository();
    useCase = StartClaimUseCase(repository);
  });

  test('ASSIGNED → IN_PROGRESS is a valid start claim operation', () async {
    final assigned = testClaim(status: ClaimStatus.assigned);
    final started = testClaim(status: ClaimStatus.inProgress);
    when(
      () => repository.startClaim(assigned.id),
    ).thenAnswer((_) async => Right(started));

    final result = await useCase(assigned);

    expect(result, Right(started));
    verify(() => repository.startClaim(assigned.id)).called(1);
  });

  test('cannot start a SUBMITTED claim', () async {
    final result = await useCase(testClaim(status: ClaimStatus.submitted));

    expect(
      result,
      const Left(ValidationFailure('Cannot start claim in current status')),
    );
    verifyNever(() => repository.startClaim(any()));
  });

  test('cannot start an APPROVED claim', () async {
    final result = await useCase(testClaim(status: ClaimStatus.approved));

    expect(result.isLeft(), isTrue);
    result.fold((failure) => expect(failure, isA<ValidationFailure>()), (_) {});
    verifyNever(() => repository.startClaim(any()));
  });

  test('cannot start a REJECTED claim', () async {
    final result = await useCase(testClaim(status: ClaimStatus.rejected));

    expect(result.isLeft(), isTrue);
    result.fold((failure) => expect(failure, isA<ValidationFailure>()), (_) {});
    verifyNever(() => repository.startClaim(any()));
  });

  test('ClaimStatus.canStart is true only for ASSIGNED', () {
    expect(ClaimStatus.assigned.canStart, isTrue);
    expect(ClaimStatus.inProgress.canStart, isFalse);
    expect(ClaimStatus.submitted.canStart, isFalse);
    expect(ClaimStatus.underReview.canStart, isFalse);
    expect(ClaimStatus.approved.canStart, isFalse);
    expect(ClaimStatus.rejected.canStart, isFalse);
    expect(ClaimStatus.parse('IN_PROGRESS'), ClaimStatus.inProgress);
    expect(ClaimStatus.parse('UNDER_REVIEW'), ClaimStatus.underReview);
    expect(ClaimStatus.parse('NEW'), ClaimStatus.newClaim);
  });
}
