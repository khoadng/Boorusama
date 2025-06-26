// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/booru_text_form_field.dart';

class CreateBooruLoginField extends StatefulWidget {
  const CreateBooruLoginField({
    required this.labelText,
    super.key,
    this.onChanged,
    this.hintText,
    this.text,
    this.controller,
    this.validator,
    this.autovalidateMode,
  });

  final void Function(String value)? onChanged;
  final String labelText;
  final String? hintText;
  final String? text;
  final TextEditingController? controller;

  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  State<CreateBooruLoginField> createState() => _CreateBooruLoginFieldState();
}

class _CreateBooruLoginFieldState extends State<CreateBooruLoginField> {
  late var controller =
      widget.controller ?? TextEditingController(text: widget.text);

  @override
  void dispose() {
    super.dispose();
    if (widget.controller == null) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: BooruTextFormField(
        controller: controller,
        autocorrect: false,
        autofillHints: const [
          AutofillHints.username,
          AutofillHints.email,
        ],
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
        ),
      ),
    );
  }
}
