// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTagTypeSelectorProvider = StateProvider<TagType>(
  (ref) => TagType.tag,
);
