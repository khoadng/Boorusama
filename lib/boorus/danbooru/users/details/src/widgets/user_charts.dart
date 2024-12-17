// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../reports/report.dart';
import '../providers/local_providers.dart';
import '../types/upload_date_range_selector_type.dart';

class UserUploadDailyDeltaChart extends ConsumerWidget {
  const UserUploadDailyDeltaChart({
    super.key,
    required this.data,
  });

  final List<DanbooruReportDataPoint> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titles = <int, String>{};
    final dateRange = ref.watch(selectedUploadDateRangeSelectorTypeProvider);
    final isWeeklyChart = dateRange == UploadDateRangeSelectorType.last7Days;
    final isMonthlyChart = dateRange == UploadDateRangeSelectorType.last30Days;
    final isYearlyChart = dateRange == UploadDateRangeSelectorType.lastYear;

    if (isWeeklyChart) {
      // Sep 5 7 9 11 13
      for (var i = 0; i < data.length; i++) {
        // if it's the first day, show the month e.g. Sep 5
        if (i == 0) {
          titles[i] =
              '${parseIntToMonthString(data[i].date.month)} ${data[i].date.day}';
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
              '${parseIntToMonthString(data[i].date.month)} ${data[i].date.day}';
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
            titles[i] = parseIntToMonthString(month);
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
          titles[i] = parseIntToMonthString(month);
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
            getTooltipColor: (_) =>
                Theme.of(context).colorScheme.surfaceContainerHighest,
            fitInsideHorizontally: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = data[groupIndex].date;
              return BarTooltipItem(
                '${date.day}/${date.month}/${date.year}',
                Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ) ??
                    const TextStyle(),
                children: [
                  TextSpan(
                    text: '\n${rod.toY.toInt()} posts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
                axisSide: meta.axisSide,
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
                      UploadDateRangeSelectorType.last7Days => 28,
                      UploadDateRangeSelectorType.last30Days => 8,
                      UploadDateRangeSelectorType.last3Months => 2.5,
                      UploadDateRangeSelectorType.last6Months => 1.25,
                      UploadDateRangeSelectorType.lastYear => 0.75,
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
