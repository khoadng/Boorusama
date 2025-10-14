// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../reports/types.dart';
import '../providers/local_providers.dart';
import '../types/upload_date_range.dart';

class UserUploadDailyDeltaChart extends ConsumerWidget {
  const UserUploadDailyDeltaChart({
    required this.data,
    super.key,
  });

  final List<DanbooruReportDataPoint> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final titles = <int, String>{};
    final dateRange = ref.watch(selectedUploadDateRangeSelectorTypeProvider);
    final isWeeklyChart = dateRange == UploadDateRange.last7Days;
    final isMonthlyChart = dateRange == UploadDateRange.last30Days;
    final isYearlyChart = dateRange == UploadDateRange.lastYear;

    if (isWeeklyChart) {
      // Sep 5 7 9 11 13
      for (var i = 0; i < data.length; i++) {
        // if it's the first day, show the month e.g. Sep 5
        if (i == 0) {
          titles[i] =
              '${parseIntToMonthString(data[i].date.month, context)} ${data[i].date.day}';
        } else {
          titles[i] = data[i].date.day.toString();
        }
      }
    } else if (isMonthlyChart) {
      // Sep 5 12 19 26
      var skipCounter = 0;
      for (var i = 0; i < data.length; i++) {
        if (skipCounter == 6 || i == 0) {
          titles[i] =
              '${parseIntToMonthString(data[i].date.month, context)} ${data[i].date.day}';
          skipCounter = 0;
        } else {
          titles[i] = '';
          skipCounter++;
        }
      }
    } else if (isYearlyChart) {
      // Sep Dec Mar Jun
      if (data.isNotEmpty) {
        final firstMonth = data.first.date.month;

        final showMonths = {
          for (var i = 0; i < 4; i++)
            (firstMonth + i * 3) % 12 == 0 ? 12 : (firstMonth + i * 3) % 12,

          // always include today's month
          DateTime.now().month,
        };

        final seen = <int>{};

        for (var i = 0; i < data.length; i++) {
          final month = data[i].date.month;
          if (showMonths.contains(month) && !seen.contains(month)) {
            titles[i] = parseIntToMonthString(month, context);
            seen.add(month);
          } else {
            titles[i] = '';
          }
        }
      }
    } else {
      final seen = <int>{};

      for (var i = 0; i < data.length; i++) {
        final month = data[i].date.month;
        if (!seen.contains(month)) {
          titles[i] = parseIntToMonthString(month, context);
          seen.add(data[i].date.month);
        } else {
          titles[i] = '';
        }
      }
    }

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => colorScheme.surfaceContainerHighest,
            fitInsideHorizontally: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = data[groupIndex].date;
              return BarTooltipItem(
                '${date.day}/${date.month}/${date.year}',
                textTheme.bodySmall?.copyWith(
                      color: textTheme.bodyLarge?.color,
                    ) ??
                    const TextStyle(),
                children: [
                  TextSpan(
                    text: '\n${context.t.uploads.counter(n: rod.toY.toInt())}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 30,
              showTitles: true,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  titles[value.toInt()]!,
                ),
              ),
            ),
          ),
        ),
        barGroups: data
            .mapIndexed(
              (idx, e) => BarChartGroupData(
                x: idx,
                barRods: [
                  BarChartRodData(
                    width: switch (dateRange) {
                      UploadDateRange.last7Days => 28,
                      UploadDateRange.last30Days => 8,
                      UploadDateRange.last3Months => 2.5,
                      UploadDateRange.last6Months => 1.25,
                      UploadDateRange.lastYear => 0.75,
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(1),
                      topRight: Radius.circular(1),
                    ),
                    toY: e.postCount.toDouble(),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

String parseIntToMonthString(int value, BuildContext context) =>
    switch (value) {
      1 => context.t.time.months.short.jan,
      2 => context.t.time.months.short.feb,
      3 => context.t.time.months.short.mar,
      4 => context.t.time.months.short.apr,
      5 => context.t.time.months.short.may,
      6 => context.t.time.months.short.jun,
      7 => context.t.time.months.short.jul,
      8 => context.t.time.months.short.aug,
      9 => context.t.time.months.short.sep,
      10 => context.t.time.months.short.oct,
      11 => context.t.time.months.short.nov,
      12 => context.t.time.months.short.dec,
      _ => '',
    };
