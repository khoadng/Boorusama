// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/add_unknown_booru_page.dart';
import 'package:boorusama/boorus/core/pages/boorus/create_booru_page.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Text(
                  'booru.add_a_booru_site'.tr(),
                  style: context.textTheme.headlineSmall!
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
                  autofocus: true,
                  onChanged: (value) {
                    inputText.value = value;
                    booruUrlError.value = mapBooruUrlToUri(value);
                  },
                  controller: urlController,
                  labelText: 'booru.site_url'.tr(),
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
                        context.navigator.pop();
                        final booruFactory = ref.watch(booruFactoryProvider);
                        final booru = getBooruType(
                            uri.toString(), booruFactory.booruData);
                        if (booru == BooruType.unknown) {
                          context.navigator.push(MaterialPageRoute(
                              builder: (_) => AddUnknownBooruPage(
                                    url: uri.toString(),
                                    setCurrentBooruOnSubmit:
                                        widget.setCurrentBooruOnSubmit,
                                  )));
                        } else {
                          context.navigator.push(MaterialPageRoute(
                              builder: (_) => CreateBooruPage(
                                  booru: booruFactory.from(type: booru))));
                        }
                      },
                      child: const Text('booru.next_step').tr(),
                    ),
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
                          style: context.theme.textTheme.bodyLarge!
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
                          contentBuilder: (context) => const Text(
                            'booru.unsupported_warning',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ).tr(),
                        )
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

extension BooruUrlErrorX on BooruUrlError {
  String message(String url) => switch (this) {
        BooruUrlError.nullUrl => 'URL is null',
        BooruUrlError.emptyUrl => 'booru.validation_empty_url'.tr(),
        BooruUrlError.invalidUrlFormat =>
          'booru.validation_invalid_url'.tr().replaceAll('{0}', url),
        BooruUrlError.notAnHttpOrHttpsUrl =>
          'booru.validation_invalid_http_url'.tr().replaceAll('{0}', url),
        BooruUrlError.missingLastSlash =>
          'booru.validation_missing_trailing_slash'.tr().replaceAll('{0}', url),
        BooruUrlError.redundantWww =>
          'booru.validation_redundant_www'.tr().replaceAll('{0}', url),
        BooruUrlError.stringHasInbetweenSpaces =>
          'booru.validation_contains_spaces'.tr().replaceAll('{0}', url),
        BooruUrlError.missingScheme =>
          'booru.validation_missing_scheme'.tr().replaceAll('{0}', url),
      };
}
