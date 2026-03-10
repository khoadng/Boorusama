// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/listing/widgets.dart';
import '../../../core/posts/post/types.dart';
import '../../../core/themes/theme/types.dart';
import '../../../core/users/widgets.dart';
import '../../../core/widgets/widgets.dart';
import '../../../foundation/clipboard.dart';
import '../client_provider.dart';
import '../posts/parser.dart' as parser;
import 'providers.dart';
import 'types.dart';

class EshuushuuUserDetailsPage extends ConsumerWidget {
  const EshuushuuUserDetailsPage({
    required this.userId,
    this.username,
    super.key,
  });

  final int userId;
  final String? username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return UserDetailsPage(
      actions: [
        BooruPopupMenuButton(
          items: [
            BooruPopupMenuItem(
              title: Text(context.t.profile.copy_user_id),
              onTap: () => AppClipboard.copy(userId.toString()),
            ),
          ],
        ),
      ],
      body: ref
          .watch(eshuushuuUserProvider((config, userId)))
          .when(
            data: (user) {
              if (user == null) {
                return Center(
                  child: Text(context.t.profile.fail_to_load_profile),
                );
              }

              return _EshuushuuUserDetailsBody(user: user);
            },
            error: (_, _) => Center(
              child: Text(context.t.profile.fail_to_load_profile),
            ),
            loading: () => _buildLoading(context),
          ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return UserDetailsViewScaffold(
      sliverInfoOverview: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                username ?? '...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: const Center(
        child: SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _EshuushuuUserDetailsBody extends StatelessWidget {
  const _EshuushuuUserDetailsBody({
    required this.user,
  });

  final EshuushuuUser user;

  @override
  Widget build(BuildContext context) {
    final tabMap = {
      context.t.profile.tabs.info: _EshuushuuUserInfoView(user: user),
      if (user.hasUploads)
        context.t.profile.tabs.uploads: _EshuushuuUserPostsTab(
          userId: user.id,
          isUploads: true,
        ),
      if (user.hasFavorites)
        context.t.profile.favorites: _EshuushuuUserPostsTab(
          userId: user.id,
          isUploads: false,
        ),
    };

    return UserDetailsViewScaffold(
      sliverInfoOverview: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _EshuushuuUserOverview(user: user),
        ),
      ),
      body: DefaultTabController(
        length: tabMap.length,
        child: Column(
          children: [
            TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              isScrollable: true,
              tabs: [
                for (final tab in tabMap.keys) Tab(text: tab),
              ],
            ),
            const Divider(thickness: 1, height: 0),
            Expanded(
              child: TabBarView(
                children: [
                  for (final tab in tabMap.values) tab,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EshuushuuUserOverview extends StatelessWidget {
  const _EshuushuuUserOverview({required this.user});

  final EshuushuuUser user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMd(locale);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            image: switch (user.avatarUrl) {
              final String url => DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
              _ => null,
            },
          ),
          child: user.avatarUrl == null
              ? Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 24,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (user.userTitle case final title?) ...[
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(color: colorScheme.hintColor),
                ),
              ],
              const SizedBox(height: 4),
              _buildDatesRow(context, dateFormat),
              if (user.isAdmin) ...[
                const SizedBox(height: 6),
                Chip(
                  label: Text(
                    'Admin',
                    style: TextStyle(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: colorScheme.secondaryContainer,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatesRow(BuildContext context, DateFormat dateFormat) {
    final hintColor = Theme.of(context).colorScheme.hintColor;
    final hintStyle = TextStyle(color: hintColor, fontSize: 12);
    final t = context.t.eshuushuu.profile;

    final parts = <Widget>[];

    if (user.dateJoined case final joined?) {
      parts.add(
        Text(
          '${t.joined}: ${dateFormat.format(joined)}',
          style: hintStyle,
        ),
      );
    }

    if (user.lastActive case final lastActive?) {
      if (parts.isNotEmpty) {
        parts.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('•', style: hintStyle),
          ),
        );
      }
      parts.add(
        Text(
          '${t.last_active}: ${dateFormat.format(lastActive)}',
          style: hintStyle,
        ),
      );
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(children: parts);
  }
}

class _EshuushuuUserInfoView extends StatelessWidget {
  const _EshuushuuUserInfoView({required this.user});

  final EshuushuuUser user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _StatCard(
                  title: context.t.profile.activity.title,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatsItem(
                        count: user.uploadCount,
                        label: context.t.profile.activity.uploads,
                      ),
                      _StatsItem(
                        count: user.favoriteCount,
                        label: context.t.profile.favorites,
                      ),
                      _StatsItem(
                        count: user.forumPostCount,
                        label: context.t.profile.activity.forum_posts,
                      ),
                    ],
                  ),
                ),
                if (user.hasPersonalInfo) ...[
                  const SizedBox(height: 16),
                  _PersonalInfoCard(user: user),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatsItem extends StatelessWidget {
  const _StatsItem({
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          NumberFormat.compact().format(count),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.hintColor),
        ),
      ],
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({required this.user});

  final EshuushuuUser user;

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).colorScheme.hintColor;

    final t = context.t.eshuushuu.personal_info;

    return _StatCard(
      title: t.title,
      child: Column(
        children: [
          if (user.gender case final gender?)
            _InfoRow(label: '${t.gender}:', value: gender),
          if (user.location case final location?)
            _InfoRow(label: '${t.location}:', value: location),
          if (user.website case final website?)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${t.website}:',
                    style: TextStyle(color: hintColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => launchUrl(
                        Uri.parse(website),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              website,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (user.interests case final interests?)
            _InfoRow(label: '${t.interests}:', value: interests),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _EshuushuuUserPostsTab extends ConsumerWidget {
  const _EshuushuuUserPostsTab({
    required this.userId,
    required this.isUploads,
  });

  final int userId;
  final bool isUploads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final client = ref.watch(eshuushuuClientProvider(config));

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => TaskEither.Do(($) async {
          final dtos = await client.getPosts(
            userId: isUploads ? userId : null,
            favoritedByUserId: isUploads ? null : userId,
            page: page,
          );

          final posts = dtos
              .map((dto) => parser.postDtoToPost(dto, null))
              .toList();

          return posts.toResult();
        }),
        builder: (context, controller) => PostGrid(
          controller: controller,
        ),
      ),
    );
  }
}
