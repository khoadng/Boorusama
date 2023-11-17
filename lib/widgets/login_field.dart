// Flutter imports:
import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  const LoginField({
    super.key,
    required this.validator,
    this.controller,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.hintText,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? Function(String?) validator;
  final Widget? suffixIcon;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String? hintText;
  final void Function(String value)? onSubmitted;

  final bool autofocus;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      readOnly: readOnly,
      onChanged: onChanged,
      obscureText: obscureText,
      validator: validator,
      controller: controller,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: suffixIcon,
        labelText: labelText,
      ),
    );
  }
}
