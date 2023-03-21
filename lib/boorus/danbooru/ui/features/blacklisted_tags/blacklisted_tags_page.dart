// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/warning_container.dart';
import 'blacklisted_tags_search_page.dart';

class BlacklistedTagsPage extends StatelessWidget {
  const BlacklistedTagsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Screen.of(context).size == ScreenSize.small
        ? Scaffold(
            appBar: AppBar(
              title: const Text('blacklisted_tags.blacklisted_tags').tr(),
              actions: [_buildAddTagButton()],
            ),
            body: const SafeArea(child: BlacklistedTagsList()),
          )
        : Scaffold(
            body: Row(children: [
              SizedBox(
                width: 300,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => TagSearchBloc(
                        tagInfo: context.read<TagInfo>(),
                        autocompleteRepository:
                            context.read<AutocompleteRepository>(),
                      ),
                    ),
                  ],
                  child: BlacklistedTagsSearchPage(onSelectedDone: (tagItems) {
                    context.read<BlacklistedTagsBloc>().add(BlacklistedTagAdded(
                          tag: tagItems.map((e) => e.toString()).join(' '),
                        ));
                  }),
                ),
              ),
              const VerticalDivider(),
              const Expanded(child: BlacklistedTagsList()),
            ]),
          );
  }

  Widget _buildAddTagButton() {
    return BlocBuilder<BlacklistedTagsBloc, BlacklistedTagsState>(
      builder: (context, state) {
        return IconButton(
          onPressed: () {
            final bloc = context.read<BlacklistedTagsBloc>();

            goToBlacklistedTagsSearchPage(
              context,
              onSelectDone: (tagItems) {
                bloc.add(BlacklistedTagAdded(
                  tag: tagItems.map((e) => e.toString()).join(' '),
                ));
                Navigator.of(context).pop();
              },
            );
          },
          icon: const FaIcon(FontAwesomeIcons.plus),
        );
      },
    );
  }
}

// ignore: prefer-single-widget-per-file
class BlacklistedTagsList extends StatelessWidget {
  const BlacklistedTagsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlacklistedTagsBloc, BlacklistedTagsState>(
      builder: (context, state) {
        if (state.status == LoadStatus.success ||
            state.status == LoadStatus.loading) {
          final tags = state.blacklistedTags;
          if (tags == null) {
            return Center(
              child: const Text('blacklisted_tags.load_error').tr(),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: WarningContainer(contentBuilder: (context) {
                  return Html(data: 'blacklisted_tags.limitation_notice'.tr());
                }),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tag = tags[index];

                    return BlacklistedTagTile(
                      tag: tag,
                      onEditTap: () {
                        final bloc = context.read<BlacklistedTagsBloc>();

                        goToBlacklistedTagsSearchPage(
                          context,
                          initialTags: tag.split(' '),
                          onSelectDone: (tagItems) {
                            bloc.add(BlacklistedTagReplaced(
                              oldTag: tag,
                              newTag:
                                  tagItems.map((e) => e.toString()).join(' '),
                            ));
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                  childCount: tags.length,
                ),
              ),
            ],
          );
        } else if (state.status == LoadStatus.failure) {
          return Center(
            child: const Text('blacklisted_tags.load_error').tr(),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// ignore: prefer-single-widget-per-file
class BlacklistedTagTile extends StatelessWidget {
  const BlacklistedTagTile({
    super.key,
    required this.tag,
    required this.onEditTap,
  });

  final String tag;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        child: ListTile(
          title: Text(tag),
          // ignore: no-empty-block
          onTap: () {},
          trailing: PopupMenuButton(
            constraints: const BoxConstraints(minWidth: 150),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    context
                        .read<BlacklistedTagsBloc>()
                        .add(BlacklistedTagRemoved(tag: tag));
                  },
                  title: const Text('blacklisted_tags.remove').tr(),
                  trailing: const FaIcon(
                    FontAwesomeIcons.trash,
                    size: 16,
                  ),
                ),
              ),
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    onEditTap.call();
                  },
                  title: const Text('blacklisted_tags.edit').tr(),
                  trailing: const FaIcon(
                    FontAwesomeIcons.pen,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
