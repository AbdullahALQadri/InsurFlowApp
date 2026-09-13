import 'package:flutter/services.dart';
import 'package:insurflow/features/claims/domain/license_plate_format.dart';

class LicensePlateInputFormatter extends TextInputFormatter {
  const LicensePlateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = LicensePlateFormat.display(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
