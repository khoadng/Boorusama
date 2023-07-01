// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/login_field.dart';

class CreateBooruPasswordField extends StatefulWidget {
  const CreateBooruPasswordField({
    super.key,
    required this.onChanged,
    this.readOnly = false,
    this.text,
  });

  final void Function(String value) onChanged;
  final bool readOnly;
  final String? text;

  @override
  State<CreateBooruPasswordField> createState() =>
      _CreateBooruPasswordFieldState();
}

class _CreateBooruPasswordFieldState extends State<CreateBooruPasswordField> {
  var revealKey = false;
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
      readOnly: widget.readOnly,
      validator: (p0) => null,
      obscureText: !revealKey,
      labelText: widget.readOnly
          ? 'booru.password_hashed_label'.tr()
          : 'booru.password_label'.tr(),
      onChanged: widget.onChanged,
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
    );
  }
}
