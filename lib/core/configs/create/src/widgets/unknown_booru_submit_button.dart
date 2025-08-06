// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/booru/booru.dart';
import '../../../../theme.dart';
import '../../../config/types.dart';
import '../../../manage/providers.dart';
import '../providers/internal_providers.dart';
import '../providers/providers.dart';
import '../types/utils.dart';
import 'booru_config_data_provider.dart';
import 'create_booru_submit_button.dart';

bool _defaultValidate(AuthConfigData auth) {
  return auth.isValid;
}

class UnknownBooruSubmitButton extends ConsumerWidget {
  const UnknownBooruSubmitButton({
    super.key,
    this.validate,
  });

  final bool Function(AuthConfigData auth)? validate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(
      editBooruConfigProvider(
        editId,
      ).select((value) => AuthConfigData.fromConfig(value)),
    );
    final configName = ref.watch(
      editBooruConfigProvider(editId).select((value) => value.name),
    );
    final url = ref.watch(
      editBooruConfigProvider(editId).select((value) => value.url),
    );
    final engine = ref.watch(booruEngineProvider);
    final effectiveValidate = validate ?? _defaultValidate;

    final isValid =
        engine != null &&
        url.isNotEmpty &&
        effectiveValidate(auth) &&
        configName.isNotEmpty;

    return ref
        .watch(validateConfigProvider)
        .when(
          data: (value) => value != null
              ? BooruConfigDataProvider(
                  builder: (data) => CreateBooruSubmitButton(
                    fill: true,
                    backgroundColor: value ? Colors.green : null,
                    onSubmit: isValid
                        ? () {
                            ref
                                .read(booruConfigProvider.notifier)
                                .addOrUpdate(
                                  id: editId,
                                  newConfig: data.copyWith(
                                    booruIdHint: () => engine.id,
                                  ),
                                  initialData: config,
                                );

                            Navigator.of(context).pop();
                          }
                        : null,
                    child: value
                        ? Text(context.t.booru.config_booru_confirm)
                        : Text(context.t.generic.action.verify),
                  ),
                )
              : _buildVerifyButton(context, isValid, ref, engine, url, auth),
          loading: () => CreateBooruSubmitButton(
            fill: true,
            backgroundColor: Theme.of(context).colorScheme.hintColor,
            onSubmit: null,
            child: const Center(
              child: SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (err, _) => _buildVerifyButton(
            context,
            isValid,
            ref,
            engine,
            url,
            auth,
            forceRefresh: true,
          ),
        );
  }

  Widget _buildVerifyButton(
    BuildContext context,
    bool isValid,
    WidgetRef ref,
    BooruType? engine,
    String? url,
    AuthConfigData auth, {
    bool forceRefresh = false,
  }) {
    return CreateBooruSubmitButton(
      fill: true,
      onSubmit: isValid && engine != null
          ? () {
              final notifier = ref.read(
                targetConfigToValidateProvider.notifier,
              );

              if (forceRefresh) {
                notifier.state = null;
              }

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                notifier.state =
                    BooruConfig.defaultConfig(
                          booruType: engine,
                          url: url!,
                          customDownloadFileNameFormat: null,
                        )
                        .copyWith(
                          login: auth.login,
                          apiKey: auth.apiKey,
                        )
                        .auth;
              });
            }
          : null,
      child: Text(context.t.generic.action.verify),
    );
  }
}
