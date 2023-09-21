// Flutter imports:
import 'package:file_picker/file_picker.dart';
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
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

enum AddBooruPhase {
  url,
  newUnknownBooru,
  newKnownBooru,
}

class AddBooruPage extends ConsumerStatefulWidget {
  const AddBooruPage({
    super.key,
    required this.setCurrentBooruOnSubmit,
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
            booru = getBooruType(url, booruFactory.booruData);
            phase = booru == BooruType.unknown
                ? AddBooruPhase.newUnknownBooru
                : AddBooruPhase.newKnownBooru;
            this.url = url;
          }),
        ),
      AddBooruPhase.newUnknownBooru => AddUnknownBooruPage(
          url: url,
          setCurrentBooruOnSubmit: widget.setCurrentBooruOnSubmit,
          backgroundColor: widget.backgroundColor,
        ),
      AddBooruPhase.newKnownBooru => CreateBooruPage(
          url: url,
          booruType: booru!,
          backgroundColor: widget.backgroundColor,
        ),
    };
  }
}

class AddBooruPageInternal extends ConsumerStatefulWidget {
  const AddBooruPageInternal({
    super.key,
    required this.setCurrentBooruOnSubmit,
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
  String? storagePath;

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: widget.backgroundColor,
        child: Stack(
          children: [
            _buildBody(),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: context.navigator.pop,
                icon: const Icon(Icons.close),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
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
          child: ValueListenableBuilder(
            valueListenable: booruUrlError,
            builder: (_, error, __) => LoginField(
              validator: (p0) => null,
              autofocus: true,
              onChanged: (value) {
                inputText.value = value;
                booruUrlError.value = mapBooruUrlToUri(value);
              },
              onSubmitted: error.fold(
                (l) => null,
                (r) => (_) => _onNext(r.toString()),
              ),
              controller: urlController,
              labelText: 'booru.site_url'.tr(),
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
        ValueListenableBuilder(
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
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          child: Text(
            'Or browse a local booru on your device',
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            child: Ink(
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                border: Border.fromBorderSide(
                  BorderSide(color: context.theme.hintColor),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: ListTile(
                visualDensity: VisualDensity.compact,
                minVerticalPadding: 0,
                onTap: () => _pickFolder(),
                title: storagePath != null && storagePath!.isNotEmpty
                    ? Text(
                        storagePath!,
                        overflow: TextOverflow.fade,
                      )
                    : Text(
                        'settings.download.select_a_folder'.tr(),
                        overflow: TextOverflow.fade,
                        style: context.textTheme.titleMedium!
                            .copyWith(color: context.theme.hintColor),
                      ),
                trailing: IconButton(
                  onPressed: () => _pickFolder(),
                  icon: const Icon(Icons.folder),
                ),
              ),
            ),
          ),
        ),

        ValueListenableBuilder(
          valueListenable: booruUrlError,
          builder: (_, error, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: error.fold(
              (e) => ElevatedButton(
                onPressed: null,
                child: const Text('booru.next_step').tr(),
              ),
              (uri) => ElevatedButton(
                onPressed: () => _onNext(uri.toString()),
                child: const Text('booru.next_step').tr(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        storagePath = selectedDirectory;
      });
    }
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
