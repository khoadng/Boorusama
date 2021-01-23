import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/search/suggestions_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

class TagSettingsPage extends HookWidget {
  TagSettingsPage({
    Key key,
    @required this.settings,
  }) : super(key: key);

  final Setting settings;

  @override
  Widget build(BuildContext context) {
    final blackListedTags = useProvider(blacklistedTagsProvider);

    return blackListedTags.when(
      data: (tags) => Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     final tag = await showSearch(
        //       context: context,
        //       delegate: _Search(),
        //     );
        //     if (tag != null) {
        //       tags.add(tag);
        //     }
        //   },
        //   child: Icon(
        //     Icons.add,
        //   ),
        // ),
        appBar: AppBar(
          title: Text("Blacklisted tags"),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(tags[index]),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  tags.remove(tags[index]);
                },
              ),
            );
          },
          itemCount: tags.length,
        ),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: CircularProgressIndicator()),
    );
  }
}
