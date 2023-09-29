// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/login_field.dart';

class CreateBooruSiteUrlField extends StatefulWidget {
  const CreateBooruSiteUrlField({
    super.key,
    this.text,
  });

  final String? text;

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
    return LoginField(
      readOnly: true,
      validator: (p0) => null,
      controller: urlController,
      labelText: 'booru.site_url_label'.tr(),
    );
  }
}
