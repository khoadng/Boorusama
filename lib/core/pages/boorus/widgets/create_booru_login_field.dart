// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';

class CreateBooruLoginField extends StatefulWidget {
  const CreateBooruLoginField({
    super.key,
    this.onChanged,
    required this.labelText,
    this.hintText,
    this.text,
    this.controller,
  });

  final void Function(String value)? onChanged;
  final String labelText;
  final String? hintText;
  final String? text;
  final TextEditingController? controller;

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
        validator: (p0) => null,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
        ),
      ),
    );
  }
}
