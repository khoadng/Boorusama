// Project imports:
import 'package:boorusama/functional.dart';

Option<Uri> tryParseUrl(String? url) => Option.Do(($) {
      if (url == null) return $(none());
      final uri = Uri.tryParse(url);
      if (uri == null) return $(none());
      return $(some(uri));
    });
