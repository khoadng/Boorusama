import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  const LoginField({
    Key? key,
    required this.validator,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  }) : super(key: key);

  final TextEditingController controller;
  final String? Function(String?) validator;
  final Widget? suffixIcon;
  final String labelText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: obscureText,
      validator: validator,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
        labelText: labelText,
      ),
    );
  }
}
