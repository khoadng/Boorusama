// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infrastructure/device_info_service.dart';
import 'package:boorusama/core/infrastructure/io_helper.dart';

const String _basePath = '/storage/emulated/0/';
const List<String> _allowedFolders = ['Download', 'Documents', 'Pictures'];

bool _isInvalidDownloadPath(String? path) {
  try {
    if (path == null) return false;

    final nonBasePath = path.replaceAll(_basePath, '');
    final paths = nonBasePath.split('/');

    if (paths.isEmpty) return true;
    if (!_allowedFolders.contains(paths.first)) return true;
    return false;
  } catch (e) {
    return false;
  }
}

class DownloadPage extends StatelessWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.downloadPath != current.settings.downloadPath,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('download.download').tr(),
          ),
          body: SafeArea(
              child: Column(children: [
            if (hasScopedStorage(context.read<DeviceInfo>()))
              _DownloadPathWarning(
                releaseName: context.read<DeviceInfo>().release,
                allowedFolders: _allowedFolders,
              ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.folder),
              onTap: () async {
                final bloc = context.read<SettingsCubit>();
                final path = await FilePicker.platform.getDirectoryPath();

                if (path == null) return;
                await bloc.update(state.settings.copyWith(downloadPath: path));
              },
              subtitle: state.settings.downloadPath != null
                  ? Text(state.settings.downloadPath!)
                  : FutureBuilder<String>(
                      future: IOHelper.getDownloadPath(),
                      builder: (_, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
              title: const Text('Download path'),
            ),
            if (hasScopedStorage(context.read<DeviceInfo>()) &&
                _isInvalidDownloadPath(state.settings.downloadPath))
              WarningContainer(
                  contentBuilder: (context) =>
                      const Text('Download might fail if using this path.'))
          ])),
        );
      },
    );
  }
}

class _DownloadPathWarning extends StatelessWidget {
  const _DownloadPathWarning({
    Key? key,
    required this.releaseName,
    required this.allowedFolders,
  }) : super(key: key);

  final String releaseName;
  final List<String> allowedFolders;

  @override
  Widget build(BuildContext context) {
    return WarningContainer(
      contentBuilder: (context) => RichText(
          text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              children: [
            const TextSpan(
                text: 'Only subfolders created inside public directories '),
            TextSpan(
                text: '(${allowedFolders.join(',')}) ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(
                text:
                    "are allowed in Android 11+. Picking anything else won't work."),
            TextSpan(text: "\n\nThis device's version is $releaseName")
          ])),
    );
  }
}
