/// Base failure type. Every repository method returns `Either<Failure, T>`
/// instead of throwing, so the presentation layer never has to deal with
/// raw exceptions (Geolocator's, Dio's, etc.) — only these domain-level
/// failures, which it can map to Arabic messages.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  bool operator ==(Object other) => other is Failure && other.runtimeType == runtimeType && other.message == message;

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

// ---- Generic / server-side --------------------------------------------

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم، حاول لاحقاً']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'تعذر قراءة البيانات المحفوظة']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'تحقق من اتصال الإنترنت']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'حدث خطأ غير متوقع']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Please sign in again.']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'You do not have permission to perform this action.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested claim was not found.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'The request could not be processed.']);
}

// ---- Location / GPS specific -------------------------------------------
// One Failure subtype per GPS state the UI needs to distinguish (mirrors
// the states GpsLocatingScreen already renders, but now sourced from the
// domain layer instead of a raw try/catch around Geolocator calls).

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure([
    super.message = 'خدمة تحديد الموقع (GPS) غير مفعّلة على جهازك. فعّلها ثم أعد المحاولة',
  ]);
}

class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure([
    super.message = 'تم رفض إذن الوصول للموقع. يرجى السماح بالوصول للموقع للمتابعة',
  ]);
}

class LocationPermissionDeniedForeverFailure extends Failure {
  const LocationPermissionDeniedForeverFailure([
    super.message = 'إذن الموقع مرفوض بشكل دائم. افتح إعدادات التطبيق لتفعيله',
  ]);
}

class LocationTimeoutFailure extends Failure {
  const LocationTimeoutFailure([
    super.message = 'استغرق تحديد الموقع وقتاً طويلاً. تحقق من الإشارة وأعد المحاولة',
  ]);
}

class ReverseGeocodeFailure extends Failure {
  const ReverseGeocodeFailure([super.message = 'تعذر تحويل الإحداثيات إلى عنوان']);
}

class InvalidAddressSelectionFailure extends Failure {
  const InvalidAddressSelectionFailure([super.message = 'بيانات العنوان غير مكتملة']);
}
