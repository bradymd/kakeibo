import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakeibo/theme/app_colors.dart';

class CurrencyInput extends StatelessWidget {
  const CurrencyInput({
    super.key,
    required this.controller,
    required this.currencySymbol,
    this.label,
    this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currencySymbol;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? '0.00',
        prefixText: '$currencySymbol ',
        prefixStyle: const TextStyle(
          color: AppColors.hotPink,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
