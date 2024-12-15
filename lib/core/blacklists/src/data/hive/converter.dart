// Project imports:
import '../../types/blacklisted_tag.dart';
import 'tag_hive_object.dart';

BlacklistedTagHiveObject convertToHiveObject(BlacklistedTag blacklistedTag) {
  return BlacklistedTagHiveObject(
    name: blacklistedTag.name,
    isActive: blacklistedTag.isActive,
    createdDate: blacklistedTag.createdDate,
    updatedDate: blacklistedTag.updatedDate,
  );
}

BlacklistedTag convertFromHiveObject(BlacklistedTagHiveObject hiveObject) {
  return BlacklistedTag(
    id: hiveObject.key,
    name: hiveObject.name,
    isActive: hiveObject.isActive,
    createdDate: hiveObject.createdDate,
    updatedDate: hiveObject.updatedDate,
  );
}
