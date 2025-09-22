// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

class StorageSegment {
  const StorageSegment({
    required this.name,
    required this.size,
    required this.color,
    this.subtitle,
  });

  final String name;
  final int size;
  final Color color;
  final String? subtitle;
}

class StorageSegmentBar extends StatelessWidget {
  const StorageSegmentBar({
    required this.segments,
    required this.totalSpace,
    this.title,
    this.subtitle,
    super.key,
    this.height = 8,
    this.borderRadius = 4,
  });

  final String? title;
  final String? subtitle;
  final List<StorageSegment> segments;
  final int totalSpace;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title case final title?)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 4,
            ),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (subtitle case final subtitle?)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 4,
            ),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 8),
        _buildSegmentBar(context),
        const SizedBox(height: 12),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildSegmentBar(BuildContext context) {
    if (totalSpace <= 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: segments.map((segment) {
          final percentage = segment.size / totalSpace;
          final width = math.max(percentage, 0);

          return Expanded(
            flex: (width * 1000).round(),
            child: Container(
              color: segment.color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final visibleSegments = segments.where((s) => s.size > 0).toList();

    if (visibleSegments.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: visibleSegments.map((segment) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: segment.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  segment.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (segment.subtitle != null)
                  Text(
                    segment.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}
