// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/core/application/boorus/add_or_update_booru_cubit.dart';
import 'package:boorusama/core/application/boorus/add_or_update_booru_state.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/application/settings/settings_cubit.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/login_field.dart';
import 'package:boorusama/core/ui/option_dropdown_button.dart';
import 'package:boorusama/core/ui/warning_container.dart';

class ConfigBooruPage extends StatefulWidget {
  const ConfigBooruPage({
    super.key,
    required this.onSubmit,
    this.initial,
    required this.booruFactory,
    required this.url,
  });

  static Widget of(
    BuildContext context, {
    required BooruFactory booruFactory,
    BooruConfig? initialConfig,
    required BooruType booru,
    required String url,
    bool setCurrentBooruOnSubmit = false,
    bool unverifiedBooru = false,
  }) {
    final cubit = AddOrUpdateBooruCubit(
      booruFactory: booruFactory,
      initialConfig: initialConfig,
      unverifiedBooru: unverifiedBooru,
    );
    final bloc = context.read<ManageBooruBloc>();
    final settings = context.read<SettingsCubit>().state.settings;
    final currentBooruBloc = context.read<CurrentBooruBloc>();
    return BlocProvider(
      create: (context) => cubit
        ..changeBooru(booru)
        ..changeUrl(url),
      child: ConfigBooruPage(
        onSubmit: (newConfig) {
          bloc.add(
            ManageBooruAdded(
              config: newConfig,
              onSuccess: (booruConfig) {
                if (initialConfig == null) {
                  if (setCurrentBooruOnSubmit) {
                    currentBooruBloc.add(CurrentBooruChanged(
                      booruConfig: booruConfig,
                      settings: settings,
                    ));
                  }
                } else {
                  bloc.add(ManageBooruUpdated(
                    config: newConfig,
                    oldConfig: initialConfig,
                    id: initialConfig.id,
                  ));
                }
              },
            ),
          );
        },
        initial: initialConfig,
        booruFactory: booruFactory,
        url: url,
      ),
    );
  }

  final void Function(
    AddNewBooruConfig config,
  ) onSubmit;

  final BooruConfig? initial;
  final BooruFactory booruFactory;
  final String url;

  @override
  State<ConfigBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends State<ConfigBooruPage>
    with AddOrUpdateBooruCubitMixin {
  final loginController = TextEditingController();
  final apiKeyController = TextEditingController();
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  final _engine = ValueNotifier<BooruEngine?>(null);

  @override
  void initState() {
    super.initState();
    urlController.text = widget.url;

    if (widget.initial != null) {
      loginController.text = widget.initial!.login ?? '';
      apiKeyController.text = widget.initial!.apiKey ?? '';
      nameController.text = widget.initial!.name;
      urlController.text = widget.initial!.url;
    }
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
    final supportContentFilter = context.select(
        (AddOrUpdateBooruCubit cubit) => cubit.state.supportRatingFilter());
    final supportHideDeleted = context.select(
        (AddOrUpdateBooruCubit cubit) => cubit.state.supportHideDeleted());
    final ratingFilter = context
        .select((AddOrUpdateBooruCubit cubit) => cubit.state.ratingFilter);
    final hideDeleted = context.select((AddOrUpdateBooruCubit cubit) =>
        cubit.state.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide);
    final allowSubmit = context
        .select((AddOrUpdateBooruCubit cubit) => cubit.state.allowSubmit());
    final selectedBooru = context
        .select((AddOrUpdateBooruCubit cubit) => cubit.state.selectedBooru);

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
              BlocSelector<AddOrUpdateBooruCubit, AddOrUpdateBooruState, bool>(
                selector: (state) => state.unverifiedBooru,
                builder: (context, unverified) {
                  return !unverified
                      ? Card(
                          child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(selectedBooru.booruType.stringify()),
                        ))
                      : WarningContainer(
                          contentBuilder: (context) => const Text(
                              'This booru is not offically supported yet. It probally won\'t work.'));
                },
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 2,
                endIndent: 16,
                indent: 16,
              ),
              BlocSelector<AddOrUpdateBooruCubit, AddOrUpdateBooruState, bool>(
                selector: (state) => state.unverifiedBooru,
                builder: (context, unverified) {
                  return unverified
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
                                  context
                                      .read<AddOrUpdateBooruCubit>()
                                      .changeBooruEngine(value);
                                },
                                items: BooruEngine.values
                                    .map((value) =>
                                        DropdownMenuItem<BooruEngine>(
                                          value: value,
                                          child: Text(value.name.sentenceCase),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox();
                },
              ),
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
                    AddOrUpdateBooruBuider(
                      builder: (context, state) {
                        return LoginField(
                          readOnly: state.selectedBooru.loginType ==
                                  LoginType.loginAndPasswordHashed &&
                              widget.initial != null,
                          validator: (p0) => null,
                          obscureText: !state.revealKey,
                          controller: apiKeyController,
                          labelText: state.selectedBooru.loginType ==
                                  LoginType.loginAndApiKey
                              ? 'API key'
                              : widget.initial != null
                                  ? 'Password Hashed (readonly)'
                                  : 'Password',
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
                        );
                      },
                    ),
                    if (supportContentFilter)
                      ListTile(
                        title: const Text('Content filtering'),
                        trailing: OptionDropDownButton<BooruConfigRatingFilter>(
                          value: ratingFilter,
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
                    if (supportHideDeleted)
                      SwitchListTile.adaptive(
                        title: const Text('Hide deleted posts'),
                        value: hideDeleted,
                        onChanged: (_) => toggleDeleted(),
                      ),
                    AddOrUpdateBooruBuider(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: allowSubmit
                              ? () {
                                  Navigator.of(context).pop();
                                  widget.onSubmit
                                      .call(state.createNewBooruConfig(
                                    widget.booruFactory,
                                  ));
                                }
                              : null,
                          child: const Text('OK'),
                        );
                      },
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
