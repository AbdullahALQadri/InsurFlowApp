import 'package:flutter/widgets.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/features/claims/domain/accident_details.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/claim_validation_progress.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/features/claims/domain/vehicle_lookup_progress.dart';
import 'package:insurflow/features/claims/domain/entities/claim_details.dart';

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  bool get isArabic => locale.languageCode == 'ar';

  String get signIn => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get welcomeBack => isArabic ? 'مرحباً بعودتك' : 'Welcome back';
  String get loginSubtitle => isArabic
      ? 'سجّل الدخول لمتابعة مهامك الميدانية.'
      : 'Sign in to continue your field assignments.';
  String get organizationCode => isArabic ? 'رمز المؤسسة' : 'Organization code';
  String get organizationCodeHint =>
      isArabic ? 'أدخل رمز المؤسسة' : 'Enter organization code';
  String get employeeCode => isArabic ? 'الرقم الوظيفي' : 'Employee code';
  String get employeeCodeHint =>
      isArabic ? 'أدخل الرقم الوظيفي' : 'Enter employee code';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get passwordHint => isArabic ? 'أدخل كلمة المرور' : 'Enter password';
  String get forgotPassword =>
      isArabic ? 'نسيت كلمة المرور؟' : 'Forgot password?';
  String get showPassword => isArabic ? 'إظهار كلمة المرور' : 'Show password';
  String get hidePassword => isArabic ? 'إخفاء كلمة المرور' : 'Hide password';
  String get invalidCredentials => isArabic
      ? 'بيانات الدخول غير صحيحة'
      : 'Invalid organization, employee code, or password';
  String get requiredField =>
      isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
  String get passwordRequired =>
      isArabic ? 'كلمة المرور مطلوبة' : 'Password is required';
  String get secureFieldAccess =>
      isArabic ? 'وصول ميداني آمن' : 'Secure field access';

  String get loadingAssignments =>
      isArabic ? 'جاري تحميل المهام...' : 'Loading your assignments...';
  String get noAssignments => isArabic
      ? 'لا توجد مهام مسندة إليك حاليًا.'
      : 'No assignments available.';
  String get unableToLoadAssignments => isArabic
      ? 'تعذر تحميل المهام المسندة إليك. حاول مرة أخرى.'
      : 'Unable to load your assignments. Please try again.';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get myClaims => isArabic ? 'مطالباتي' : 'My Claims';
  String get assignmentsSubtitle => isArabic
      ? 'المهام والمطالبات المسندة إليك.'
      : 'Assignments and claims assigned to you.';
  String get noClaimsInStatus =>
      isArabic ? 'لا توجد مطالبات بهذه الحالة.' : 'No claims in this status.';
  String get searchHint => isArabic ? 'بحث' : 'Search';

  String get filterAll => isArabic ? 'الكل' : 'All';
  String get statusNew => isArabic ? 'جديدة' : 'New';
  String get statusPendingAcceptance =>
      isArabic ? 'بانتظار القبول' : 'Pending Acceptance';
  String get statusAssigned => isArabic ? 'مسندة' : 'Assigned';
  String get statusUnderReview => isArabic ? 'قيد المراجعة' : 'Under Review';
  String get statusInProgress => isArabic ? 'قيد التنفيذ' : 'In Progress';
  String get statusCorrection => isArabic ? 'تصحيح' : 'Correction';
  String get statusSubmitted => isArabic ? 'مُقدمة' : 'Submitted';
  String get statusApproved => isArabic ? 'مقبولة' : 'Approved';
  String get statusRejected => isArabic ? 'مرفوضة' : 'Rejected';
  String get statusClosed => isArabic ? 'مغلقة' : 'Closed';
  String get statusUnknown => isArabic ? 'غير معروفة' : 'Unknown';
  String get statusCorrectionRequired =>
      isArabic ? 'تصحيح مطلوب' : 'Correction Required';
  String get todayTasks => isArabic ? 'مهام اليوم' : "Today's Tasks";
  String get searchClaimsHint => isArabic
      ? 'ابحث برقم المطالبة أو المركبة أو اللوحة'
      : 'Search claim, vehicle or plate';
  String get noClaimsFound => isArabic ? 'لا توجد مطالبات' : 'No claims found';
  String get noClaimsFoundHint => isArabic
      ? 'جرّب بحثاً أو تصفية أخرى لعرض المهام في قائمتك.'
      : 'Try another search or filter to see assignments on your list.';

  String get newAssignment => isArabic ? 'مهمة جديدة' : 'New Assignment';
  String get assignedTaskMessage => isArabic
      ? 'تم إسناد هذه المهمة الميدانية إليك.'
      : 'You have been assigned this field task.';
  String get customer => isArabic ? 'العميل' : 'CUSTOMER';
  String get vehicle => isArabic ? 'المركبة' : 'VEHICLE';
  String get location => isArabic ? 'الموقع' : 'LOCATION';
  String get assignment => isArabic ? 'الإسناد' : 'ASSIGNMENT';
  String get assignedBy => isArabic ? 'أُسندت بواسطة:' : 'Assigned by:';
  String get assignedTo => isArabic ? 'أُسندت إلى:' : 'Assigned to:';
  String get assignedAt => isArabic ? 'تاريخ الإسناد:' : 'Assigned at:';
  String get viewClaim => isArabic ? 'عرض المطالبة' : 'View Claim';
  String get later => isArabic ? 'لاحقاً' : 'Later';
  String get startClaim => isArabic ? 'بدء المطالبة' : 'Start Claim';
  String get continueInspection =>
      isArabic ? 'متابعة المعاينة' : 'Continue Inspection';
  String get fixCorrection => isArabic ? 'تصحيح المطالبة' : 'Fix Correction';
  String get requestedCorrection =>
      isArabic ? 'التصحيح المطلوب' : 'Requested correction';
  String get claimLockedHint => isArabic
      ? 'لا يمكن تعديل هذه المطالبة في حالتها الحالية.'
      : 'This claim cannot be edited in its current status.';
  String get lastUpdatedLabel => isArabic ? 'آخر تحديث:' : 'Last updated:';
  String inspectionStepsCompleted(int completed, int total) => isArabic
      ? '$completed / $total خطوات مكتملة'
      : '$completed / $total steps completed';
  String get submittingClaim =>
      isArabic ? 'جاري تقديم المطالبة...' : 'Submitting claim...';
  String get claimSubmitted => isArabic
      ? 'تم تقديم المطالبة وهي الآن قيد المراجعة.'
      : 'The claim was submitted and is now under review.';
  String get submitFailed => isArabic
      ? 'تعذر تقديم المطالبة. حاول مرة أخرى.'
      : 'Unable to submit the claim. Please try again.';
  String get savingInspection =>
      isArabic ? 'جاري حفظ البيانات...' : 'Saving inspection data...';
  String get uploadingEvidence =>
      isArabic ? 'جاري رفع الصورة...' : 'Uploading photo...';
  String get uploadingSignature =>
      isArabic ? 'جاري رفع التوقيع...' : 'Uploading signature...';
  String get missingLookupIds => isArabic
      ? 'تعذر تأكيد المركبة بدون نتيجة البحث من الخادم.'
      : 'Vehicle confirmation needs a successful policy lookup.';
  String get missingEvidencePhoto => isArabic
      ? 'لا توجد صورة للرفع. أعد التقاط الصورة.'
      : 'No photo is available to upload. Please retake it.';
  String get validationError => isArabic
      ? 'تعذر تنفيذ الطلب. تحقق من البيانات وحاول مرة أخرى.'
      : 'The request could not be processed. Check the details and try again.';
  String get startClaimHint => isArabic
      ? 'بدء المطالبة سيبدأ معاينتك الميدانية.'
      : 'Starting the claim will begin your field inspection.';
  String get startFieldInspectionTitle =>
      isArabic ? 'بدء المعاينة الميدانية؟' : 'Start Field Inspection?';
  String get startInspectionExplain => isArabic
      ? 'بمجرد البدء، ستبدأ بتوثيق المركبة والحادث والموقع والأدلة.'
      : "Once you start, you'll begin documenting the vehicle, accident, location and evidence.";
  String get startInspection => isArabic ? 'بدء المعاينة' : 'Start Inspection';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get claimFieldLabel => isArabic ? 'المطالبة' : 'Claim';
  String get vehicleFieldLabel => isArabic ? 'المركبة' : 'Vehicle';
  String get claimNumberPrefix => isArabic ? 'مطالبة #' : 'Claim #';
  String get assignedDateLabel => isArabic ? 'تاريخ الإسناد:' : 'Assigned:';
  String get loadingClaimDetails =>
      isArabic ? 'جاري تحميل تفاصيل المطالبة...' : 'Loading claim details...';
  String get claimDetails => isArabic ? 'تفاصيل المطالبة' : 'Claim Details';
  String get createdDate => isArabic ? 'تاريخ الإنشاء' : 'Created date';
  String get startingClaim =>
      isArabic ? 'جاري بدء المطالبة...' : 'Starting claim...';
  String get claimStarted => isArabic
      ? 'تم بدء المطالبة وهي الآن قيد التنفيذ.'
      : 'The claim is now in progress.';
  String get cannotStartClaim => isArabic
      ? 'لا يمكن بدء هذه المطالبة في حالتها الحالية.'
      : 'This claim cannot be started in its current status.';
  String get unableToLoadClaim => isArabic
      ? 'تعذر تحميل تفاصيل المطالبة. حاول مرة أخرى.'
      : 'Unable to load claim details. Please try again.';
  String get claimNotFound => isArabic
      ? 'لم يتم العثور على المطالبة.'
      : 'The requested claim was not found.';
  String get sessionExpired => isArabic
      ? 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.'
      : 'Session expired. Please sign in again.';
  String get networkError =>
      isArabic ? 'تحقق من اتصال الإنترنت' : 'Check your internet connection.';
  String get serverError => isArabic
      ? 'حدث خطأ في الخادم، حاول لاحقاً'
      : 'A server error occurred. Please try again.';
  String get unexpectedError =>
      isArabic ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred.';
  String get forbidden => isArabic
      ? 'ليست لديك صلاحية لتنفيذ هذا الإجراء.'
      : 'You do not have permission to perform this action.';
  String get signOut => isArabic ? 'تسجيل الخروج' : 'Sign out';
  String get fieldAdjuster => isArabic ? 'معاين ميداني' : 'Field Adjuster';
  String get notAvailable => isArabic ? 'غير متوفر' : 'Not available';
  String get executionTitle => isArabic ? 'تنفيذ المطالبة' : 'Claim execution';
  String get executionBody => isArabic
      ? 'المطالبة قيد التنفيذ. خطوات المعاينة ستُضاف لاحقاً.'
      : 'This claim is in progress. Inspection steps will be added later.';
  String get inspectionProgress =>
      isArabic ? 'تقدم المعاينة' : 'Inspection Progress';
  String get currentStepLabel => isArabic ? 'الخطوة الحالية' : 'Current';
  String get completedStepHint => isArabic ? 'مكتملة' : 'Completed';
  String get remainingStepHint => isArabic ? 'متبقية' : 'Remaining';
  String get identifyVehicle =>
      isArabic ? 'تحديد هوية المركبة' : 'Vehicle Identification';
  String get identifyVehicleSubtitle => isArabic
      ? 'أكّد المركبة المسندة لهذه المطالبة.'
      : 'Confirm the vehicle assigned to this claim.';
  String get scanLicensePlate =>
      isArabic ? 'مسح لوحة المركبة' : 'Scan License Plate';
  String get enterPlateManually =>
      isArabic ? 'إدخال اللوحة يدوياً' : 'Enter Plate Manually';
  String get positionPlateInFrame => isArabic
      ? 'ضع لوحة المركبة داخل الإطار'
      : 'Position the license plate inside the frame';
  String get keepPlateVisible => isArabic
      ? 'أبقِ اللوحة ظاهرة وثابتة.'
      : 'Keep the plate visible and steady.';
  String get capturePlate =>
      isArabic ? 'التقاط اللوحة' : 'Capture license plate';
  String get toggleFlash => isArabic ? 'الفلاش' : 'Flash';
  String get gallery => isArabic ? 'المعرض' : 'Gallery';
  String get captureEvidence => isArabic ? 'التقاط الصورة' : 'Capture photo';
  String get cameraUnavailable => isArabic
      ? 'تعذر فتح الكاميرا. تحقق من الصلاحيات وحاول مرة أخرى.'
      : 'Unable to open the camera. Check permissions and try again.';
  String get plateDetected => isArabic ? 'تم رصد اللوحة' : 'Plate detected';
  String get verifyDetectedPlate => isArabic
      ? 'يرجى التحقق من الرقم المرصود قبل المتابعة.'
      : 'Please verify the detected number before continuing.';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get retake => isArabic ? 'إعادة الالتقاط' : 'Retake';
  String get enterLicensePlate =>
      isArabic ? 'أدخل رقم اللوحة' : 'Enter License Plate';
  String get enterLicensePlateSubtitle => isArabic
      ? 'اكتب رقم اللوحة كما يظهر تماماً على المركبة.'
      : 'Type the plate number exactly as shown on the vehicle.';
  String get licensePlateHint => 'ABC-1234';
  String get confirmPlate => isArabic ? 'تأكيد اللوحة' : 'Confirm Plate';
  String get validPlateFormat => isArabic ? 'التنسيق صحيح ✓' : 'Valid format ✓';
  String get invalidLicensePlate => isArabic
      ? 'يرجى إدخال رقم لوحة صالح.'
      : 'Please enter a valid license plate.';
  String get findingVehicle =>
      isArabic ? 'البحث عن المركبة' : 'Finding vehicle';
  String get checkingVehicleAndPolicy => isArabic
      ? 'جارٍ التحقق من معلومات المركبة والوثيقة...'
      : 'Checking vehicle and policy information...';
  String get lookupVehicleInformation =>
      isArabic ? 'معلومات المركبة' : 'Vehicle information';
  String get lookupCustomerInformation =>
      isArabic ? 'معلومات العميل' : 'Customer information';
  String get lookupPolicyInformation =>
      isArabic ? 'معلومات الوثيقة' : 'Policy information';
  String get vehicleInformation =>
      isArabic ? 'معلومات المركبة' : 'Vehicle Information';
  String get vehicleSection => isArabic ? 'المركبة' : 'Vehicle';
  String get customerSection => isArabic ? 'العميل' : 'Customer';
  String get policySection => isArabic ? 'الوثيقة' : 'Policy';
  String get licensePlateLabel => isArabic ? 'رقم اللوحة' : 'License Plate';
  String get confirmInformation =>
      isArabic ? 'تأكيد المعلومات' : 'Confirm Information';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get policyStatusActive => isArabic ? 'سارية' : 'ACTIVE';
  String get accidentDetails => isArabic ? 'تفاصيل الحادث' : 'Accident Details';
  String get accidentType => isArabic ? 'نوع الحادث' : 'Accident Type';
  String get accidentDate => isArabic ? 'التاريخ' : 'Date';
  String get accidentTime => isArabic ? 'الوقت' : 'Time';
  String get accidentDateHint => isArabic ? 'اختر التاريخ' : 'Select date';
  String get accidentTimeHint => isArabic ? 'اختر الوقت' : 'Select time';
  String get accidentDescription => isArabic ? 'الوصف' : 'Description';
  String get whatHappened => isArabic ? 'ماذا حدث؟' : 'What happened?';
  String get damageDescription => isArabic ? 'وصف الضرر' : 'Damage Description';
  String get describeVisibleDamage =>
      isArabic ? 'صف الضرر الظاهر.' : 'Describe the visible damage.';
  String get continueAction => isArabic ? 'متابعة' : 'Continue';
  String get almostThere => isArabic ? 'أوشكت على الانتهاء' : 'Almost there';
  String get completeMissingAccidentInfo => isArabic
      ? 'أكمل المعلومات الناقصة قبل المتابعة.'
      : 'Complete the missing information before continuing.';
  String get completeDetails =>
      isArabic ? 'إكمال التفاصيل' : 'Complete Details';
  String get captureAccidentLocation =>
      isArabic ? 'توثيق موقع الحادث' : 'Capture Accident Location';
  String get captureAccidentLocationSubtitle => isArabic
      ? 'نستخدم موقعك لتوثيق مكان معاينة الحادث بدقة.'
      : 'We use your location to accurately document where the accident was inspected.';
  String get gpsCoordinates => isArabic ? 'إحداثيات GPS' : 'GPS coordinates';
  String get locationAddress => isArabic ? 'العنوان' : 'Address';
  String get inspectionTimestamp =>
      isArabic ? 'وقت المعاينة' : 'Inspection timestamp';
  String get locationPrivacyNote => isArabic
      ? 'يُستخدم الموقع لهذه المعاينة فقط ولا يُشارك خارج المطالبة.'
      : 'Used only for this claim inspection. Location is not shared outside the file.';
  String get allowLocationAccess =>
      isArabic ? 'السماح بالوصول إلى الموقع' : 'Allow Location Access';
  String get notNow => isArabic ? 'ليس الآن' : 'Not Now';
  String get gettingYourLocation =>
      isArabic ? 'جاري تحديد موقعك...' : 'Getting your location...';
  String get searchingMostAccuratePosition => isArabic
      ? 'نبحث عن أدق موضع ممكن.'
      : 'Searching for the most accurate position.';
  String get gpsSignal => isArabic ? 'إشارة GPS' : 'GPS Signal';
  String get searchingEllipsis => isArabic ? 'جاري البحث...' : 'Searching...';
  String get locationAccuracy => isArabic ? 'الدقة' : 'Accuracy';
  String get calculatingEllipsis =>
      isArabic ? 'جاري الحساب...' : 'Calculating...';
  String get accidentLocation => isArabic ? 'موقع الحادث' : 'Accident Location';
  String get coordinates => isArabic ? 'الإحداثيات' : 'Coordinates';
  String get captured => isArabic ? 'وقت التوثيق' : 'Captured';
  String get locationAccurate => isArabic ? 'دقيق' : 'Accurate';
  String get refreshLocation => isArabic ? 'تحديث الموقع' : 'Refresh Location';
  String get confirmLocation => isArabic ? 'تأكيد الموقع' : 'Confirm Location';
  String get vehicleEvidence => isArabic ? 'أدلة المركبة' : 'Vehicle Evidence';
  String get vehicleEvidenceSubtitle => isArabic
      ? 'التقط جميع الصور المطلوبة قبل الإرسال.'
      : 'Capture all required photos before submitting.';
  String get addPhoto => isArabic ? 'إضافة صورة' : 'Add Photo';
  String get photoAdded => isArabic ? '✓ تمت إضافة الصورة' : '✓ Photo Added';
  String get readyToSave => isArabic ? 'جاهزة للحفظ' : 'Ready to save';
  String get usePhoto => isArabic ? 'استخدام الصورة' : 'Use Photo';
  String get capturedJustNow => isArabic ? 'التُقطت للتو' : 'Captured just now';
  String evidencePhotoAdded(EvidenceCategory category) => isArabic
      ? '✓ تمت إضافة صورة ${evidenceCategoryLabel(category)}'
      : '✓ ${evidenceCategoryLabel(category)} Photo Added';
  String get requiredEvidence => isArabic ? 'مطلوب' : 'Required';
  String get allRequiredPhotosCaptured => isArabic
      ? 'تم التقاط جميع الصور المطلوبة.'
      : 'All required photos have been captured.';
  String get evidenceCompleteHeadline =>
      isArabic ? 'اكتملت الأدلة' : 'Evidence complete';
  String get continueToDocuments =>
      isArabic ? 'متابعة إلى المستندات' : 'Continue to Documents';
  String get documentsTitle => isArabic ? 'المستندات' : 'Documents';
  String get documentsSubtitle => isArabic
      ? 'ارفع مستندات المطالبة المطلوبة.'
      : 'Upload the required claim documents.';
  String get upload => isArabic ? 'رفع' : 'Upload';
  String get documentUploaded => isArabic ? '✓ تم الرفع' : '✓ Uploaded';
  String get optionalDocument => isArabic ? 'اختياري' : 'Optional';
  String get camera => isArabic ? 'الكاميرا' : 'Camera';
  String get files => isArabic ? 'الملفات' : 'Files';
  String get uploadDocumentSource =>
      isArabic ? 'اختر مصدر الرفع' : 'Choose a source';
  String get reviewDocument => isArabic ? 'مراجعة المستند' : 'Review Document';
  String get capturedToday => isArabic ? 'التُقطت اليوم' : 'Captured today';
  String documentSaved(ClaimDocumentType type) => isArabic
      ? '✓ تم حفظ ${claimDocumentLabel(type)}'
      : '✓ ${claimDocumentLabel(type)} saved';
  String get customerConfirmation =>
      isArabic ? 'تأكيد العميل' : 'Customer Confirmation';
  String get customerSignatureSubtitle => isArabic
      ? 'اطلب من العميل المراجعة والتوقيع أدناه.'
      : 'Ask the customer to review and sign below.';
  String get customerSignaturePlaceholder =>
      isArabic ? 'توقيع العميل' : 'Customer signature';
  String get clearSignature => isArabic ? 'مسح' : 'Clear';
  String get confirmSignature =>
      isArabic ? 'تأكيد التوقيع' : 'Confirm Signature';
  String get signatureConsent => isArabic
      ? 'بالتوقيع، يؤكد العميل أنه راجع المعلومات والأدلة التي تم جمعها.'
      : 'By signing, the customer confirms that the collected information and evidence were reviewed.';
  String get reviewClaim => isArabic ? 'مراجعة المطالبة' : 'Review Claim';
  String get claimReadyToSubmit =>
      isArabic ? 'المطالبة جاهزة للتقديم' : 'Claim is ready to submit';
  String get submitClaim => isArabic ? 'تقديم المطالبة' : 'Submit Claim';
  String get checkingYourClaim =>
      isArabic ? 'جارٍ التحقق من مطالبتك' : 'Checking your claim';
  String get makingSureEverythingComplete => isArabic
      ? 'نتأكد من اكتمال كل المتطلبات.'
      : 'We\'re making sure everything required is complete.';
  String get requiredPhotos => isArabic ? 'الصور المطلوبة' : 'Required Photos';
  String get requiredDocuments =>
      isArabic ? 'المستندات المطلوبة' : 'Required Documents';
  String get everythingLooksGood =>
      isArabic ? 'كل شيء يبدو جيدًا' : 'Everything looks good';
  String get continueToSubmit =>
      isArabic ? 'المتابعة للتقديم' : 'Continue to Submit';
  String get submitClaimQuestion =>
      isArabic ? 'تقديم المطالبة؟' : 'Submit Claim?';
  String get submitClaimOfficerExplain => isArabic
      ? 'بعد التقديم، ستُرسل هذه المطالبة إلى مسؤول المطالبات للمراجعة.'
      : 'After submission, this claim will be sent to the Claims Officer for review.';
  String get submitClaimLockNote => isArabic
      ? 'لن تتمكن من تعديل المطالبة إلا إذا طُلب تصحيح.'
      : "You won't be able to edit the claim unless a correction is requested.";
  String get locationCaptured => isArabic ? 'تم التوثيق' : 'Captured';
  String get policyActiveShort => isArabic ? 'سارية' : 'Active';

  String get vehicleLinkUnavailable => isArabic
      ? 'لا توجد بيانات مركبة أو وثيقة مرتبطة بهذه اللوحة لربطها بالمطالبة.'
      : 'No vehicle, customer or policy record was returned for this plate, so nothing can be linked to the claim.';

  // --- Labels for fields returned by GET /claims/{id} -------------------
  // Each maps to a real key in the claim detail payload. Nothing here
  // is shown unless the backend actually sent a value for it.

  String get claimPolicy => isArabic ? 'الوثيقة' : 'POLICY';
  String get claimAccident => isArabic ? 'الحادث' : 'ACCIDENT';
  String get claimEvidence => isArabic ? 'الأدلة' : 'EVIDENCE';
  String get claimSignature => isArabic ? 'التوقيع' : 'SIGNATURE';
  String get claimActivity => isArabic ? 'سجل النشاط' : 'ACTIVITY';
  String get reportedIncident =>
      isArabic ? 'البلاغ الأولي' : 'REPORTED INCIDENT';
  String get capturedLocation =>
      isArabic ? 'الموقع الموثّق' : 'CAPTURED LOCATION';
  String get claimClosure => isArabic ? 'الإغلاق' : 'CLOSURE';

  // --- Claim location map ------------------------------------------------

  String get claimLocation => isArabic ? 'موقع المطالبة' : 'Claim Location';
  String get claimLocationSection =>
      isArabic ? 'موقع المطالبة' : 'CLAIM LOCATION';
  String get locationUnavailable =>
      isArabic ? 'الموقع غير متوفر' : 'Location unavailable';
  String get viewLargerMap => isArabic ? 'تكبير' : 'Expand';
  String get reportedPositionLabel =>
      isArabic ? 'الموقع المبلّغ عنه' : 'Reported position';
  String get capturedPositionLabel =>
      isArabic ? 'الموقع الموثّق ميدانياً' : 'Adjuster-captured position';

  String get policyNumberLabel => isArabic ? 'رقم الوثيقة' : 'Policy number';
  String get policyPeriodLabel => isArabic ? 'سريان الوثيقة' : 'Coverage';
  String get policyStatusFieldLabel => isArabic ? 'الحالة' : 'Status';
  String get priorityLabel => isArabic ? 'الأولوية' : 'Priority';
  String get incidentTypeLabel => isArabic ? 'نوع البلاغ' : 'Incident type';
  String get assignmentNotesLabel => isArabic ? 'ملاحظات الإسناد' : 'Notes';
  String get damageDescriptionLabel =>
      isArabic ? 'وصف الأضرار' : 'Damage description';
  String get customerPhoneLabel => isArabic ? 'الهاتف' : 'Phone';
  String get customerNameLabel => isArabic ? 'الاسم' : 'Name';
  String get plateNumberLabel => isArabic ? 'رقم اللوحة' : 'Plate number';
  String get makeModelLabel => isArabic ? 'الماركة والطراز' : 'Make & model';
  String get yearLabel => isArabic ? 'سنة الصنع' : 'Year';
  String get colorLabel => isArabic ? 'اللون' : 'Color';
  String get coordinatesLabel => isArabic ? 'الإحداثيات' : 'Coordinates';
  String get capturedAtLabel => isArabic ? 'وقت التوثيق' : 'Captured';
  String get createdByLabel => isArabic ? 'أنشأها' : 'Created by';
  String get createdAtLabel => isArabic ? 'تاريخ الإنشاء' : 'Created';
  String get closedByLabel => isArabic ? 'أغلقها' : 'Closed by';
  String get closedAtLabel => isArabic ? 'تاريخ الإغلاق' : 'Closed';
  String get closingNotesLabel =>
      isArabic ? 'ملاحظات الإغلاق' : 'Closing notes';
  String get decisionNotesLabel =>
      isArabic ? 'ملاحظات القرار' : 'Decision notes';
  String get uploadedByLabel => isArabic ? 'رفعها' : 'Uploaded by';

  String get noVehicleDetailsYet => isArabic
      ? 'لم يتم توثيق بيانات المركبة بعد.'
      : 'Vehicle details not recorded yet.';
  String get noAccidentDetailsYet => isArabic
      ? 'لم يتم توثيق تفاصيل الحادث بعد.'
      : 'Accident details not recorded yet.';
  String get noLocationCapturedYet =>
      isArabic ? 'لم يتم توثيق الموقع بعد.' : 'Location not captured yet.';
  String get noEvidenceUploadedYet =>
      isArabic ? 'لم يتم رفع أي صور بعد.' : 'No evidence photos uploaded yet.';
  String get noSignatureCapturedYet => isArabic
      ? 'لم يتم توقيع العميل بعد.'
      : 'Customer signature not captured yet.';
  String get noPolicyLinkedYet => isArabic
      ? 'لم يتم ربط وثيقة تأمين بعد.'
      : 'No policy linked to this claim yet.';
  String get evidenceImageUnavailable =>
      isArabic ? 'تعذّر تحميل الصورة' : 'Image unavailable';

  String evidencePhotoCount(int count) => isArabic
      ? (count == 1 ? 'صورة واحدة' : '$count صور')
      : (count == 1 ? '1 photo' : '$count photos');

  String statusTransitionLabel(String from, String to) => '$from -> $to';

  String reviewEvidenceCount(int completed, int total) =>
      isArabic ? '$completed / $total صور' : '$completed / $total photos';
  String reviewDocumentsCount(int completed, int total) => isArabic
      ? '$completed / $total مستندات'
      : '$completed / $total documents';
  String requiredDocumentsProgress(int completed, int total) => isArabic
      ? '$completed / $total مستندات مطلوبة'
      : '$completed / $total required documents';
  String claimDocumentLabel(ClaimDocumentType type) {
    switch (type) {
      case ClaimDocumentType.driverLicense:
        return isArabic ? 'رخصة القيادة' : 'Driver License';
      case ClaimDocumentType.nationalId:
        return isArabic ? 'الهوية الوطنية' : 'National ID';
      case ClaimDocumentType.policeReport:
        return isArabic ? 'تقرير الشرطة' : 'Police Report';
      case ClaimDocumentType.other:
        return isArabic ? 'أخرى' : 'Other';
    }
  }

  String documentSourceLabel(DocumentSource source) {
    switch (source) {
      case DocumentSource.camera:
        return camera;
      case DocumentSource.gallery:
        return gallery;
      case DocumentSource.files:
        return files;
    }
  }

  String requiredPhotosProgress(int completed, int total) => isArabic
      ? '$completed / $total صور مطلوبة'
      : '$completed / $total Required Photos';
  String evidenceCompleteItemLabel(EvidenceCategory category) {
    switch (category) {
      case EvidenceCategory.leftSide:
        return isArabic ? 'اليسار' : 'Left';
      case EvidenceCategory.rightSide:
        return isArabic ? 'اليمين' : 'Right';
      default:
        return evidenceCategoryLabel(category);
    }
  }

  String evidenceProgressCount(int completed, int total) =>
      isArabic ? '$completed / $total مكتملة' : '$completed / $total completed';
  String requiredPhotosRemaining(int remaining) => isArabic
      ? remaining == 1
            ? 'تبقى صورة واحدة مطلوبة.'
            : 'تبقى $remaining صور مطلوبة.'
      : remaining == 1
      ? '1 required photo remaining.'
      : '$remaining required photos remaining.';
  String evidenceCategoryLabel(EvidenceCategory category) {
    switch (category) {
      case EvidenceCategory.licensePlate:
        return licensePlateLabel;
      case EvidenceCategory.front:
        return isArabic ? 'الأمام' : 'Front';
      case EvidenceCategory.rear:
        return isArabic ? 'الخلف' : 'Rear';
      case EvidenceCategory.leftSide:
        return isArabic ? 'الجانب الأيسر' : 'Left Side';
      case EvidenceCategory.rightSide:
        return isArabic ? 'الجانب الأيمن' : 'Right Side';
      case EvidenceCategory.damageCloseUp:
        return isArabic ? 'ضرر عن قرب' : 'Damage Close-up';
      case EvidenceCategory.accidentScene:
        return isArabic ? 'موقع الحادث' : 'Accident Scene';
    }
  }

  String evidenceCameraPrompt(EvidenceCategory category) {
    switch (category) {
      case EvidenceCategory.licensePlate:
        return isArabic
            ? 'التقط لوحة المركبة بوضوح.'
            : 'Capture the license plate clearly.';
      case EvidenceCategory.front:
        return isArabic
            ? 'التقط مقدمة المركبة بوضوح.'
            : 'Capture the front of the vehicle clearly.';
      case EvidenceCategory.rear:
        return isArabic
            ? 'التقط مؤخرة المركبة بوضوح.'
            : 'Capture the rear of the vehicle clearly.';
      case EvidenceCategory.leftSide:
        return isArabic
            ? 'التقط الجانب الأيسر من المركبة بوضوح.'
            : 'Capture the left side of the vehicle clearly.';
      case EvidenceCategory.rightSide:
        return isArabic
            ? 'التقط الجانب الأيمن من المركبة بوضوح.'
            : 'Capture the right side of the vehicle clearly.';
      case EvidenceCategory.damageCloseUp:
        return isArabic
            ? 'التقط الضرر عن قرب بوضوح.'
            : 'Capture a close-up of the damage clearly.';
      case EvidenceCategory.accidentScene:
        return isArabic
            ? 'التقط موقع الحادث بوضوح.'
            : 'Capture the accident scene clearly.';
    }
  }

  String get evidenceVehicleAreaVisible => isArabic
      ? 'تأكد من ظهور منطقة المركبة بالكامل.'
      : 'Make sure the entire vehicle area is visible.';

  String evidenceCameraInstruction(EvidenceCategory category) {
    switch (category) {
      case EvidenceCategory.licensePlate:
        return isArabic
            ? 'تأكد من أن اللوحة كاملة وواضحة القراءة.'
            : 'Make sure the full plate is readable.';
      case EvidenceCategory.damageCloseUp:
        return isArabic
            ? 'تأكد من أن منطقة الضرر تملأ الإطار.'
            : 'Make sure the damaged area fills the frame.';
      case EvidenceCategory.accidentScene:
        return isArabic
            ? 'تأكد من ظهور موقع الحادث بالكامل.'
            : 'Make sure the full accident area is visible.';
      case EvidenceCategory.front:
      case EvidenceCategory.rear:
      case EvidenceCategory.leftSide:
      case EvidenceCategory.rightSide:
        return evidenceVehicleAreaVisible;
    }
  }

  String accidentChecklistLabel(AccidentField field) {
    switch (field) {
      case AccidentField.type:
        return accidentType;
      case AccidentField.date:
        return accidentDate;
      case AccidentField.time:
        return accidentTime;
      case AccidentField.description:
        return accidentDescription;
      case AccidentField.damage:
        return damageDescription;
    }
  }

  String accidentFieldHint(AccidentField field) {
    switch (field) {
      case AccidentField.type:
        return isArabic ? 'اختر نوع الاصطدام.' : 'Choose the collision type.';
      case AccidentField.date:
        return isArabic ? 'أكد تاريخ الحادث.' : 'Confirm the accident date.';
      case AccidentField.time:
        return isArabic ? 'أكد وقت الحادث.' : 'Confirm the accident time.';
      case AccidentField.description:
        return isArabic
            ? 'أضف وصفاً موجزاً لما حدث.'
            : 'Add a short description of what happened.';
      case AccidentField.damage:
        return isArabic
            ? 'صف الضرر الظاهر على المركبة.'
            : 'Note the visible damage on the vehicle.';
    }
  }

  String accidentTypeLabel(AccidentType type) {
    switch (type) {
      case AccidentType.collision:
        return isArabic ? 'اصطدام' : 'Collision';
      case AccidentType.rearEndCollision:
        return isArabic ? 'اصطدام خلفي' : 'Rear-end Collision';
      case AccidentType.sideImpact:
        return isArabic ? 'اصطدام جانبي' : 'Side Impact';
      case AccidentType.parkingDamage:
        return isArabic ? 'ضرر أثناء الوقوف' : 'Parking Damage';
      case AccidentType.other:
        return isArabic ? 'أخرى' : 'Other';
    }
  }

  String accidentFieldError(AccidentField field, AccidentFieldIssue issue) {
    switch (issue) {
      case AccidentFieldIssue.missing:
        switch (field) {
          case AccidentField.type:
            return isArabic
                ? 'يرجى اختيار نوع الحادث.'
                : 'Please select an accident type.';
          case AccidentField.date:
            return isArabic ? 'التاريخ مطلوب.' : 'Date is required.';
          case AccidentField.time:
            return isArabic ? 'الوقت مطلوب.' : 'Time is required.';
          case AccidentField.description:
            return isArabic
                ? 'يرجى وصف ما حدث.'
                : 'Please describe what happened.';
          case AccidentField.damage:
            return isArabic
                ? 'يرجى وصف الضرر الظاهر.'
                : 'Please describe the visible damage.';
        }
      case AccidentFieldIssue.inFuture:
        if (field == AccidentField.date) {
          return isArabic
              ? 'لا يمكن أن يكون التاريخ في المستقبل.'
              : 'Date cannot be in the future.';
        }
        return isArabic
            ? 'لا يمكن أن يكون الوقت في المستقبل.'
            : 'Time cannot be in the future.';
      case AccidentFieldIssue.tooShort:
        if (field == AccidentField.description) {
          return isArabic
              ? 'يرجى إضافة مزيد من التفاصيل.'
              : 'Please add a bit more detail.';
        }
        return isArabic
            ? 'يرجى إضافة مزيد من التفاصيل عن الضرر.'
            : 'Please add a bit more detail about the damage.';
    }
  }

  String vehicleColorLabel(String colorKey) {
    switch (colorKey.toLowerCase()) {
      case 'white':
        return isArabic ? 'أبيض' : 'White';
      default:
        return colorKey;
    }
  }

  /// Localises the raw `policy.status` the backend sends. `ACTIVE` is
  /// the only value observed so far; anything else is shown as the
  /// backend spelled it rather than mapped to an invented label.
  String? policyStatusLabel(String? rawStatus) {
    final value = rawStatus?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.toUpperCase() == 'ACTIVE') return policyStatusActive;
    return humanizeEnum(value);
  }

  String vehicleLookupItemLabel(VehicleLookupItem item) {
    switch (item) {
      case VehicleLookupItem.vehicle:
        return lookupVehicleInformation;
      case VehicleLookupItem.customer:
        return lookupCustomerInformation;
      case VehicleLookupItem.policy:
        return lookupPolicyInformation;
    }
  }

  String claimValidationItemLabel(ClaimValidationItem item) {
    switch (item) {
      case ClaimValidationItem.vehicle:
        return vehicleSection;
      case ClaimValidationItem.policy:
        return policySection;
      case ClaimValidationItem.accident:
        return inspectionStepLabel(InspectionStepId.accident);
      case ClaimValidationItem.location:
        return inspectionStepLabel(InspectionStepId.location);
      case ClaimValidationItem.photos:
        return requiredPhotos;
      case ClaimValidationItem.documents:
        return requiredDocuments;
      case ClaimValidationItem.signature:
        return inspectionStepLabel(InspectionStepId.signature);
    }
  }

  String inspectionStepIndicator(int step, int total) =>
      isArabic ? 'الخطوة $step من $total' : 'Step $step of $total';
  String get vehicleInformationCompleted =>
      isArabic ? 'تم إكمال معلومات المركبة.' : 'Vehicle information completed.';
  String get assignmentCompleted =>
      isArabic ? 'تم إكمال الإسناد.' : 'Assignment completed.';
  String get accidentCompleted =>
      isArabic ? 'تم إكمال توثيق الحادث.' : 'Accident information completed.';
  String get locationCompleted =>
      isArabic ? 'تم إكمال الموقع.' : 'Location information completed.';
  String get evidenceCompleted =>
      isArabic ? 'تم إكمال الأدلة.' : 'Evidence completed.';
  String get documentsCompleted =>
      isArabic ? 'تم إكمال المستندات.' : 'Documents completed.';
  String get signatureCompleted =>
      isArabic ? 'تم إكمال التوقيع.' : 'Signature completed.';
  String get reviewCompleted =>
      isArabic ? 'تم إكمال المراجعة.' : 'Review completed.';
  String get inspectionJustStarted => isArabic
      ? 'ابدأ بتحديد المركبة للمتابعة.'
      : 'Start with vehicle identification to continue.';

  String inspectionProgressCount(int completed, int total) => isArabic
      ? '$completed من $total مكتملة'
      : '$completed of $total completed';

  String inspectionStepLabel(InspectionStepId step) {
    switch (step) {
      case InspectionStepId.vehicle:
        return isArabic ? 'المركبة' : 'Vehicle';
      case InspectionStepId.accident:
        return isArabic ? 'الحادث' : 'Accident';
      case InspectionStepId.location:
        return isArabic ? 'الموقع' : 'Location';
      case InspectionStepId.evidence:
        return isArabic ? 'الأدلة' : 'Evidence';
      case InspectionStepId.documents:
        return isArabic ? 'المستندات' : 'Documents';
      case InspectionStepId.signature:
        return isArabic ? 'التوقيع' : 'Signature';
      case InspectionStepId.review:
        return isArabic ? 'المراجعة' : 'Review';
      case InspectionStepId.submission:
        return isArabic ? 'التقديم' : 'Submission';
    }
  }

  String inspectionStepCompletedMessage(InspectionStepId? step) {
    switch (step) {
      case InspectionStepId.vehicle:
        return vehicleInformationCompleted;
      case InspectionStepId.accident:
        return accidentCompleted;
      case InspectionStepId.location:
        return locationCompleted;
      case InspectionStepId.evidence:
        return evidenceCompleted;
      case InspectionStepId.documents:
        return documentsCompleted;
      case InspectionStepId.signature:
        return signatureCompleted;
      case InspectionStepId.review:
        return reviewCompleted;
      case InspectionStepId.submission:
        return claimSubmitted;
      case null:
        return inspectionJustStarted;
    }
  }

  String get homeTitle => isArabic ? 'الرئيسية' : 'Home';
  String get profileTitle => isArabic ? 'الملف الشخصي' : 'Profile';
  String get goodMorning => isArabic ? 'صباح الخير' : 'Good morning';
  String get goodAfternoon => isArabic ? 'مساء الخير' : 'Good afternoon';
  String get goodEvening => isArabic ? 'مساء الخير' : 'Good evening';
  String get homeSubtitle => isArabic
      ? 'هذا ما يحتاج انتباهك اليوم.'
      : 'Here’s what needs your attention today.';

  String statusLabel(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.newClaim:
        return statusNew;
      case ClaimStatus.pendingAcceptance:
        return statusPendingAcceptance;
      case ClaimStatus.assigned:
        return statusAssigned;
      case ClaimStatus.inProgress:
        return statusInProgress;
      case ClaimStatus.correctionRequired:
        return statusCorrection;
      case ClaimStatus.submitted:
        return statusSubmitted;
      case ClaimStatus.underReview:
        return statusUnderReview;
      case ClaimStatus.approved:
        return statusApproved;
      case ClaimStatus.rejected:
        return statusRejected;
      case ClaimStatus.closed:
        return statusClosed;
      case ClaimStatus.unknown:
        return statusUnknown;
    }
  }

  String statusBadgeLabel(ClaimStatus status) =>
      statusLabel(status).toUpperCase();

  String loginMessageFor(Failure failure) {
    if (failure is NetworkFailure) return networkError;
    if (failure is UnauthorizedFailure || failure is ValidationFailure) {
      return invalidCredentials;
    }
    if (failure is ForbiddenFailure) return forbidden;
    if (failure is ServerFailure) return serverError;
    return unexpectedError;
  }

  String startMessageFor(Failure failure) {
    if (failure is NotFoundFailure) {
      return isArabic
          ? 'تعذر بدء هذه المطالبة. يرجى المحاولة لاحقاً.'
          : 'Unable to start this claim. Please try again.';
    }
    if (failure is ValidationFailure) return cannotStartClaim;
    return messageFor(failure);
  }

  String messageFor(Failure failure) {
    if (failure is NetworkFailure) return networkError;
    if (failure is UnauthorizedFailure) return sessionExpired;
    if (failure is ForbiddenFailure) return forbidden;
    if (failure is NotFoundFailure) return claimNotFound;
    if (failure is ValidationFailure) {
      if (failure.message.contains('start') ||
          failure.message.contains('بدء')) {
        return cannotStartClaim;
      }
      return validationError;
    }
    if (failure is ServerFailure) return serverError;
    return unexpectedError;
  }
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
