// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../../create/providers.dart';
import '../types/media_host_override.dart';

class MediaHostOverridesSection extends ConsumerWidget {
  const MediaHostOverridesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(editBooruConfigNetworkProvider);
    final t = context.t.booru.network.media_hosts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KurumiSwitchListTile(
          contentPadding: const EdgeInsets.only(left: 4),
          title: Text(t.title),
          subtitle: Text(t.description),
          value:
              settings.mediaHostOverrides.isNotEmpty &&
              settings.mediaHostOverridesEnabled,
          onChanged: settings.mediaHostOverrides.isEmpty
              ? null
              : (enabled) => ref.editNotifier.updateNetworkSettings(
                  settings.copyWith(
                    mediaHostOverridesEnabled: enabled,
                  ),
                ),
        ),
        for (final rule in settings.mediaHostOverrides)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 4),
            title: Text(rule.from),
            subtitle: Text(rule.to),
            trailing: IconButton(
              tooltip: context.t.generic.action.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.editNotifier.updateNetworkSettings(
                settings.copyWith(
                  mediaHostOverrides: [
                    ...settings.mediaHostOverrides.where(
                      (value) => value != rule,
                    ),
                  ],
                ),
              ),
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(t.add),
            onPressed: () async {
              final rule =
                  await Kurumi.showAdaptiveBottomSheet<MediaHostOverride>(
                    context,
                    settings: const RouteSettings(name: 'media_host_override'),
                    builder: (_) =>
                        _HostSheet(existing: settings.mediaHostOverrides),
                  );
              if (rule == null || !context.mounted) return;
              ref.editNotifier.updateNetworkSettings(
                settings.copyWith(
                  mediaHostOverrides: [...settings.mediaHostOverrides, rule],
                  mediaHostOverridesEnabled: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HostSheet extends StatefulWidget {
  const _HostSheet({required this.existing});
  final List<MediaHostOverride> existing;

  @override
  State<_HostSheet> createState() => _HostSheetState();
}

class _HostSheetState extends State<_HostSheet> {
  final _form = GlobalKey<FormState>();
  final _from = TextEditingController();
  final _to = TextEditingController();

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  String? _validate(String? value, {required bool source}) {
    final t = context.t.booru.network.media_hosts;
    try {
      final host = MediaHostOverride.normalizeHost(value ?? '');
      if (source && widget.existing.any((rule) => rule.from == host)) {
        return t.duplicate_host;
      }
      if (!source && host == _from.text.trim().toLowerCase()) {
        return t.same_host;
      }
      return null;
    } on FormatException {
      return t.invalid_host;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.booru.network.media_hosts;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: Kurumi.themeOf(context).colorScheme.surfaceContainerLow,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            controller: ModalScrollController.of(context),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.add,
                    style: Kurumi.themeOf(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  KurumiTextFormField(
                    controller: _from,
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(labelText: t.from),
                    validator: (value) => _validate(value, source: true),
                  ),
                  const SizedBox(height: 12),
                  KurumiTextFormField(
                    controller: _to,
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(labelText: t.to),
                    validator: (value) => _validate(value, source: false),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (_form.currentState!.validate()) {
                        Navigator.pop(
                          context,
                          MediaHostOverride(from: _from.text, to: _to.text),
                        );
                      }
                    },
                    child: Text(context.t.generic.action.add),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.t.generic.action.cancel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
