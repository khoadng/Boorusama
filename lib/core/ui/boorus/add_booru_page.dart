// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/login_field.dart';

class AddBooruPage extends StatefulWidget {
  const AddBooruPage({
    super.key,
    required this.onSubmit,
    this.initial,
    required this.booruFactory,
  });

  final void Function(
    AddNewBooruConfig config,
  ) onSubmit;

  final AddNewBooruConfig? initial;
  final BooruFactory booruFactory;

  @override
  State<AddBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends State<AddBooruPage> {
  final loginController = TextEditingController();
  final apiKeyController = TextEditingController();
  final nameController = TextEditingController();
  final urlController = TextEditingController();

  var selectedBooru = BooruType.unknown;
  var hideDeleted = true;
  var ratingFilter = BooruConfigRatingFilter.hideNSFW;

  var allowSubmit = false;
  var showKey = false;

  @override
  void initState() {
    super.initState();
    loginController.addListener(() {
      setState(() {
        allowSubmit = isValid();
      });
    });
    apiKeyController.addListener(() {
      setState(() {
        allowSubmit = isValid();
      });
    });
    nameController.addListener(() {
      setState(() {
        allowSubmit = isValid();
      });
    });
    urlController.addListener(() {
      setState(() {
        allowSubmit = isValid();
        selectedBooru = getBooruType(
          urlController.text,
          widget.booruFactory.booruData,
        );
      });
    });

    if (widget.initial != null) {
      loginController.text = widget.initial!.login;
      apiKeyController.text = widget.initial!.apiKey;
      nameController.text = widget.initial!.configName;
      urlController.text = widget.initial!.url;
      hideDeleted = widget.initial!.hideDeleted;
      ratingFilter = widget.initial!.ratingFilter;
      selectedBooru = widget.initial!.booru;
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

  bool isValid() {
    if (selectedBooru == BooruType.unknown) return false;
    if (nameController.text.isEmpty) return false;
    if (urlController.text.isEmpty) return false;

    return (loginController.text.isNotEmpty &&
            apiKeyController.text.isNotEmpty) ||
        (loginController.text.isEmpty && apiKeyController.text.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
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
                    ),
                    const SizedBox(height: 16),
                    LoginField(
                      validator: (p0) => null,
                      obscureText: !showKey,
                      controller: apiKeyController,
                      labelText: 'API key',
                      suffixIcon: IconButton(
                        splashColor: Colors.transparent,
                        icon: showKey
                            ? const FaIcon(
                                FontAwesomeIcons.solidEyeSlash,
                                size: 18,
                              )
                            : const FaIcon(
                                FontAwesomeIcons.solidEye,
                                size: 18,
                              ),
                        onPressed: () => setState(() => showKey = !showKey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedBooru != BooruType.safebooru)
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
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      ratingFilter = newValue;
                                    });
                                  }
                                },
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
                    if (selectedBooru != BooruType.gelbooru)
                      SwitchListTile.adaptive(
                        title: const Text('Hide deleted posts'),
                        value: hideDeleted,
                        onChanged: (value) => setState(() {
                          hideDeleted = value;
                        }),
                      ),
                    ElevatedButton(
                      onPressed: allowSubmit
                          ? () {
                              Navigator.of(context).pop();
                              widget.onSubmit.call(AddNewBooruConfig(
                                login: loginController.text,
                                apiKey: apiKeyController.text,
                                booru: selectedBooru,
                                configName: nameController.text,
                                hideDeleted: hideDeleted,
                                ratingFilter: ratingFilter,
                                url: urlController.text,
                              ));
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
