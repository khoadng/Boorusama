// Package imports:
import 'package:hive/hive.dart';

class UserMetatagRepository {
  UserMetatagRepository({
    required this.box,
  });

  final Box<String> box;

  Future<void> put(String tag) => box.put(tag, tag);
  Future<void> delete(String tag) => box.delete(tag);

  List<String> getAll() => box.values.toList();
}
