// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/details/widgets.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/search/search/routes.dart';
import '../../../../../../core/tags/categories/types.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/themes/theme/types.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/platform.dart';
import '../../../../../../foundation/utils/flutter_utils.dart';
import '../../../../posts/post/types.dart';
import '../../../../tags/related/types.dart';
import '../../../user/types.dart';
import '../providers/local_providers.dart';
import '../types/report_data_params.dart';
import '../widgets/upload_date_range_selector_button.dart';
import '../widgets/user_charts.dart';

const _kTopCopyrigthTags = 5;

class UserDetailsUploadView extends ConsumerWidget {
  const UserDetailsUploadView({
    required this.uid,
    required this.username,
    required this.isSelf,
    required this.user,
    super.key,
  });

  final int uid;
  final String username;
  final bool isSelf;
  final DanbooruUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) => PostDetailsSheetConstraints(
        maxWidth: constraints.maxWidth,
        child: CustomScrollView(
          slivers: [
            if (user.uploadCount > 0)
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
                            DanbooruReportDataParams.forUser(user),
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
                                      context.t.uploads.counter(
                                        n: data.sumBy((e) => e.postCount),
                                      ),
                                      style: textTheme.titleMedium!.copyWith(
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
            if (user.uploadCount > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.t.profile.uploads.top_n_copyright(
                          n: _kTopCopyrigthTags,
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ref
                          .watch(
                            userCopyrightDataProvider(
                              (
                                username: username,
                                uploadCount: user.uploadCount,
                              ),
                            ),
                          )
                          .maybeWhen(
                            data: (data) => _buildTags(
                              ref,
                              data.tags.take(_kTopCopyrigthTags).toList(),
                            ),
                            orElse: () => _buildPlaceHolderTags(context),
                          ),
                    ],
                  ),
                ),
              ),
            SliverUploadPostList(
              title: context.t.profile.tabs.uploads,
              user: user,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceHolderTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: isDesktopPlatform() ? 4 : 0,
      children:
          [
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

  Widget _buildTags(WidgetRef ref, List<DanbooruRelatedTagItem> tags) {
    final context = ref.context;
    final brightness = Theme.of(context).brightness;
    return Wrap(
      spacing: 8,
      runSpacing: isDesktopPlatform() ? 4 : 0,
      children: tags
          .map(
            (e) => BooruChip(
              visualDensity: VisualDensity.compact,
              color: ref.watch(
                tagColorProvider(
                  (ref.watchConfigAuth, TagCategory.copyright().name),
                ),
              ),
              onPressed: () => goToSearchPage(
                ref,
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
                      color: brightness.isDark
                          ? ref.watch(
                              tagColorProvider(
                                (
                                  ref.watchConfigAuth,
                                  TagCategory.copyright().name,
                                ),
                              ),
                            )
                          : Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: '  ${(e.frequency * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: brightness.isLight
                              ? Colors.white.withValues(alpha: 0.85)
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
    required this.title,
    required this.user,

    super.key,
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
                onPressed: () => goToSearchPage(ref, tag: 'user:${user.name}'),
                child: Text(context.t.generic.action.view_all),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: ref
              .watch(danbooruUserUploadsProvider(params))
              .maybeWhen(
                data: (data) => SliverPreviewPostGrid(
                  posts: data,
                  auth: ref.watchConfigAuth,
                  imageUrl: (item) => item.url360x360,
                ),
                orElse: () => const SliverPreviewPostGridPlaceholder(),
              ),
        ),
      ],
    );
  }
}
