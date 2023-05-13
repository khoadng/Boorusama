// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/login_field.dart';
import 'package:boorusama/core/ui/option_dropdown_button.dart';
import 'package:boorusama/core/ui/warning_container.dart';

class ConfigBooruPage extends ConsumerStatefulWidget {
  const ConfigBooruPage({
    super.key,
    required this.arg,
    this.setCurrentBooruOnSubmit = false,
  });

  final AddOrUpdateBooruArg arg;
  final bool setCurrentBooruOnSubmit;

  @override
  ConsumerState<ConfigBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends ConsumerState<ConfigBooruPage>
    with AddOrUpdateBooruNotifierMixin {
  final loginController = TextEditingController();
  final apiKeyController = TextEditingController();
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  final _engine = ValueNotifier<BooruEngine?>(null);

  @override
  AddOrUpdateBooruArg get arg => widget.arg;

  @override
  void initState() {
    super.initState();
    urlController.text = ref.read(addOrUpdateBooruProvider(arg)).url;
    loginController.text = ref.read(addOrUpdateBooruProvider(arg)).login;
    apiKeyController.text = ref.read(addOrUpdateBooruProvider(arg)).apiKey;
    nameController.text = ref.read(addOrUpdateBooruProvider(arg)).configName;
  }

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
    final state = ref.watch(addOrUpdateBooruProvider(arg));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: Navigator.of(context).pop,
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
                  'Add a source, leave the login details empty to be anonymous',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              !state.unverifiedBooru
                  ? Card(
                      child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(state.selectedBooru.booruType.stringify()),
                    ))
                  : WarningContainer(
                      contentBuilder: (context) => const Text(
                          'This booru is not offically supported yet. It probally won\'t work.')),
              const SizedBox(height: 8),
              const Divider(
                thickness: 2,
                endIndent: 16,
                indent: 16,
              ),
              state.unverifiedBooru
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: const Text('Booru engine (*)'),
                        trailing: ValueListenableBuilder<BooruEngine?>(
                          valueListenable: _engine,
                          builder: (_, engine, __) =>
                              OptionDropDownButton<BooruEngine?>(
                            value: engine,
                            onChanged: (value) {
                              _engine.value = value;
                              changeBooruEngine(engine);
                            },
                            items: BooruEngine.values
                                .map((value) => DropdownMenuItem<BooruEngine>(
                                      value: value,
                                      child: Text(value.name.sentenceCase),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: LoginField(
                  validator: (p0) => null,
                  controller: nameController,
                  labelText: 'Config Name (*)',
                  onChanged: changeConfigName,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: LoginField(
                  validator: (p0) => null,
                  controller: urlController,
                  labelText: 'Site URL',
                  onChanged: changeUrl,
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
                      labelText: 'Login',
                      onChanged: changeLogin,
                    ),
                    const SizedBox(height: 16),
                    LoginField(
                      readOnly: switch (arg) {
                        UpdateConfig _ => state.selectedBooru.loginType ==
                            LoginType.loginAndPasswordHashed,
                        _ => false,
                      },
                      validator: (p0) => null,
                      obscureText: !state.revealKey,
                      controller: apiKeyController,
                      labelText: state.selectedBooru.loginType ==
                              LoginType.loginAndApiKey
                          ? 'API key'
                          : switch (arg) {
                              UpdateConfig _ => 'Password Hashed (readonly)',
                              _ => 'Password',
                            },
                      onChanged: changeApiKey,
                      suffixIcon: IconButton(
                        splashColor: Colors.transparent,
                        icon: state.revealKey
                            ? const FaIcon(
                                FontAwesomeIcons.solidEyeSlash,
                                size: 18,
                              )
                            : const FaIcon(
                                FontAwesomeIcons.solidEye,
                                size: 18,
                              ),
                        onPressed: toggleApiKey,
                      ),
                    ),
                    if (state.supportRatingFilter())
                      ListTile(
                        title: const Text('Content filtering'),
                        trailing: OptionDropDownButton<BooruConfigRatingFilter>(
                          value: state.ratingFilter,
                          onChanged: changeRatingFilter,
                          items: BooruConfigRatingFilter.values
                              .map((value) =>
                                  DropdownMenuItem<BooruConfigRatingFilter>(
                                    value: value,
                                    child: Text(value.getFilterRatingTerm()),
                                  ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (state.supportHideDeleted())
                      SwitchListTile.adaptive(
                        title: const Text('Hide deleted posts'),
                        value: state.deletedItemBehavior ==
                            BooruConfigDeletedItemBehavior.hide,
                        onChanged: (_) => toggleDeleted(),
                      ),
                    ElevatedButton(
                      onPressed: state.allowSubmit()
                          ? () {
                              Navigator.of(context).pop();
                              submit(
                                  setCurrentBooruOnSubmit:
                                      widget.setCurrentBooruOnSubmit);
                            }
                          : null,
                      child: const Text('OK'),
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
