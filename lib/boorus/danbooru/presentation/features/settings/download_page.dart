// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/core/infrastructure/io_helper.dart';

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
            title: const Text('Download'),
          ),
          body: SafeArea(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.error,
                ),
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          children: const [
                        TextSpan(
                            text:
                                'Only subfolders created inside public directories '),
                        TextSpan(
                            text: '(Download, Pictures, Documents) ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                                "are allowed in Android 11+. Picking anything else won't work.")
                      ])),
                ),
              ),
            ),
            ListTile(
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
          ])),
        );
      },
    );
  }
}
