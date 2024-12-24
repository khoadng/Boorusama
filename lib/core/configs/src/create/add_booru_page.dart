// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../boorus/booru/providers.dart';
import '../../../boorus/engine/providers.dart';
import '../../../widgets/widgets.dart';
import '../booru_config.dart';
import '../edit_booru_config_id.dart';
import '../validator/booru_url_error.dart';
import '../validator/booru_url_validator.dart';
import 'add_unknown_booru_page.dart';
import 'scaffold.dart';

enum AddBooruPhase {
  url,
  newUnknownBooru,
  newKnownBooru,
}

class AddBooruPage extends ConsumerStatefulWidget {
  const AddBooruPage({
    required this.setCurrentBooruOnSubmit,
    super.key,
    this.backgroundColor,
  });

  final bool setCurrentBooruOnSubmit;
  final Color? backgroundColor;

  @override
  ConsumerState<AddBooruPage> createState() => _AddBooruPageState();
}

class _AddBooruPageState extends ConsumerState<AddBooruPage> {
  var phase = AddBooruPhase.url;
  var url = '';
  BooruType? booru;

  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      AddBooruPhase.url => AddBooruPageInternal(
          backgroundColor: widget.backgroundColor,
          setCurrentBooruOnSubmit: widget.setCurrentBooruOnSubmit,
          onBooruSubmit: (url) => setState(() {
            final booruFactory = ref.read(booruFactoryProvider);
            booru = intToBooruType(booruFactory.getBooruFromUrl(url)?.id);
            phase = booru == BooruType.unknown
                ? AddBooruPhase.newUnknownBooru
                : AddBooruPhase.newKnownBooru;
            this.url = url;
          }),
        ),
      AddBooruPhase.newUnknownBooru => CreateBooruConfigScope(
          id: EditBooruConfigId.newId(
            booruType: BooruType.unknown,
            url: url,
          ),
          config: BooruConfig.defaultConfig(
            booruType: BooruType.unknown,
            url: url,
            customDownloadFileNameFormat: null,
          ),
          child: AddUnknownBooruPage(
            setCurrentBooruOnSubmit: widget.setCurrentBooruOnSubmit,
            backgroundColor: widget.backgroundColor,
          ),
        ),
      AddBooruPhase.newKnownBooru => _buildNewKnownBooru(booru!, url),
    };
  }

  Widget _buildNewKnownBooru(BooruType booruType, String booruUrl) {
    final defaultConfig = BooruConfig.defaultConfig(
      booruType: booruType,
      url: booruUrl,
      customDownloadFileNameFormat: null,
    );
    final booruBuilder =
        ref.watchBooruBuilder(defaultConfig.auth)?.createConfigPageBuilder;

    return booruBuilder != null
        ? booruBuilder(
            context,
            EditBooruConfigId.newId(
              booruType: booruType,
              url: booruUrl,
            ),
            backgroundColor: widget.backgroundColor,
          )
        : Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Not implemented'),
            ),
          );
  }
}

class AddBooruPageInternal extends ConsumerStatefulWidget {
  const AddBooruPageInternal({
    required this.setCurrentBooruOnSubmit,
    super.key,
    this.backgroundColor,
    this.onBooruSubmit,
  });

  final bool setCurrentBooruOnSubmit;
  final Color? backgroundColor;
  final void Function(String url)? onBooruSubmit;

  @override
  ConsumerState<AddBooruPageInternal> createState() =>
      _AddBooruPageInternalState();
}

class _AddBooruPageInternalState extends ConsumerState<AddBooruPageInternal> {
  final urlController = TextEditingController();
  final booruUrlError = ValueNotifier(left(BooruUrlError.emptyUrl));
  final inputText = ValueNotifier('');

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: MediaQuery.viewPaddingOf(context).top,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'booru.add_a_booru_site'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w900),
              ),
              IconButton(
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Symbols.close),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
          child: ValueListenableBuilder(
            valueListenable: booruUrlError,
            builder: (_, error, __) => AutofillGroup(
              child: BooruTextFormField(
                validator: (p0) => null,
                autocorrect: false,
                autofillHints: const [
                  AutofillHints.url,
                ],
                keyboardType: TextInputType.url,
                autofocus: true,
                onChanged: (value) {
                  inputText.value = value;
                  booruUrlError.value = mapBooruUrlToUri(value);
                },
                onFieldSubmitted: error.fold(
                  (l) => null,
                  (r) => (_) => _onNext(r.toString()),
                ),
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'booru.site_url'.tr(),
                ),
              ),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: booruUrlError,
          builder: (_, error, __) => error.fold(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ValueListenableBuilder(
                valueListenable: inputText,
                builder: (_, input, __) => Text(
                  e.message(input),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            ),
            (uri) => const SizedBox.shrink(),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: booruUrlError,
          builder: (_, error, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: error.fold(
              (e) => FilledButton(
                onPressed: null,
                child: const Text('booru.next_step').tr(),
              ),
              (uri) => FilledButton(
                onPressed: () => _onNext(uri.toString()),
                child: const Text('booru.next_step').tr(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onNext(String url) {
    widget.onBooruSubmit?.call(url);
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
