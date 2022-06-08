class Artist {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String groupName;
  final bool isBanned;
  final List<String> otherNames;
  final String name;

  Artist({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isBanned,
    required this.groupName,
    required this.isDeleted,
    required this.otherNames,
    required this.name,
  });

  factory Artist.empty() => Artist(
        createdAt: DateTime.now(),
        id: 0,
        name: "",
        groupName: "",
        isBanned: false,
        isDeleted: false,
        otherNames: [],
        updatedAt: DateTime.now(),
      );
}
