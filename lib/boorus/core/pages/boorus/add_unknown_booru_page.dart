// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class AddUnknownBooruPage extends ConsumerStatefulWidget {
  const AddUnknownBooruPage({
    super.key,
    this.setCurrentBooruOnSubmit = false,
    required this.url,
  });

  final bool setCurrentBooruOnSubmit;
  final String url;

  @override
  ConsumerState<AddUnknownBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends ConsumerState<AddUnknownBooruPage> {
  final loginController = TextEditingController();
  final apiKeyController = TextEditingController();
  final nameController = TextEditingController();
  late final urlController = TextEditingController(text: widget.url);

  @override
  void dispose() {
    loginController.dispose();
    apiKeyController.dispose();
    nameController.dispose();
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(booruEngineProvider);
    final revealApiKey = ref.watch(booruRevealKeyProvider);
    final allowSubmit = ref.watch(booruAllowSubmitProvider);
    final ratingFilter = ref.watch(booruRatingFilterProvider);

    return GestureDetector(
      onTap: () => context.focusScope.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Icons.close),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Text(
                  'booru.add_booru_source_title',
                  style: context.textTheme.headlineSmall!
                      .copyWith(fontWeight: FontWeight.w900),
                ).tr(),
              ),
              WarningContainer(
                  contentBuilder: (context) =>
                      const Text('booru.add_random_booru_warning').tr()),
              const SizedBox(height: 8),
              const Divider(
                thickness: 2,
                endIndent: 16,
                indent: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: ListTile(
                  title: const Text('booru.booru_engine_input_label').tr(),
                  trailing: OptionDropDownButton<BooruEngine?>(
                    value: engine,
                    onChanged: (value) {
                      ref.read(booruEngineProvider.notifier).state = value;
                    },
                    items: BooruEngine.values
                        .map((value) => DropdownMenuItem<BooruEngine>(
                              value: value,
                              child: Text(value.stringify()),
                            ))
                        .toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: LoginField(
                  validator: (p0) => null,
                  controller: nameController,
                  labelText: 'booru.config_name_label'.tr(),
                  onChanged: (value) =>
                      ref.read(booruConfigNameProvider.notifier).state = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: LoginField(
                  readOnly: true,
                  validator: (p0) => null,
                  controller: urlController,
                  labelText: 'booru.site_url_label'.tr(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoginField(
                      validator: (p0) => null,
                      controller: loginController,
                      labelText: 'booru.login_name_label'.tr(),
                      onChanged: (value) =>
                          ref.read(booruLoginProvider.notifier).state = value,
                    ),
                    const SizedBox(height: 16),
                    LoginField(
                      validator: (p0) => null,
                      obscureText: !revealApiKey,
                      controller: apiKeyController,
                      labelText: 'booru.password_api_key_label'.tr(),
                      onChanged: (value) =>
                          ref.read(booruApiKeyProvider.notifier).state = value,
                      suffixIcon: IconButton(
                        splashColor: Colors.transparent,
                        icon: revealApiKey
                            ? const FaIcon(
                                FontAwesomeIcons.solidEyeSlash,
                                size: 18,
                              )
                            : const FaIcon(
                                FontAwesomeIcons.solidEye,
                                size: 18,
                              ),
                        onPressed: () {
                          ref.read(booruRevealKeyProvider.notifier).state =
                              !revealApiKey;
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('booru.content_filtering_label').tr(),
                      trailing: OptionDropDownButton<BooruConfigRatingFilter>(
                        value: ratingFilter,
                        onChanged: (value) {
                          if (value == null) return;
                          ref.read(booruRatingFilterProvider.notifier).state =
                              value;
                        },
                        items: BooruConfigRatingFilter.values
                            .map((value) =>
                                DropdownMenuItem<BooruConfigRatingFilter>(
                                  value: value,
                                  child: Text(value.getFilterRatingTerm()),
                                ))
                            .toList(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: allowSubmit
                          ? () {
                              context.navigator.pop();
                              ref
                                  .read(booruConfigProvider.notifier)
                                  .addFromAddBooruConfig(
                                    newConfig: ref.read(
                                        newbooruConfigProvider(widget.url)),
                                    setAsCurrent:
                                        widget.setCurrentBooruOnSubmit,
                                  );
                            }
                          : null,
                      child: const Text('booru.config_booru_confirm').tr(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
