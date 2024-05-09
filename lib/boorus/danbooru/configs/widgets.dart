// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_hide_deleted_switch.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
import 'package:boorusama/core/scaffolds/create_booru_config_scaffold2.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'providers.dart';

class DanbooruApiKeyField extends ConsumerWidget {
  const DanbooruApiKeyField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKey =
        ref.watch(authConfigDataProvider.select((value) => value.apiKey));

    void updateApiKey(String value) {
      final auth = ref.read(authConfigDataProvider);
      ref.updateAuthConfigData(auth.copyWith(apiKey: value));
    }

    return CreateBooruApiKeyField(
      text: apiKey,
      hintText: 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
      onChanged: updateApiKey,
    );
  }
}

class DanbooruLoginField extends ConsumerWidget {
  const DanbooruLoginField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login =
        ref.watch(authConfigDataProvider.select((value) => value.login));

    void updateLogin(String value) {
      final auth = ref.read(authConfigDataProvider);
      ref.updateAuthConfigData(auth.copyWith(login: value));
    }

    return CreateBooruLoginField(
      text: login,
      labelText: 'booru.login_name_label'.tr(),
      hintText: 'e.g: my_login',
      onChanged: updateLogin,
    );
  }
}

class DanbooruHideDeletedSwitch extends ConsumerWidget {
  const DanbooruHideDeletedSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final hideDeleted = ref.watch(hideDeletedProvider(config));

    return CreateBooruHideDeletedSwitch(
      value: hideDeleted,
      onChanged: (value) =>
          ref.read(hideDeletedProvider(config).notifier).state = value,
      subtitle: const Text(
        'Hide low-quality images, some decent ones might also be hidden.',
      ),
    );
  }
}

class DanbooruImageDetailsQualityProvider extends ConsumerWidget {
  const DanbooruImageDetailsQualityProvider({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final imageDetailsQuality = ref.watch(imageDetailsQualityProvider(config));

    return CreateBooruImageDetailsResolutionOptionTile(
      value: imageDetailsQuality,
      items: PostQualityType.values.map((e) => e.stringify()).toList(),
      onChanged: (value) =>
          ref.read(imageDetailsQualityProvider(config).notifier).state = value,
    );
  }
}
