// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/widgets/login_field.dart';

class CreateBooruLoginField extends StatefulWidget {
  const CreateBooruLoginField({
    super.key,
    required this.onChanged,
    required this.labelText,
    this.hintText,
    this.text,
  });

  final void Function(String value) onChanged;
  final String labelText;
  final String? hintText;
  final String? text;

  @override
  State<CreateBooruLoginField> createState() => _CreateBooruLoginFieldState();
}

class _CreateBooruLoginFieldState extends State<CreateBooruLoginField> {
  late var controller = TextEditingController(text: widget.text);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginField(
      controller: controller,
      validator: (p0) => null,
      labelText: widget.labelText,
      onChanged: widget.onChanged,
      hintText: widget.hintText,
    );
  }
}
