// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../widgets/booru_text_form_field.dart';

class CreateBooruSiteUrlField extends StatefulWidget {
  const CreateBooruSiteUrlField({
    super.key,
    this.text,
    this.onChanged,
  });

  final String? text;
  final void Function(String value)? onChanged;

  @override
  State<CreateBooruSiteUrlField> createState() =>
      _CreateBooruSiteUrlFieldState();
}

class _CreateBooruSiteUrlFieldState extends State<CreateBooruSiteUrlField> {
  late final urlController = TextEditingController(text: widget.text);

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: BooruTextFormField(
        readOnly: widget.onChanged == null,
        autocorrect: false,
        keyboardType: TextInputType.url,
        autofillHints: const [
          AutofillHints.url,
        ],
        validator: (p0) => null,
        controller: urlController,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: 'booru.site_url_label'.tr(),
        ),
      ),
    );
  }
}
