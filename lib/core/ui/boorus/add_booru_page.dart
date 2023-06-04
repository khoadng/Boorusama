// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/boorus/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/boorus/config_booru_page.dart';
import 'package:boorusama/core/ui/login_field.dart';
import 'package:boorusama/core/ui/warning_container.dart';
import 'package:boorusama/functional.dart';

class AddBooruPage extends ConsumerStatefulWidget {
  const AddBooruPage({super.key, required this.setCurrentBooruOnSubmit});

  final bool setCurrentBooruOnSubmit;

  @override
  ConsumerState<AddBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends ConsumerState<AddBooruPage> {
  final urlController = TextEditingController();
  final booruUrlError =
      ValueNotifier<BooruUriOrError>(left(BooruUrlError.emptyUrl));
  final inputText = ValueNotifier('');

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Text(
                  'Add a booru',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const Divider(
                thickness: 2,
                endIndent: 16,
                indent: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: LoginField(
                  validator: (p0) => null,
                  onChanged: (value) {
                    inputText.value = value;
                    booruUrlError.value = mapBooruUrlToUri(value);
                  },
                  controller: urlController,
                  labelText: 'Site URL',
                ),
              ),
              ValueListenableBuilder<BooruUriOrError>(
                valueListenable: booruUrlError,
                builder: (_, error, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: error.fold(
                    (e) => const SizedBox.shrink(),
                    (uri) => ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ConfigBooruPage(
                                    setCurrentBooruOnSubmit:
                                        widget.setCurrentBooruOnSubmit,
                                    arg: AddNewConfig(uri),
                                  )));
                        },
                        child: const Text('Next')),
                  ),
                ),
              ),
              ValueListenableBuilder<BooruUriOrError>(
                valueListenable: booruUrlError,
                builder: (_, error, __) => error.fold(
                  (e) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ValueListenableBuilder<String>(
                        valueListenable: inputText,
                        builder: (_, input, __) => Text(
                          e.message(input),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.red),
                        ),
                      )),
                  (uri) => const SizedBox.shrink(),
                ),
              ),
              // warning container for when the URL is not a supported booru
              ValueListenableBuilder<BooruUriOrError>(
                valueListenable: booruUrlError,
                builder: (_, error, __) => error.fold(
                  (e) => const SizedBox.shrink(),
                  (uri) => getBooruType(uri.toString(),
                              ref.watch(booruFactoryProvider).booruData) ==
                          BooruType.unknown
                      ? WarningContainer(
                          contentBuilder: (context) =>
                              const Text('This booru is not supported yet.'))
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// map BooruUrlError to string message
extension BooruUrlErrorX on BooruUrlError {
  String message(String url) => switch (this) {
        BooruUrlError.nullUrl => 'URL is null',
        BooruUrlError.emptyUrl => 'URL is empty',
        BooruUrlError.invalidUrlFormat => '"$url" is not a valid URL',
        BooruUrlError.notAnHttpOrHttpsUrl =>
          '"$url" is not an HTTP or HTTPS URL',
        BooruUrlError.missingLastSlash => '"$url" is missing a trailing slash',
        BooruUrlError.redundantWww => '"$url" contains redundant "www"',
        BooruUrlError.stringHasInbetweenSpaces =>
          '"$url" contains in-between spaces',
        BooruUrlError.missingScheme =>
          '"$url" is missing a scheme (e.g. https://)'
      };
}
