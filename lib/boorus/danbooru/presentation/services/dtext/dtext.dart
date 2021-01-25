// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/widgets/non_quote.dart';
import 'package:boorusama/boorus/danbooru/presentation/services/dtext/widgets/quote.dart';

class Dtext {
  static Widget parse(String content, String startString, String endString) {
    final widgets = <Widget>[];
    var target = content;
    while (target.isNotEmpty) {
      var start = target.indexOf(startString);

      if (!start.isNegative) {
        var end = target.indexOf(endString);
        if (!end.isNegative) {
          var text = target.substring(start + startString.length, end);
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
