// Project imports:
import 'tag.dart';

extension TagDisplayX on Tag {
  String get displayName => name.replaceAll('_', ' ');
  String get rawName => name;
}
