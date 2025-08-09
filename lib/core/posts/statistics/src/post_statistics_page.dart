// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../foundation/utils/statistics.dart';
import 'post_stats.dart';
import 'post_stats_display.dart';

class PostStatisticsPage extends StatelessWidget {
  const PostStatisticsPage({
    required this.totalPosts,
    required this.generalStats,
    super.key,
    this.customStats,
  });

  final int Function() totalPosts;
  final PostStats Function() generalStats;
  final List<Widget>? customStats;

  @override
  Widget build(BuildContext context) {
    final stats = generalStats();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.post.statistics.stats_for_nerds),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'General'.hc,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PostStatsTile(
                title: 'Total posts'.hc,
                value: totalPosts().toString(),
              ),
              const Divider(),
              PostStatsSectionTitle(
                title: 'Score'.hc,
                onMore: () {
                  showAppModalBarBottomSheet(
                    context: context,
                    settings: const RouteSettings(name: 'posts_score_stats'),
                    builder: (context) => StatisticalSummaryDetailsPage(
                      title: 'Score'.hc,
                      stats: stats.scores,
                    ),
                  );
                },
              ),
              PostStatsTile(
                title: 'Average'.hc,
                value:
                    '${stats.scores.mean.toStringAsFixed(1)} ± ${stats.scores.standardDeviation.toStringAsFixed(1)}',
              ),
              const Divider(),
              Text(
                'Rating'.hc,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (stats.generalRatingPercentage > 0)
                PostStatsTile(
                  title: 'General'.hc,
                  value: stats.generalRatingPercentageDisplay,
                ),
              if (stats.sensitiveRatingPercentage > 0)
                PostStatsTile(
                  title: 'Sensitive'.hc,
                  value: stats.sensitiveRatingPercentageDisplay,
                ),
              if (stats.questionableRatingPercentage > 0)
                PostStatsTile(
                  title: 'Questionable'.hc,
                  value: stats.questionableRatingPercentageDisplay,
                ),
              if (stats.explicitRatingPercentage > 0)
                PostStatsTile(
                  title: 'Explicit'.hc,
                  value: stats.explicitRatingPercentageDisplay,
                ),
              const Divider(),
              PostStatsSectionTitle(
                title: 'Source'.hc,
                onMore: () {
                  showAppModalBarBottomSheet(
                    context: context,
                    settings: const RouteSettings(name: 'posts_source_stats'),
                    builder: (context) => StatisticsFromMapPage(
                      title: 'Source'.hc,
                      total: totalPosts(),
                      data: stats.domains.topN(),
                    ),
                  );
                },
              ),
              ...stats.domains
                  .topN(5)
                  .entries
                  .map(
                    (e) => PostStatsTile(
                      title: e.key,
                      value: e.value.toString(),
                    ),
                  ),
              const Divider(),
              Text(
                'Media type'.hc,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              ...stats.mediaTypes.entries
                  .sorted((a, b) => b.value.compareTo(a.value))
                  .map(
                    (e) => PostStatsTile(
                      title: e.key,
                      value: e.value.toString(),
                    ),
                  ),
              const Divider(),
              PostStatsSectionTitle(
                title: 'Tags'.hc,
                onMore: () {
                  showAppModalBarBottomSheet(
                    context: context,
                    settings: const RouteSettings(name: 'posts_tags_stats'),
                    builder: (context) => StatisticalSummaryDetailsPage(
                      title: 'Tags'.hc,
                      stats: stats.tags,
                    ),
                  );
                },
              ),
              PostStatsTile(
                title: 'Average'.hc,
                value:
                    '${stats.tags.mean.toStringAsFixed(1)} ± ${stats.tags.standardDeviation.toStringAsFixed(1)}',
              ),
              if (customStats != null) ...customStats!,
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsFromMapPage extends StatefulWidget {
  const StatisticsFromMapPage({
    required this.total,
    required this.title,
    required this.data,
    super.key,
    this.keyColor,
    this.titleFormatter,
  });

  final String title;
  final Map<String, int> data;
  final int total;
  final Color? keyColor;
  final String? Function(String value)? titleFormatter;

  @override
  State<StatisticsFromMapPage> createState() => _StatisticsFromMapPageState();
}

class _StatisticsFromMapPageState extends State<StatisticsFromMapPage> {
  late var data = _convertToNumber(widget.data);
  var percent = false;

  Map<String, String> _convertToPercentage(Map<String, int> data) {
    return {
      for (final entry in data.entries)
        entry.key:
            '${((entry.value / widget.total) * 100).toStringAsFixed(1)}%',
    };
  }

  Map<String, String> _convertToNumber(Map<String, int> data) {
    return {
      for (final entry in data.entries) entry.key: entry.value.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: [
          // Change to percentage
          IconButton(
            onPressed: () {
              setState(() {
                percent = !percent;
                data = percent
                    ? _convertToPercentage(widget.data)
                    : _convertToNumber(widget.data);
              });
            },
            icon: const Icon(Symbols.change_circle),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final entry = data.entries.elementAt(index);

            return PostStatsTile(
              title: widget.titleFormatter?.call(entry.key) ?? entry.key,
              titleColor: widget.keyColor,
              value: entry.value,
            );
          },
        ),
      ),
    );
  }
}

class PostStatsSectionTitle extends StatelessWidget {
  const PostStatsSectionTitle({
    required this.title,
    required this.onMore,
    super.key,
  });

  final String title;
  final void Function() onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onMore,
          child: Text(
            'More'.hc,
          ),
        ),
      ],
    );
  }
}

class StatisticalSummaryDetailsPage extends StatelessWidget {
  const StatisticalSummaryDetailsPage({
    required this.title,
    required this.stats,
    super.key,
    this.formatter,
  });

  final String title;
  final StatisticalSummary stats;

  final String Function(double value)? formatter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PostStatsTile(
                title: 'Average',
                value:
                    '${formatter?.call(stats.mean) ?? stats.mean.toStringAsFixed(1)} ± ${formatter?.call(stats.standardDeviation) ?? stats.standardDeviation.toStringAsFixed(1)}',
              ),
              PostStatsTile(
                title: 'Highest',
                value:
                    formatter?.call(stats.highest) ??
                    stats.highest.toStringAsFixed(0),
              ),
              PostStatsTile(
                title: 'Lowest',
                value:
                    formatter?.call(stats.lowest) ??
                    stats.lowest.toStringAsFixed(0),
              ),
              const Divider(),
              PostStatsTile(
                title: 'Median',
                value:
                    formatter?.call(stats.median) ??
                    stats.median.toStringAsFixed(0),
              ),
              PostStatsTile(
                title: '25th percentile',
                value:
                    formatter?.call(stats.percentile25) ??
                    stats.percentile25.toStringAsFixed(0),
              ),
              PostStatsTile(
                title: '75th percentile',
                value:
                    formatter?.call(stats.percentile75) ??
                    stats.percentile75.toStringAsFixed(0),
              ),
              PostStatsTile(
                title: '90th percentile',
                value:
                    formatter?.call(stats.percentile90) ??
                    stats.percentile90.toStringAsFixed(0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostStatsTile extends StatelessWidget {
  const PostStatsTile({
    required this.title,
    required this.value,
    super.key,
    this.titleColor,
  });

  final String title;
  final String value;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 160,
              minWidth: 160,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
