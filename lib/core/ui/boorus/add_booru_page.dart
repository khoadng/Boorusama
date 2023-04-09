// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/application/boorus/add_or_update_booru_cubit.dart';
import 'package:boorusama/core/application/boorus/add_or_update_booru_state.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/login_field.dart';

class AddBooruPage extends StatefulWidget {
  const AddBooruPage({
    super.key,
    required this.onSubmit,
    this.initial,
  });

  static Widget of(
    BuildContext context, {
    required void Function(AddNewBooruConfig config) onSubmit,
    required BooruFactory booruFactory,
    BooruConfig? initialConfig,
  }) {
    return BlocProvider(
      create: (context) => AddOrUpdateBooruCubit(
        booruFactory: booruFactory,
        initialConfig: initialConfig,
      ),
      child: AddBooruPage(
        onSubmit: onSubmit,
        initial: initialConfig,
      ),
    );
  }

  final void Function(
    AddNewBooruConfig config,
  ) onSubmit;

  final BooruConfig? initial;

  @override
  State<AddBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends State<AddBooruPage>
    with AddOrUpdateBooruCubitMixin {
  final loginController = TextEditingController();
  final apiKeyController = TextEditingController();
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

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
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(selectedBooru.stringify()),
              )),
              const SizedBox(height: 8),
              const Divider(
                thickness: 2,
                endIndent: 16,
                indent: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Config Name'.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w800,
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
                  labelText: 'Name',
                  onChanged: changeConfigName,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Site'.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w800,
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
                  controller: urlController,
                  labelText: 'Site URL',
                  onChanged: changeUrl,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Login details'.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w800,
                      ),
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
                          validator: (p0) => null,
                          obscureText: !state.revealKey,
                          controller: apiKeyController,
                          labelText: 'API key',
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
                        trailing: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<BooruConfigRatingFilter>(
                                isDense: true,
                                value: ratingFilter,
                                icon: const Padding(
                                  padding: EdgeInsets.only(left: 5, top: 2),
                                  child: FaIcon(FontAwesomeIcons.angleDown,
                                      size: 16),
                                ),
                                onChanged: changeRatingFilter,
                                items: BooruConfigRatingFilter.values
                                    .map((value) => DropdownMenuItem<
                                            BooruConfigRatingFilter>(
                                          value: value,
                                          child:
                                              Text(value.getFilterRatingTerm()),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
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
                                      .call(state.createNewBooruConfig());
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
