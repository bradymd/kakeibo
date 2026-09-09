import 'package:flutter/services.dart';

/// Restricts a money-amount TextField to digits and a decimal point.
///
/// `keyboardType: TextInputType.numberWithOptions(decimal: true)` alone
/// only selects which on-screen keyboard is shown -- it doesn't stop a
/// physical/desktop keyboard, IME, or paste from entering letters. A stray
/// second '.' is left unfiltered here (a real edge case, but harmless:
/// every amount field's save-guard already goes through
/// `double.tryParse`, which simply rejects a malformed string rather than
/// crashing).
final currencyInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
];
