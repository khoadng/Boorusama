// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../widgets/booru_text_form_field.dart';

class CreateBooruApiKeyField extends StatefulWidget {
  const CreateBooruApiKeyField({
    super.key,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.text,
    this.controller,
    this.validator,
    this.autovalidateMode,
  });

  final void Function(String value)? onChanged;
  final String? text;
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  State<CreateBooruApiKeyField> createState() => _CreateBooruApiKeyFieldState();
}

class _CreateBooruApiKeyFieldState extends State<CreateBooruApiKeyField> {
  var revealKey = false;
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
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
        autofillHints: const [
          AutofillHints.password,
        ],
        obscureText: !revealKey,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.labelText ?? 'booru.password_api_key_label'.tr(),
          hintText: widget.hintText,
          errorMaxLines: 2,
          suffixIcon: IconButton(
            splashColor: Colors.transparent,
            icon: revealKey
                ? const FaIcon(
                    FontAwesomeIcons.solidEyeSlash,
                    size: 18,
                  )
                : const FaIcon(
                    FontAwesomeIcons.solidEye,
                    size: 18,
                  ),
            onPressed: () => setState(() => revealKey = !revealKey),
          ),
        ),
      ),
    );
  }
}
