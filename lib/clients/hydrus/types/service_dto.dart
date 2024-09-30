// 0 - tag repository
// 1 - file repository
// 2 - a local file domain like 'my files'
// 5 - a local tag domain like 'my tags'
// 6 - a 'numerical' rating service with several stars
// 7 - a 'like/dislike' rating service with on/off status
// 10 - all known tags -- a union of all the tag services
// 11 - all known files -- a union of all the file services and files that appear in tag services
// 12 - the local booru -- you can ignore this
// 13 - IPFS
// 14 - trash
// 15 - all local files -- all files on hard disk ('all my files' + updates + trash)
// 17 - file notes
// 18 - Client API
// 19 - deleted from anywhere -- you can ignore this
// 20 - local updates -- a file domain to store repository update files in
// 21 - all my files -- union of all local file domains
// 22 - a 'inc/dec' rating service with positive integer rating
// 99 - server administration

enum ServiceType {
  tagRepository,
  fileRepository,
  localFileDomain,
  localTagDomain,
  numericalRatingService,
  likeDislikeRatingService,
  allKnownTags,
  allKnownFiles,
  localBooru,
  ipfs,
  trash,
  allLocalFiles,
  fileNotes,
  clientApi,
  deletedFromAnywhere,
  localUpdates,
  allMyFiles,
  incDecRatingService,
  serverAdministration,
}

ServiceType? intToServiceType(int? value) => switch (value) {
      0 => ServiceType.tagRepository,
      1 => ServiceType.fileRepository,
      2 => ServiceType.localFileDomain,
      5 => ServiceType.localTagDomain,
      6 => ServiceType.numericalRatingService,
      7 => ServiceType.likeDislikeRatingService,
      10 => ServiceType.allKnownTags,
      11 => ServiceType.allKnownFiles,
      12 => ServiceType.localBooru,
      13 => ServiceType.ipfs,
      14 => ServiceType.trash,
      15 => ServiceType.allLocalFiles,
      17 => ServiceType.fileNotes,
      18 => ServiceType.clientApi,
      19 => ServiceType.deletedFromAnywhere,
      20 => ServiceType.localUpdates,
      21 => ServiceType.allMyFiles,
      22 => ServiceType.incDecRatingService,
      99 => ServiceType.serverAdministration,
      _ => null,
    };

class ServiceDto {
  final String key;
  final String name;
  final ServiceType type;
  final String prettyType;

  ServiceDto({
    required this.key,
    required this.name,
    required this.type,
    required this.prettyType,
  });

  static ServiceDto? fromJson(Map<String, dynamic> json, String key) {
    final rawType = json['type'] as int?;
    if (rawType == null) return null;
    final type = intToServiceType(rawType);
    if (type == null) return null;

    final prettyType =
        json['type_pretty'] != null ? json['type_pretty'] as String : '';

    return ServiceDto(
      key: key,
      name: json['name'] as String,
      type: type,
      prettyType: prettyType,
    );
  }
}
