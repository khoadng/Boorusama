// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/search/queries/types.dart';

final sankakuTagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
      (ref, config) => SankakuTagQueryComposer(config: config),
    );

class SankakuTagQueryComposer extends DefaultTagQueryComposer {
  SankakuTagQueryComposer({required super.config});

  static final _singleDate = RegExp(r'^date:(\d{8}|\d{4}-\d{2}-\d{2})$');

  @override
  List<String> compose(List<String> tags) =>
      super.compose(tags).map(_normalizeDate).toList();

  String _normalizeDate(String tag) {
    final match = _singleDate.firstMatch(tag);
    if (match == null) return tag;

    final value = match.group(1)!.replaceAll('-', '');
    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(4, 6));
    final day = int.parse(value.substring(6, 8));
    final date = DateTime.utc(year, month, day);
    if (year == 0 ||
        date.year != year ||
        date.month != month ||
        date.day != day) {
      return tag;
    }

    final nextDay = date.add(const Duration(days: 1));
    if (nextDay.year > 9999) return tag;

    // Sankaku rejects single dates but accepts a range spanning the UTC day.
    return 'date:${_formatDate(date)}..${_formatDate(nextDay)}';
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
