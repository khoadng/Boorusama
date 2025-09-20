// Package imports:
import 'package:hive_ce/hive.dart';

class BlacklistedTagHiveObject extends HiveObject {
  BlacklistedTagHiveObject({
    required this.name,
    required this.isActive,
    required this.createdDate,
    required this.updatedDate,
  });

  String name;
  bool isActive;
  DateTime createdDate;
  DateTime updatedDate;
}
