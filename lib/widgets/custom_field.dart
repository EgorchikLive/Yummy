import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final label;
  final String hintText;
  final TextEditingController? controller;
  final bool isObscureText;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      decoration: InputDecoration(
        label: label,
        hintText: hintText,
      ),
      validator: (val) {
        if (val!.isEmpty) {
          return "$hintText пропущено!";
        }
        return null;
      },
      obscureText: isObscureText,
    );
  }
}
