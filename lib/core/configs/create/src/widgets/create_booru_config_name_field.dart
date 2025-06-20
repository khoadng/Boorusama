// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../widgets/booru_text_form_field.dart';
import '../providers/providers.dart';

class BooruConfigNameField extends ConsumerWidget {
  const BooruConfigNameField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);

    return CreateBooruConfigNameField(
      text:
          ref.watch(editBooruConfigProvider(id).select((value) => value.name)),
      onChanged: (value) => ref.editNotifier.updateName(value),
    );
  }
}

class CreateBooruConfigNameField extends StatefulWidget {
  const CreateBooruConfigNameField({
    required this.onChanged,
    super.key,
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
