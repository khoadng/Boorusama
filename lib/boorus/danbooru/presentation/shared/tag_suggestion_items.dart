// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';

class TagSuggestionItems extends StatelessWidget {
  const TagSuggestionItems({
    Key? key,
    required List<AutocompleteData> tags,
    required this.onItemTap,
  })  : _tags = tags,
        super(key: key);

  final List<AutocompleteData> _tags;
  final ValueChanged<AutocompleteData> onItemTap;

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
              final tag = _tags[index];
              return ListTile(
                onTap: () => onItemTap(_tags[index]),
                trailing: tag.hasCount
                    ? Text(NumberFormat.compact().format(tag.postCount),
                        style: const TextStyle(color: Colors.grey))
                    : null,
                title: _getTitle(tag, state.theme),
              );
            },
          );
        },
      ),
    );
  }
}

Widget _getTitle(AutocompleteData tag, ThemeMode theme) {
  if (tag.hasAlias) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${tag.antecedent!.replaceAll('_', '')}  ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _getTagColor(tag, theme),
            ),
          ),
          const WidgetSpan(
            child: FaIcon(FontAwesomeIcons.arrowRightLong, size: 14),
          ),
          TextSpan(
            text: '  ${tag.label}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _getTagColor(tag, theme),
            ),
          ),
        ],
      ),
    );
  } else {
    return Text(
      tag.label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: _getTagColor(tag, theme),
      ),
    );
  }
}

Color? _getTagColor(AutocompleteData tag, ThemeMode theme) {
  if (tag.hasCategory) {
    return getTagColor(
      intToTagCategory(tag.category!.getIndex()),
      theme,
    );
  } else if (tag.hasUserLevel) {
    return Color(tag.level!.hexColor);
  }

  return null;
}
