import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/domain/accident_details.dart';
import 'package:insurflow/features/claims/domain/inspection_progress.dart';
import 'package:insurflow/features/claims/presentation/screens/location_permission_screen.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';
import 'package:insurflow/features/claims/presentation/widgets/accident_header_illustration.dart';
import 'package:insurflow/features/claims/presentation/widgets/accident_type_grid.dart';
import 'package:insurflow/features/claims/presentation/widgets/accident_validation_sheet.dart';
import 'package:insurflow/features/claims/presentation/widgets/field_work_input.dart';
import 'package:insurflow/features/claims/presentation/widgets/inspection_step_track.dart';

class AccidentDetailsArgs {
  const AccidentDetailsArgs({required this.claimId});

  final String claimId;
}

class AccidentDetailsScreen extends StatefulWidget {
  const AccidentDetailsScreen({
    super.key,
    required this.args,
    this.clock,
    this.onContinue,
  });

  final AccidentDetailsArgs args;
  final DateTime? clock;
  final ValueChanged<AccidentDetailsDraft>? onContinue;

  static const accidentWorkStep = 2;

  static Future<dynamic> open(BuildContext context, {required String claimId}) {
    return context.pushNamed(
      Routes.accidentDetailsScreen,
      arguments: AccidentDetailsArgs(claimId: claimId),
    );
  }

  @override
  State<AccidentDetailsScreen> createState() => _AccidentDetailsScreenState();
}

class _AccidentDetailsScreenState extends State<AccidentDetailsScreen> {
  final _description = TextEditingController();
  final _damage = TextEditingController();
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();
  final _descriptionFocus = FocusNode();
  final _damageFocus = FocusNode();
  final _scroll = ScrollController();
  final _typeKey = GlobalKey();
  final _dateKey = GlobalKey();
  final _timeKey = GlobalKey();
  final _descriptionKey = GlobalKey();
  final _damageKey = GlobalKey();

  late DateTime _now;
  AccidentType? _type;
  DateTime? _date;
  TimeOfDay? _time;
  var _attention = <AccidentField>{};

  @override
  void initState() {
    super.initState();
    _now = widget.clock ?? DateTime.now();
    _date = DateTime(_now.year, _now.month, _now.day);
    _time = TimeOfDay(hour: _now.hour, minute: _now.minute);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppStrings is not available in initState, and this also re-renders
    // the fields when the language changes.
    _syncPickerFields();
  }

  /// Re-renders the date and time fields in the active language.
  void _syncPickerFields([AppStrings? strings]) {
    final copy = strings ?? AppStrings.of(context);
    _dateText.text = _date == null
        ? ''
        : ClaimDateFormatter.dayMonthYear(copy, _date!);
    _timeText.text = _time == null
        ? ''
        : ClaimDateFormatter.timeOfDay(
            copy,
            hour: _time!.hour,
            minute: _time!.minute,
          );
  }

  @override
  void dispose() {
    _description.dispose();
    _damage.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _descriptionFocus.dispose();
    _damageFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  AccidentDetailsDraft get _draft => AccidentDetailsDraft(
    type: _type,
    occurredOn: _date,
    hour: _time?.hour,
    minute: _time?.minute,
    description: _description.text,
    damageDescription: _damage.text,
  );

  Map<AccidentField, AccidentFieldIssue> _validate() {
    return _draft.validate(now: widget.clock ?? DateTime.now());
  }

  void _refreshAttention() {
    if (_attention.isEmpty) return;
    final open = _validate();
    setState(() {
      _attention = _attention.where(open.containsKey).toSet();
    });
  }

  bool _needsAttention(AccidentField field) => _attention.contains(field);

  FocusNode? _focusFor(AccidentField field) {
    return switch (field) {
      AccidentField.description => _descriptionFocus,
      AccidentField.damage => _damageFocus,
      AccidentField.type || AccidentField.date || AccidentField.time => null,
    };
  }

  Future<void> _pickDate() async {
    final colors = context.colors;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? _now,
      firstDate: DateTime(_now.year - 2),
      lastDate: DateTime(_now.year, _now.month, _now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: colors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _syncPickerFields();
    });
    _refreshAttention();
  }

  Future<void> _pickTime() async {
    final colors = context.colors;
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.fromDateTime(_now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: colors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _syncPickerFields();
    });
    _refreshAttention();
  }

  Future<void> _continue() async {
    final now = widget.clock ?? DateTime.now();
    final issues = _draft.validate(now: now);
    if (issues.isEmpty) {
      setState(() => _attention = {});
      if (widget.onContinue != null) {
        widget.onContinue!(_draft);
        return;
      }
      InspectionProgress.complete(
        widget.args.claimId,
        InspectionStepId.accident,
      );
      await LocationPermissionScreen.open(
        context,
        claimId: widget.args.claimId,
      );
      return;
    }

    final focus = await AccidentValidationSheet.show(
      context,
      draft: _draft,
      issues: issues,
      now: now,
    );
    if (!mounted) return;
    setState(() => _attention = issues.keys.toSet());
    final target = focus ?? issues.keys.first;
    await _scrollTo(target);
    _focusFor(target)?.requestFocus();
  }

  Future<void> _scrollTo(AccidentField field) async {
    final key = switch (field) {
      AccidentField.type => _typeKey,
      AccidentField.date => _dateKey,
      AccidentField.time => _timeKey,
      AccidentField.description => _descriptionKey,
      AccidentField.damage => _damageKey,
    };
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 280),
      alignment: 0.08,
    );
  }

  Widget _guidedField({
    required GlobalKey key,
    required AccidentField field,
    required Widget child,
  }) {
    final warning = context.colors.warningColor;
    final attention = _needsAttention(field);

    return KeyedSubtree(
      key: key,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: attention ? warning.changeOpacity(0.06) : Colors.transparent,
          borderRadius: context.circularRadius(18),
          border: Border.all(
            color: attention ? warning.changeOpacity(0.28) : Colors.transparent,
          ),
        ),
        padding: attention
            ? context.spaceSymmetric(vertical: 10, horizontal: 10)
            : EdgeInsets.zero,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.cardColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey(widget.args.claimId),
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.backgroundColor,
          foregroundColor: colors.textPrimaryColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            strings.accidentDetails,
            style: context.font18Bold?.copyWith(
              color: colors.textPrimaryColor,
              fontWeight: FontWeightHelper.semiBold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.inspectionStepIndicator(
                    AccidentDetailsScreen.accidentWorkStep,
                    InspectionProgress.totalCount,
                  ),
                  style: context.font14Regular?.copyWith(
                    color: colors.primaryColor,
                    fontWeight: FontWeightHelper.medium,
                    letterSpacing: 0.2,
                  ),
                ),
                context.addVerticalSpace(6),
                const InspectionStepTrack(
                  step: AccidentDetailsScreen.accidentWorkStep,
                ),
                context.addVerticalSpace(8),
                const AccidentHeaderIllustration(),
                context.addVerticalSpace(8),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      _guidedField(
                        key: _typeKey,
                        field: AccidentField.type,
                        child: AccidentTypeGrid(
                          selected: _type,
                          attention: _needsAttention(AccidentField.type),
                          helperText: _needsAttention(AccidentField.type)
                              ? strings.accidentFieldHint(AccidentField.type)
                              : null,
                          onSelected: (type) {
                            setState(() => _type = type);
                            _refreshAttention();
                          },
                        ),
                      ),
                      context.addVerticalSpace(18),
                      _guidedField(
                        key: _dateKey,
                        field: AccidentField.date,
                        child: FieldWorkInput(
                          label: strings.accidentDate,
                          hint: strings.accidentDateHint,
                          required: true,
                          readOnly: true,
                          attention: _needsAttention(AccidentField.date),
                          helperText: _needsAttention(AccidentField.date)
                              ? strings.accidentFieldHint(AccidentField.date)
                              : null,
                          controller: _dateText,
                          prefixIcon: Icons.calendar_today_outlined,
                          onTap: _pickDate,
                        ),
                      ),
                      context.addVerticalSpace(16),
                      _guidedField(
                        key: _timeKey,
                        field: AccidentField.time,
                        child: FieldWorkInput(
                          label: strings.accidentTime,
                          hint: strings.accidentTimeHint,
                          required: true,
                          readOnly: true,
                          attention: _needsAttention(AccidentField.time),
                          helperText: _needsAttention(AccidentField.time)
                              ? strings.accidentFieldHint(AccidentField.time)
                              : null,
                          controller: _timeText,
                          prefixIcon: Icons.schedule_outlined,
                          onTap: _pickTime,
                        ),
                      ),
                      context.addVerticalSpace(16),
                      _guidedField(
                        key: _descriptionKey,
                        field: AccidentField.description,
                        child: FieldWorkInput(
                          key: const Key('accident-description'),
                          label: strings.accidentDescription,
                          hint: strings.whatHappened,
                          required: true,
                          controller: _description,
                          focusNode: _descriptionFocus,
                          minLines: 4,
                          maxLines: 8,
                          attention: _needsAttention(AccidentField.description),
                          helperText: _needsAttention(AccidentField.description)
                              ? strings.accidentFieldHint(
                                  AccidentField.description,
                                )
                              : null,
                          onChanged: (_) => _refreshAttention(),
                        ),
                      ),
                      context.addVerticalSpace(16),
                      _guidedField(
                        key: _damageKey,
                        field: AccidentField.damage,
                        child: FieldWorkInput(
                          key: const Key('accident-damage'),
                          label: strings.damageDescription,
                          hint: strings.describeVisibleDamage,
                          required: true,
                          controller: _damage,
                          focusNode: _damageFocus,
                          minLines: 4,
                          maxLines: 8,
                          attention: _needsAttention(AccidentField.damage),
                          helperText: _needsAttention(AccidentField.damage)
                              ? strings.accidentFieldHint(AccidentField.damage)
                              : null,
                          onChanged: (_) => _refreshAttention(),
                        ),
                      ),
                      context.addVerticalSpace(16),
                    ],
                  ),
                ),
                AppPrimaryButton(
                  label: strings.continueAction,
                  prominent: true,
                  onPressed: _continue,
                ),
                context.addVerticalSpace(8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
