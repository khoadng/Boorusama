// Project imports:
import '../../../foundation/path.dart';

String sanitizedExtension(String url) {
  return extension(sanitizedUrl(url));
}

String sanitizedUrl(String url) {
  final indexOfQuestionMark = url.indexOf('?');

  if (indexOfQuestionMark != -1) {
    return url.substring(0, indexOfQuestionMark);
  } else {
    return url;
  }
}
