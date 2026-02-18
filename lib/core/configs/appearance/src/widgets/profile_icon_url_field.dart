// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../config_widgets/website_logo.dart';
import '../../../../widgets/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';

class ProfileIconUrlField extends ConsumerStatefulWidget {
  const ProfileIconUrlField({super.key});

  @override
  ConsumerState<ProfileIconUrlField> createState() =>
      _ProfileIconUrlFieldState();
}

class _ProfileIconUrlFieldState extends ConsumerState<ProfileIconUrlField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final id = ref.read(editBooruConfigIdProvider);
    final currentUrl = ref.read(
      editBooruConfigProvider(id).select(
        (value) => value.profileIconTyped?.url,
      ),
    );
    _controller = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(initialBooruConfigProvider);
    final id = ref.watch(editBooruConfigIdProvider);
    final customUrl = ref.watch(
      editBooruConfigProvider(id).select(
        (value) => value.profileIconTyped?.url,
      ),
    );
    final hasCustomIcon = customUrl != null && customUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Icon',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ConfigAwareWebsiteLogo.fromConfig(
                      config.auth,
                      customIconUrl: customUrl,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                hasCustomIcon ? 'Custom' : 'Default',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BooruTextFormField(
            controller: _controller,
            onChanged: (value) {
              final url = value.trim();
              ref.editNotifier.updateProfileIcon(
                url.isEmpty ? null : ProfileIconConfigs(url: url),
              );
            },
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Icon URL',
              hintText: 'https://example.com/icon.png',
            ),
          ),
        ],
      ),
    );
  }
}
