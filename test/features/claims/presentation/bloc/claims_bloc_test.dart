import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/usecases/usecase.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';
import 'package:insurflow/features/claims/domain/usecases/get_my_claims.dart';
import 'package:insurflow/features/claims/presentation/bloc/claims_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class _MockGetMyClaimsUseCase extends Mock implements GetMyClaimsUseCase {}

class _FakeNoParams extends Fake implements NoParams {}

void main() {
  late _MockGetMyClaimsUseCase getMyClaimsUseCase;

  setUpAll(() {
    registerFallbackValue(_FakeNoParams());
  });

  setUp(() {
    getMyClaimsUseCase = _MockGetMyClaimsUseCase();
  });

  ClaimsBloc buildBloc() {
    return ClaimsBloc(getMyClaimsUseCase: getMyClaimsUseCase);
  }

  blocTest<ClaimsBloc, ClaimsState>(
    'emits success when assigned claims are returned',
    build: () {
      when(
        () => getMyClaimsUseCase(any()),
      ).thenAnswer((_) async => Right([testClaim()]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const ClaimsRequested()),
    expect: () => [
      isA<ClaimsLoadInProgress>(),
      isA<ClaimsLoadSuccess>().having(
        (state) => state.claims.single.id,
        'id',
        testClaim().id,
      ),
    ],
  );

  blocTest<ClaimsBloc, ClaimsState>(
    'emits empty when the adjuster has no assignments',
    build: () {
      when(
        () => getMyClaimsUseCase(any()),
      ).thenAnswer((_) async => const Right(<Claim>[]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const ClaimsRequested()),
    expect: () => [isA<ClaimsLoadInProgress>(), isA<ClaimsLoadEmpty>()],
  );

  blocTest<ClaimsBloc, ClaimsState>(
    'emits failure when the assignments API fails',
    build: () {
      when(
        () => getMyClaimsUseCase(any()),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const ClaimsRequested()),
    expect: () => [
      isA<ClaimsLoadInProgress>(),
      isA<ClaimsLoadFailure>().having(
        (state) => state.failure,
        'failure',
        isA<ServerFailure>(),
      ),
    ],
  );
}
