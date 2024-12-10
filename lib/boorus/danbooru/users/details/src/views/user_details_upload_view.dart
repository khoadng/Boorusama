// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../../../core/foundation/platform.dart';
import '../../../../../../core/posts/details/parts.dart';
import '../../../../../../core/router.dart';
import '../../../../../../core/tags/categories/tag_category.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/utils/flutter_utils.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../posts/post/post.dart';
import '../../../../tags/related/related.dart';
import '../../../user/user.dart';
import '../providers/local_providers.dart';
import '../types/danbooru_report_data_params.dart';
import '../widgets/upload_date_range_selector_button.dart';
import '../widgets/user_charts.dart';

const _kTopCopyrigthTags = 5;

class UserDetailsUploadView extends ConsumerStatefulWidget {
  const UserDetailsUploadView({
    super.key,
    required this.uid,
    required this.username,
    required this.isSelf,
    required this.user,
  });

  final int uid;
  final String username;
  final bool isSelf;
  final DanbooruUser user;

  @override
  ConsumerState<UserDetailsUploadView> createState() => _UserUploadViewState();
}

class _UserUploadViewState extends ConsumerState<UserDetailsUploadView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        if (widget.user.uploadCount > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 12,
              ),
              child: SizedBox(
                height: 220,
                child: ref
                    .watch(
                      userDataProvider(
                        DanbooruReportDataParams.forUser(widget.user),
                      ),
                    )
                    .maybeWhen(
                      data: (data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${data.sumBy((e) => e.postCount).toString()} uploads',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const UploadDateRangeSelectorButton(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: UserUploadDailyDeltaChart(
                              data: data,
                            ),
                          ),
                        ],
                      ),
                      orElse: () => const SizedBox(
                        height: 160,
                        child: Center(
                          child: SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ),
        if (widget.user.uploadCount > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Top {0} copyrights'.replaceFirst(
                      '{0}',
                      _kTopCopyrigthTags.toString(),
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  ref
                      .watch(
                        userCopyrightDataProvider(
                          (
                            username: widget.username,
                            uploadCount: widget.user.uploadCount,
                          ),
                        ),
                      )
                      .maybeWhen(
                        data: (data) => _buildTags(
                          data.tags.take(_kTopCopyrigthTags).toList(),
                        ),
                        orElse: () => _buildPlaceHolderTags(context),
                      ),
                ],
              ),
            ),
          ),
        SliverUploadPostList(
          title: 'Uploads',
          user: widget.user,
        ),
      ],
    );
  }

  Widget _buildPlaceHolderTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: isDesktopPlatform() ? 4 : 0,
      children: [
        'aaaaaaaaaaaaa',
        'fffffffffffffffff',
        'ccccccccccccccccc',
        'dddddddddd',
        'bbbddddddbb',
      ]
          .map(
            (e) => BooruChip(
              visualDensity: VisualDensity.compact,
              label: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                ),
                child: Text(
                  e,
                  style: const TextStyle(color: Colors.transparent),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTags(List<DanbooruRelatedTagItem> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: isDesktopPlatform() ? 4 : 0,
      children: tags
          .map(
            (e) => BooruChip(
              visualDensity: VisualDensity.compact,
              color: ref.watch(tagColorProvider(TagCategory.copyright().name)),
              onPressed: () => goToSearchPage(
                context,
                tag: e.tag,
              ),
              label: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                ),
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: e.tag.replaceAll('_', ' '),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness.isDark
                          ? ref.watch(
                              tagColorProvider(TagCategory.copyright().name),
                            )
                          : Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: '  ${(e.frequency * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).brightness.isLight
                                  ? Colors.white.withOpacity(0.85)
                                  : null,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class SliverUploadPostList extends ConsumerWidget {
  const SliverUploadPostList({
    super.key,
    required this.title,
    required this.user,
  });

  final String title;
  final DanbooruUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (
      username: user.name,
      uploadCount: user.uploadCount,
    );

    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 8,
              top: 12,
              bottom: 8,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              visualDensity: const ShrinkVisualDensity(),
              trailing: TextButton(
                onPressed: () =>
                    goToSearchPage(context, tag: 'user:${user.name}'),
                child: const Text('View all'),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: ref.watch(danbooruUserUploadsProvider(params)).maybeWhen(
                data: (data) => SliverPreviewPostGrid(
                  posts: data,
                  onTap: (postIdx) => goToPostDetailsPageFromPosts(
                    context: context,
                    posts: data,
                    initialIndex: postIdx,
                  ),
                  imageUrl: (item) => item.url360x360,
                ),
                orElse: () => const SliverPreviewPostGridPlaceholder(),
              ),
        ),
      ],
    );
  }
}
