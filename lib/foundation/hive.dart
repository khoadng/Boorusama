// Package imports:
import 'package:hive/hive.dart';

Future<Box<E>?> tryOpenBox<E>(
  String name, {
  String? path,
}) {
  try {
    return Hive.openBox<E>(
      name,
      path: path,
    );
  } catch (e) {
    return Future.value(null);
  }
}
