// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/warning_container.dart';
import 'package:boorusama/core/ui/widgets/parallax_slide_in_page_route.dart';
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

            Navigator.of(context).push(ParallaxSlideInPageRoute(
              enterWidget: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => TagSearchBloc(
                      tagInfo: context.read<TagInfo>(),
                      autocompleteRepository:
                          context.read<AutocompleteRepository>(),
                    ),
                  ),
                ],
                child: BlacklistedTagsSearchPage(
                  onSelectedDone: (tagItems) {
                    bloc.add(BlacklistedTagAdded(
                      tag: tagItems.map((e) => e.toString()).join(' '),
                    ));
                    Navigator.of(context).pop();
                  },
                ),
              ),
              oldWidget: this,
            ));
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
    return BlocConsumer<BlacklistedTagsBloc, BlacklistedTagsState>(
      listenWhen: (previous, current) => current is BlacklistedTagsError,
      listener: (context, state) {
        final snackbar = SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          content: Text((state as BlacklistedTagsError).errorMessage),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      builder: (context, state) {
        if (state.status == LoadStatus.success ||
            state.status == LoadStatus.loading) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: WarningContainer(contentBuilder: (context) {
                  return Html(data: 'blacklisted_tags.limitation_notice'.tr());
                }),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => BlacklistedTagTile(
                    tag: state.blacklistedTags[index],
                    onEditTap: () {
                      final bloc = context.read<BlacklistedTagsBloc>();

                      Navigator.of(context).push(ParallaxSlideInPageRoute(
                        enterWidget: MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) => TagSearchBloc(
                                tagInfo: context.read<TagInfo>(),
                                autocompleteRepository:
                                    context.read<AutocompleteRepository>(),
                              ),
                            ),
                          ],
                          child: BlacklistedTagsSearchPage(
                            initialTags:
                                state.blacklistedTags[index].split(' '),
                            onSelectedDone: (tagItems) {
                              bloc.add(BlacklistedTagReplaced(
                                oldTag: state.blacklistedTags[index],
                                newTag:
                                    tagItems.map((e) => e.toString()).join(' '),
                              ));
                            },
                          ),
                        ),
                        oldWidget: this,
                      ));
                    },
                  ),
                  childCount: state.blacklistedTags.length,
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
    return ListTile(
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      title: Text(tag),
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
    );
  }
}
