// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/login_field.dart';

class CreateBooruApiKeyField extends StatefulWidget {
  const CreateBooruApiKeyField({
    super.key,
    required this.onChanged,
    this.text,
  });

  final void Function(String value) onChanged;
  final String? text;

  @override
  State<CreateBooruApiKeyField> createState() => _CreateBooruApiKeyFieldState();
}

class _CreateBooruApiKeyFieldState extends State<CreateBooruApiKeyField> {
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
      validator: (p0) => null,
      obscureText: !revealKey,
      labelText: 'booru.password_api_key_label'.tr(),
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
