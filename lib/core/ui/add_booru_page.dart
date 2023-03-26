// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/ui/login_field.dart';

class AddBooruPage extends StatefulWidget {
  const AddBooruPage({
    super.key,
    required this.onSubmit,
  });

  final void Function(
    AddNewBooruConfig config,
  ) onSubmit;

  @override
  State<AddBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends State<AddBooruPage> {
  final loginController = TextEditingController();
  final apiKeyController = TextEditingController();
  final nameController = TextEditingController();

  var selectedBooru = BooruType.safebooru;
  var hideDeleted = false;
  var ratingFilter = true;

  var allowSubmit = false;

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
  }

  @override
  void dispose() {
    loginController.dispose();
    apiKeyController.dispose();
    nameController.dispose();
    super.dispose();
  }

  bool isValid() {
    if (nameController.text.isEmpty) return false;

    return (loginController.text.isNotEmpty &&
            apiKeyController.text.isNotEmpty) ||
        (loginController.text.isEmpty && apiKeyController.text.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Add a Booru, leave the login details empty to be anonymous',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BooruType>(
                      isDense: true,
                      value: selectedBooru,
                      focusColor: Colors.transparent,
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 5, top: 2),
                        child: FaIcon(FontAwesomeIcons.angleDown, size: 16),
                      ),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedBooru = newValue;
                          });
                        }
                      },
                      items: getSelectableBoorus()
                          .sortedBy((e) => e.stringify())
                          .map((value) => DropdownMenuItem<BooruType>(
                                value: value,
                                child: Text(value.stringify()),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(
              thickness: 2,
              endIndent: 16,
              indent: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Name'.toUpperCase(),
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
                    controller: apiKeyController,
                    labelText: 'API key',
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    title: const Text('Rating filter'),
                    value: ratingFilter,
                    onChanged: (value) => setState(() {
                      ratingFilter = value;
                    }),
                  ),
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
    );
  }
}
