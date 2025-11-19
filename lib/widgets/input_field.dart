import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final IconData? prefixIcon;

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        ),
      ),
    );
  }
}
