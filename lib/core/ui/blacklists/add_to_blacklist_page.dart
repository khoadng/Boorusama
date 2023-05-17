// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/ui/tags.dart';
import 'package:boorusama/core/utils.dart';

class AddToBlacklistPage extends ConsumerWidget {
  const AddToBlacklistPage({
    super.key,
    required this.tags,
  });

  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
        ],
        toolbarHeight: kToolbarHeight * 0.75,
        automaticallyImplyLeading: false,
        title: const Text('Add to blacklist'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
            title: Text(
              tags[index].displayName,
              style: TextStyle(
                color: getTagColor(tags[index].category, theme),
              ),
            ),
            onTap: () {
              final tag = tags[index];
              Navigator.of(context).pop();
              ref.read(danbooruBlacklistedTagsProvider.notifier).add(
                    tag: tag.rawName,
                    onFailure: (message) => showSimpleSnackBar(
                      context: context,
                      content: Text(message),
                    ),
                    onSuccess: (_) => showSimpleSnackBar(
                      context: context,
                      duration: const Duration(seconds: 2),
                      content: const Text('Blacklisted tags updated'),
                    ),
                  );
            }),
        itemCount: tags.length,
      ),
    );
  }
}
