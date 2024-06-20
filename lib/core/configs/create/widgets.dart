// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/option_dropdown_button.dart';

class CreateBooruApiKeyField extends StatefulWidget {
  const CreateBooruApiKeyField({
    super.key,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.text,
    this.controller,
  });

  final void Function(String value)? onChanged;
  final String? text;
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;

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
        validator: (p0) => null,
        autofillHints: const [
          AutofillHints.password,
        ],
        obscureText: !revealKey,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.labelText ?? 'booru.password_api_key_label'.tr(),
          hintText: widget.hintText,
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

class CreateBooruConfigNameField extends StatefulWidget {
  const CreateBooruConfigNameField({
    super.key,
    required this.onChanged,
    this.text,
  });

  final void Function(String value) onChanged;
  final String? text;

  @override
  State<CreateBooruConfigNameField> createState() =>
      _CreateBooruConfigNameFieldState();
}

class _CreateBooruConfigNameFieldState
    extends State<CreateBooruConfigNameField> {
  late var controller = TextEditingController(text: widget.text);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: BooruTextFormField(
        controller: controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'A label to identify this profile',
          labelText: 'booru.config_name_label'.tr(),
        ),
      ),
    );
  }
}

class CreateBooruHideDeletedSwitch extends StatelessWidget {
  const CreateBooruHideDeletedSwitch({
    super.key,
    required this.onChanged,
    this.value,
    this.subtitle,
  });

  final void Function(bool value) onChanged;
  final Widget? subtitle;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('booru.hide_deleted_label').tr(),
      value: value ?? false,
      onChanged: onChanged,
      subtitle: subtitle,
    );
  }
}

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

class CreateBooruImageDetailsResolutionOptionTile<T> extends StatelessWidget {
  const CreateBooruImageDetailsResolutionOptionTile({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final List<String> items;
  final String? value;
  final void Function(String? value) onChanged;

  @override
  Widget build(BuildContext context) {
    // set to Auto when value is null or empty
    final item = value?.isNotEmpty == true ? value : 'Auto';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: const Text("Details page's image resolution"),
      subtitle: const Text(
        'Higher resolution will take longer to load.',
      ),
      trailing: OptionDropDownButton(
        alignment: AlignmentDirectional.centerStart,
        value: item,
        onChanged: (value) => onChanged(value),
        items: items
            .append('Auto')
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.sentenceCase),
                ))
            .toList(),
      ),
    );
  }
}

class CreateBooruGeneralPostDetailsResolutionOptionTile
    extends StatelessWidget {
  const CreateBooruGeneralPostDetailsResolutionOptionTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final void Function(String? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return CreateBooruImageDetailsResolutionOptionTile(
      value: value,
      items: GeneralPostQualityType.values.map((e) => e.stringify()).toList(),
      onChanged: (value) => onChanged(value),
    );
  }
}

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

class CreateBooruSubmitButton extends StatelessWidget {
  const CreateBooruSubmitButton({
    super.key,
    required this.onSubmit,
    this.backgroundColor,
    this.child,
  });

  final void Function()? onSubmit;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
      onPressed: onSubmit,
      child: child ?? const Text('Save'),
    );
  }
}
