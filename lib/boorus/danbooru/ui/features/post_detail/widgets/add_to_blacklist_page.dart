// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/features/tags/tags.dart';
import 'package:boorusama/core/application/theme/theme.dart';

class AddToBlacklistPage extends StatelessWidget {
  const AddToBlacklistPage({
    super.key,
    required this.tags,
    required this.onAdded,
  });

  final List<Tag> tags;
  final void Function(Tag tag) onAdded;

  @override
  Widget build(BuildContext context) {
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
            Navigator.of(context).pop();
            onAdded(tags[index]);
          },
        ),
        itemCount: tags.length,
      ),
    );
  }
}
