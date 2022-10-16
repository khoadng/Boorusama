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
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/parallax_slide_in_page_route.dart';
import 'blacklisted_tags_search_page.dart';

class BlacklistedTagsPage extends StatelessWidget {
  const BlacklistedTagsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Screen.of(context).size == ScreenSize.small) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('blacklisted_tags.blacklisted_tags').tr(),
          actions: [
            _buildAddTagButton(),
          ],
        ),
        body: SafeArea(
          child: _buildTags(),
        ),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 300,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                      create: (context) => TagSearchBloc(
                          tagInfo: context.read<TagInfo>(),
                          autocompleteRepository:
                              context.read<AutocompleteRepository>())),
                ],
                child: BlacklistedTagsSearchPage(
                  onSelectedDone: (tagItems) {
                    context.read<BlacklistedTagsBloc>().add(BlacklistedTagAdded(
                          tag: tagItems.map((e) => e.toString()).join(' '),
                        ));
                  },
                ),
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: _buildTags(),
            )
          ],
        ),
      );
    }
  }

  Widget _buildTags() {
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
              _buildWarning(),
              _buildBlacklistedList(state),
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

  Widget _buildBlacklistedList(BlacklistedTagsState state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tag = state.blacklistedTags[index];

          return ListTile(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              title: Text(tag),
              trailing: PopupMenuButton(
                constraints: const BoxConstraints(minWidth: 150),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
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
                        final bloc = context.read<BlacklistedTagsBloc>();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(ParallaxSlideInPageRoute(
                          enterWidget: MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (context) => TagSearchBloc(
                                      tagInfo: context.read<TagInfo>(),
                                      autocompleteRepository: context
                                          .read<AutocompleteRepository>())),
                            ],
                            child: BlacklistedTagsSearchPage(
                              initialTags: tag.split(' '),
                              onSelectedDone: (tagItems) {
                                bloc.add(BlacklistedTagReplaced(
                                  oldTag: tag,
                                  newTag: tagItems
                                      .map((e) => e.toString())
                                      .join(' '),
                                ));
                              },
                            ),
                          ),
                          oldWidget: this,
                        ));
                      },
                      title: const Text('blacklisted_tags.edit').tr(),
                      trailing: const FaIcon(
                        FontAwesomeIcons.pen,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ));
        },
        childCount: state.blacklistedTags.length,
      ),
    );
  }

  Widget _buildWarning() {
    return SliverToBoxAdapter(
      child: WarningContainer(contentBuilder: (context) {
        return Html(data: 'blacklisted_tags.limitation_notice'.tr());
      }),
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
                              context.read<AutocompleteRepository>())),
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
