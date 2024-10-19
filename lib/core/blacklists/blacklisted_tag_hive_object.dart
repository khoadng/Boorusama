// Package imports:
import 'package:hive/hive.dart';

part 'blacklisted_tag_hive_object.g.dart';

@HiveType(typeId: 3)
class BlacklistedTagHiveObject extends HiveObject {

  BlacklistedTagHiveObject({
    required this.name,
    required this.isActive,
    required this.createdDate,
    required this.updatedDate,
  });
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isActive;

  @HiveField(2)
  DateTime createdDate;

  @HiveField(3)
  DateTime updatedDate;
}
