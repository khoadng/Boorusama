// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tags_search_page.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/warning_container.dart';
import 'blacklisted_tags_page.dart';

class BlacklistedTagsPageDesktop extends StatelessWidget {
  const BlacklistedTagsPageDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'blacklisted_tags.blacklisted_tags'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 12),
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => TagSearchBloc(
                    tagInfo: context.read<TagInfo>(),
                    autocompleteRepository:
                        context.read<AutocompleteRepository>(),
                  ),
                ),
              ],
              child: ElevatedButton(
                onPressed: () => _showEditView(context),
                child: const Text('Add tag'),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(
          thickness: 1.5,
        ),
        WarningContainer(contentBuilder: (context) {
          return Html(
            data: 'blacklisted_tags.limitation_notice'.tr(),
          );
        }),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<BlacklistedTagsBloc, BlacklistedTagsState>(
              builder: (context, state) {
                switch (state.status) {
                  case LoadStatus.initial:
                  case LoadStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case LoadStatus.success:
                    final tags = state.blacklistedTags;
                    if (tags == null) {
                      return Center(
                        child: const Text('blacklisted_tags.load_error').tr(),
                      );
                    }

                    return ListView.builder(
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tag = tags[index];

                        return BlacklistedTagTile(
                          tag: tag,
                          onEditTap: () => _showEditView(
                            context,
                            initialTags: tag.split(' '),
                          ),
                        );
                      },
                    );
                  case LoadStatus.failure:
                    return Center(
                      child: const Text('blacklisted_tags.load_error').tr(),
                    );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<T?> _showEditView<T>(
    BuildContext context, {
    List<String>? initialTags,
  }) {
    final bloc = context.read<BlacklistedTagsBloc>();

    return showDesktopDialogWindow<T>(
      context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      width: min(MediaQuery.of(context).size.width * 0.65, 700),
      height: min(MediaQuery.of(context).size.height * 0.7, 500),
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TagSearchBloc(
              tagInfo: context.read<TagInfo>(),
              autocompleteRepository: context.read<AutocompleteRepository>(),
            ),
          ),
        ],
        child: BlacklistedTagsSearchPage(
          initialTags: initialTags,
          onSelectedDone: (tagItems) {
            bloc.add(BlacklistedTagAdded(
              tag: tagItems.map((e) => e.toString()).join(' '),
            ));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
