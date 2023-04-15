// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/android.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/device_info_service.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/ui/downloads/widgets/download_tag_selection_view.dart';
import 'package:boorusama/core/ui/warning_container.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with DownloadMixin {
  final changed = ValueNotifier(false);
  String path = "";

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsCubit>().state;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        path = settings.settings.downloadPath ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        context.select((SettingsCubit cubit) => cubit.state.settings);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('download.download').tr(),
        ),
        body: child,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              subtitle: const Text('download.alternative_method_reason').tr(),
              title: const Text('download.alternative_method_title').tr(),
              trailing: Switch(
                activeColor: Theme.of(context).colorScheme.primary,
                value:
                    settings.downloadMethod != DownloadMethod.flutterDownloader,
                onChanged: (value) {
                  changed.value = true;
                  context.read<SettingsCubit>().update(settings.copyWith(
                        downloadMethod: value
                            ? DownloadMethod.imageGallerySaver
                            : DownloadMethod.flutterDownloader,
                      ));
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: changed,
              builder: (context, value, _) => value
                  ? WarningContainer(
                      contentBuilder: (context) =>
                          const Text('download.app_restart_request').tr(),
                    )
                  : const SizedBox.shrink(),
            ),
            const Divider(
              thickness: 2,
              endIndent: 16,
              indent: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Download path'.tr().toUpperCase(),
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
              child: Material(
                child: Ink(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.fromBorderSide(
                      BorderSide(color: Theme.of(context).hintColor),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: ListTile(
                    visualDensity: VisualDensity.compact,
                    minVerticalPadding: 0,
                    onTap: () => _pickFolder(settings),
                    title: storagePath.isNotEmpty
                        ? Text(
                            storagePath,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            'download.bulk_download_select_a_folder'.tr(),
                            overflow: TextOverflow.fade,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Theme.of(context).hintColor),
                          ),
                    trailing: IconButton(
                      onPressed: () => _pickFolder(settings),
                      icon: const Icon(Icons.folder),
                    ),
                  ),
                ),
              ),
            ),
            if (isAndroid())
              shouldDisplayWarning(
                hasScopeStorage: hasScopedStorage(context
                        .read<DeviceInfo>()
                        .androidDeviceInfo
                        ?.version
                        .sdkInt) ??
                    true,
              )
                  ? DownloadPathWarning(
                      releaseName: context
                              .read<DeviceInfo>()
                              .androidDeviceInfo
                              ?.version
                              .release ??
                          'Unknown',
                      allowedFolders: allowedFolders,
                    )
                  : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFolder(Settings settings) async {
    final bloc = context.read<SettingsCubit>();
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      bloc.update(settings.copyWith(downloadPath: selectedDirectory));
    }
  }

  @override
  String get storagePath => path;
}
