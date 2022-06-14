// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';

class TagSuggestionItems extends StatelessWidget {
  const TagSuggestionItems({
    Key? key,
    required List<Tag> tags,
    required this.onItemTap,
  })  : _tags = tags,
        super(key: key);

  final List<Tag> _tags;
  final ValueChanged<Tag> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ListView.builder(
            // shrinkWrap: true,
            // itemCount: _tags.length > 6 ? 6 : _tags.length,
            // physics: const NeverScrollableScrollPhysics(),
            itemCount: _tags.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () => onItemTap(_tags[index]),
                trailing: Text(_tags[index].postCount.toString(),
                    style: const TextStyle(color: Colors.grey)),
                title: Text(
                  _tags[index].displayName,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: getTagColor(
                        _tags[index].category,
                        state.theme,
                      )),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
