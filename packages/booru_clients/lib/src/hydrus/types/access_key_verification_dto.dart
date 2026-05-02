const kHydrusSearchFilesPermission = 3;

class AccessKeyVerificationDto {
  const AccessKeyVerificationDto({
    required this.name,
    required this.permitsEverything,
    required this.basicPermissions,
    required this.humanDescription,
  });

  factory AccessKeyVerificationDto.fromJson(Map<String, dynamic> json) {
    return AccessKeyVerificationDto(
      name: json['name'] as String?,
      permitsEverything: json['permits_everything'] as bool? ?? false,
      basicPermissions: switch (json['basic_permissions']) {
        final List list => list.whereType<int>().toSet(),
        _ => const {},
      },
      humanDescription: json['human_description'] as String?,
    );
  }

  final String? name;
  final bool permitsEverything;
  final Set<int> basicPermissions;
  final String? humanDescription;

  bool get canSearchFiles =>
      permitsEverything ||
      basicPermissions.contains(kHydrusSearchFilesPermission);
}
