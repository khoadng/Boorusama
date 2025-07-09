// Package imports:
import 'package:collection/collection.dart';

import 'package:booru_clients/src/hydrus/types/service_dto.dart';

class FileDto {
  const FileDto({
    required this.fileId,
    required this.hash,
    required this.size,
    required this.mime,
    required this.filetypeForced,
    required this.filetypeHuman,
    required this.filetypeEnum,
    required this.ext,
    required this.width,
    required this.height,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.duration,
    required this.timeModified,
    required this.timeModifiedDetails,
    required this.fileServices,
    required this.ipfsMultihashes,
    required this.hasAudio,
    required this.blurhash,
    required this.pixelHash,
    required this.numFrames,
    required this.numWords,
    required this.isInbox,
    required this.isLocal,
    required this.isTrashed,
    required this.isDeleted,
    required this.hasExif,
    required this.hasHumanReadableEmbeddedMetadata,
    required this.hasIccProfile,
    required this.hasTransparency,
    required this.knownUrls,
    required this.ratings,
    required this.tags,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.faved,
  });

  factory FileDto.fromJson(
    Map<String, dynamic> json,
    String baseUrl,
    Map<String, dynamic> servicesJson,
  ) {
    final fileId = json['file_id'] as int?;
    final imageUrl = baseUrl.endsWith('/')
        ? '${baseUrl}get_files/file?file_id=$fileId'
        : '$baseUrl/get_files/file?file_id=$fileId';

    final thumbnailUrl = baseUrl.endsWith('/')
        ? '${baseUrl}get_files/thumbnail?file_id=$fileId'
        : '$baseUrl/get_files/thumbnail?file_id=$fileId';

    final services = servicesJson.entries
        .map((e) => ServiceDto.fromJson(e.value, e.key))
        .toList();

    final ratings = json['ratings'] as Map<String, dynamic>?;

    final favServiceKey = getLikeDislikeRatingKey(services);

    final useFavService =
        ratings != null &&
        favServiceKey != null &&
        ratings.containsKey(favServiceKey);

    final faved = useFavService ? ratings[favServiceKey] == true : null;

    return FileDto(
      fileId: fileId,
      hash: json['hash'] as String?,
      size: json['size'] as int?,
      mime: json['mime'] as String?,
      filetypeForced: json['filetype_forced'] as bool?,
      filetypeHuman: json['filetype_human'] as String?,
      filetypeEnum: json['filetype_enum'] as int?,
      ext: json['ext'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      thumbnailWidth: json['thumbnail_width'] as int?,
      thumbnailHeight: json['thumbnail_height'] as int?,
      duration: json['duration'] as int?,
      timeModified: json['time_modified'] as int?,
      timeModifiedDetails:
          json['time_modified_details'] as Map<String, dynamic>?,
      fileServices: json['file_services'] as Map<String, dynamic>?,
      ipfsMultihashes: json['ipfs_multihashes'] as Map<String, dynamic>?,
      hasAudio: json['has_audio'] as bool?,
      blurhash: json['blurhash'] as String?,
      pixelHash: json['pixel_hash'] as String?,
      numFrames: json['num_frames'] as int?,
      numWords: json['num_words'] as int?,
      isInbox: json['is_inbox'] as bool?,
      isLocal: json['is_local'] as bool?,
      isTrashed: json['is_trashed'] as bool?,
      isDeleted: json['is_deleted'] as bool?,
      hasExif: json['has_exif'] as bool?,
      hasHumanReadableEmbeddedMetadata:
          json['has_human_readable_embedded_metadata'] as bool?,
      hasIccProfile: json['has_icc_profile'] as bool?,
      hasTransparency: json['has_transparency'] as bool?,
      knownUrls: json['known_urls'] != null
          ? List<String>.from(json['known_urls'])
          : null,
      ratings: ratings,
      tags: (json['tags'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as Map<String, dynamic>),
      ),
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      faved: faved,
    );
  }

  final int? fileId;
  final String? hash;
  final int? size;
  final String? mime;
  final bool? filetypeForced;
  final String? filetypeHuman;
  final int? filetypeEnum;
  final String? ext;
  final int? width;
  final int? height;
  final int? thumbnailWidth;
  final int? thumbnailHeight;
  final int? duration;
  final int? timeModified;
  final Map<String, dynamic>? timeModifiedDetails;
  final Map<String, dynamic>? fileServices;
  final Map<String, dynamic>? ipfsMultihashes;
  final bool? hasAudio;
  final String? blurhash;
  final String? pixelHash;
  final int? numFrames;
  final int? numWords;
  final bool? isInbox;
  final bool? isLocal;
  final bool? isTrashed;
  final bool? isDeleted;
  final bool? hasExif;
  final bool? hasHumanReadableEmbeddedMetadata;
  final bool? hasIccProfile;
  final bool? hasTransparency;
  final List<String>? knownUrls;
  final Map<String, dynamic>? ratings;
  final Map<String, Map<String, dynamic>>? tags;

  final String imageUrl;
  final String thumbnailUrl;
  final bool? faved;
}

extension FileDtoX on FileDto {
  Set<String> get allTags {
    // join all storage tags
    final storageTags = tags?.values
        .map(
          (e) => e['storage_tags'] != null
              ? e['storage_tags'] as Map<String, dynamic>
              : null,
        )
        .nonNulls
        .expand((e) => e.values)
        .expand((e) => e)
        .toList();

    if (storageTags == null) return {};

    return {
      for (final tag in storageTags) tag as String,
    };
  }

  String? get firstSource {
    final sources = knownUrls;
    if (sources == null) return null;

    return sources.firstOrNull;
  }
}

String? getLikeDislikeRatingKey(List<ServiceDto?>? services) {
  if (services == null) return null;

  final favService = services.firstWhereOrNull(
    (e) => e?.type == ServiceType.likeDislikeRatingService,
  );

  if (favService == null) return null;

  return favService.key;
}
