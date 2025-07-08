// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/theme/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../creator/providers.dart';
import '../../../user/providers.dart';
import '../providers/providers.dart';
import '../types/user_feedback.dart';

class UserFeedbackPage extends ConsumerStatefulWidget {
  const UserFeedbackPage({
    required this.userId,
    super.key,
  });

  final int userId;

  @override
  ConsumerState<UserFeedbackPage> createState() => _UserFeedbackPageState();
}

class _UserFeedbackPageState extends ConsumerState<UserFeedbackPage> {
  late final _pagingController = PagingController(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: _fetchPage,
  );

  @override
  void dispose() {
    _pagingController.dispose();

    super.dispose();
  }

  Future<List<DanbooruUserFeedback>> _fetchPage(int pageKey) async {
    try {
      final config = ref.readConfigAuth;
      final repo = ref.read(danbooruUserFeedbackRepoProvider(config));
      final feedbacks = await repo.getUserFeedbacks(userId: widget.userId);

      // Load creators
      final creatorsNotifier = ref.read(
        danbooruCreatorsProvider(config).notifier,
      );
      await creatorsNotifier.load(feedbacks.map((e) => e.creatorId).toList());

      return feedbacks;
    } catch (error) {
      return Future.error('Error fetching user feedbacks: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Feedbacks'.hc),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        child: PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) => PagedListView(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<DanbooruUserFeedback>(
              itemBuilder: (context, feedback, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: _UserFeedbackItem(feedback: feedback),
              ),
              firstPageProgressIndicatorBuilder: (context) => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              noItemsFoundIndicatorBuilder: (context) => const NoDataBox(),
              firstPageErrorIndicatorBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading feedbacks'.hc),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _pagingController.refresh(),
                      child: Text('Retry'.hc),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserFeedbackItem extends ConsumerWidget {
  const _UserFeedbackItem({
    required this.feedback,
  });

  final DanbooruUserFeedback feedback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.readConfigAuth;
    final creator = ref.watch(
      danbooruCreatorsProvider(
        config,
      ).select((value) => value[feedback.creatorId]),
    );

    final creatorColor = DanbooruUserColor.of(
      context,
    ).fromLevel(creator?.level);
    final colors = ref.watch(booruChipColorsProvider).fromColor(creatorColor);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CompactChip(
                  label:
                      creator?.name.replaceAll('_', ' ') ??
                      'User #${feedback.creatorId}',
                  backgroundColor: colors?.backgroundColor,
                  textColor: colors?.foregroundColor,
                ),
                const SizedBox(width: 8),
                _buildCategoryLabel(context),
                const Spacer(),
                Text(
                  feedback.createdAt.fuzzify(
                    locale: Localizations.localeOf(context),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.hintColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.body),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLabel(BuildContext context) {
    final (color, label) = switch (feedback.category) {
      UserFeedbackCategory.positive => (Colors.green, 'Positive'),
      UserFeedbackCategory.negative => (Colors.red, 'Negative'),
      UserFeedbackCategory.neutral => (Colors.grey, 'Neutral'),
    };

    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
