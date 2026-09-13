import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/usecases/get_claim_details.dart';
import 'package:insurflow/features/claims/domain/usecases/start_claim.dart';
import 'package:insurflow/features/claims/presentation/bloc/claim_details_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockGetClaimDetailsUseCase extends Mock
    implements GetClaimDetailsUseCase {}

class _MockStartClaimUseCase extends Mock implements StartClaimUseCase {}

class _FakeClaim extends Fake implements Claim {}

void main() {
  late _MockGetClaimDetailsUseCase getClaimDetailsUseCase;
  late _MockStartClaimUseCase startClaimUseCase;

  setUpAll(() {
    registerFallbackValue(_FakeClaim());
  });

  setUp(() {
    getClaimDetailsUseCase = _MockGetClaimDetailsUseCase();
    startClaimUseCase = _MockStartClaimUseCase();
  });

  ClaimDetailsBloc buildBloc() {
    return ClaimDetailsBloc(
      getClaimDetailsUseCase: getClaimDetailsUseCase,
      startClaimUseCase: startClaimUseCase,
    );
  }

  final assigned = testClaim();
  const claimId = '6a91ab09c9ff1dc54fabf15b';

  blocTest<ClaimDetailsBloc, ClaimDetailsState>(
    'emits success when claim details are returned',
    build: () {
      when(
        () => getClaimDetailsUseCase(claimId),
      ).thenAnswer((_) async => Right(assigned));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const ClaimDetailsRequested(claimId)),
    expect: () => [
      isA<ClaimDetailsLoadInProgress>(),
      isA<ClaimDetailsLoadSuccess>().having(
        (state) => state.claim.id,
        'id',
        claimId,
      ),
    ],
  );

  blocTest<ClaimDetailsBloc, ClaimDetailsState>(
    'emits not found when the claim does not exist',
    build: () {
      when(
        () => getClaimDetailsUseCase(claimId),
      ).thenAnswer((_) async => const Left(NotFoundFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const ClaimDetailsRequested(claimId)),
    expect: () => [
      isA<ClaimDetailsLoadInProgress>(),
      isA<ClaimDetailsLoadFailure>().having(
        (state) => state.failure,
        'failure',
        isA<NotFoundFailure>(),
      ),
    ],
  );

  blocTest<ClaimDetailsBloc, ClaimDetailsState>(
    'starts an assigned claim and uses the backend claim as source of truth',
    build: () {
      when(() => startClaimUseCase(any())).thenAnswer(
        (_) async => Right(testClaim(status: ClaimStatus.inProgress)),
      );
      return buildBloc();
    },
    seed: () => ClaimDetailsLoadSuccess(assigned),
    act: (bloc) => bloc.add(const ClaimStartRequested()),
    expect: () => [
      isA<ClaimDetailsLoadSuccess>().having(
        (state) => state.isStarting,
        'isStarting',
        true,
      ),
      isA<ClaimDetailsStarted>().having(
        (state) => state.claim.status,
        'status',
        ClaimStatus.inProgress,
      ),
    ],
  );

  blocTest<ClaimDetailsBloc, ClaimDetailsState>(
    'keeps the claim loaded and reports unauthorized start',
    build: () {
      when(
        () => startClaimUseCase(any()),
      ).thenAnswer((_) async => const Left(UnauthorizedFailure()));
      return buildBloc();
    },
    seed: () => ClaimDetailsLoadSuccess(assigned),
    act: (bloc) => bloc.add(const ClaimStartRequested()),
    expect: () => [
      isA<ClaimDetailsLoadSuccess>().having(
        (state) => state.isStarting,
        'isStarting',
        true,
      ),
      isA<ClaimDetailsLoadSuccess>().having(
        (state) => state.startFailure,
        'startFailure',
        isA<UnauthorizedFailure>(),
      ),
    ],
  );

  blocTest<ClaimDetailsBloc, ClaimDetailsState>(
    'reports server failure when start claim fails',
    build: () {
      when(
        () => startClaimUseCase(any()),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    seed: () => ClaimDetailsLoadSuccess(assigned),
    act: (bloc) => bloc.add(const ClaimStartRequested()),
    expect: () => [
      isA<ClaimDetailsLoadSuccess>().having(
        (state) => state.isStarting,
        'isStarting',
        true,
      ),
      isA<ClaimDetailsLoadSuccess>().having(
        (state) => state.startFailure,
        'startFailure',
        isA<ServerFailure>(),
      ),
    ],
  );
}
