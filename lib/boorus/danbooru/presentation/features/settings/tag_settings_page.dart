// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';

class TagSettingsPage extends HookWidget {
  TagSettingsPage({
    Key key,
    @required this.settings,
  }) : super(key: key);

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final blackListedTags = useProvider(blacklistedTagsProvider);
    final isLoggedIn = useProvider(isLoggedInProvider);

    return isLoggedIn
        ? blackListedTags.when(
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
            error: (error, stackTrace) =>
                Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Blacklisted tags"),
            ),
            body: Center(
              child: Text("Log in to view your blacklisted tag"),
            ),
          );
  }
}
