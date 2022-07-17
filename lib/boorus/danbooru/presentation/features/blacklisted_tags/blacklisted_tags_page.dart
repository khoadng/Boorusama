// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/autocomplete/autocomplete_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/tag_info_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/core/presentation/widgets/parallax_slide_in_page_route.dart';
import 'blacklisted_tags_search_page.dart';

class BlacklistedTagsPage extends StatelessWidget {
  const BlacklistedTagsPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final int userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blacklisted tags'),
        actions: [
          _buildAddTagButton(),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<BlacklistedTagsBloc, BlacklistedTagsState>(
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
              return const Center(
                child: Text('Failed to load blacklisted tags'),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
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
            trailing: IconButton(
                onPressed: () => context
                    .read<BlacklistedTagsBloc>()
                    .add(BlacklistedTagChanged(
                      tags: [...state.blacklistedTags..remove(tag)],
                      userId: userId,
                    )),
                icon: const FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 18,
                )),
          );
        },
        childCount: state.blacklistedTags.length,
      ),
    );
  }

  Widget _buildWarning() {
    return SliverToBoxAdapter(
      child: WarningContainer(contentBuilder: (context) {
        return RichText(
            text: const TextSpan(children: [
          TextSpan(text: 'Only support '),
          TextSpan(text: 'NOT ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: 'operator and '),
          TextSpan(text: 'OR ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: 'operator.'),
          TextSpan(
              text:
                  "\n\nBlacklisting using metatags won't work for current version."),
        ]));
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
                  onSelectedDone: (tagItems) => bloc.add(BlacklistedTagChanged(
                    tags: [
                      ...state.blacklistedTags,
                      tagItems.map((e) => e.toString()).join(' '),
                    ],
                    userId: userId,
                  )),
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
