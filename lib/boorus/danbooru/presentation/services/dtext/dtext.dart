// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/widgets/non_quote.dart';
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/widgets/quote.dart';

// ignore: avoid_classes_with_only_static_members
class Dtext {
  static Widget parse(String content, String startString, String endString) {
    final widgets = <Widget>[];
    var target = content;
    while (target.isNotEmpty) {
      final start = target.indexOf(startString);

      if (!start.isNegative) {
        final end = target.indexOf(endString);
        if (!end.isNegative) {
          final text = target.substring(start + startString.length, end);
          widgets.add(Quote(text: text));
          target = target.substring(end + endString.length);
        } else {
          widgets.add(NonQuote(text: target.trimLeft()));
          break;
        }
      } else {
        widgets.add(NonQuote(text: target.trimLeft()));
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
