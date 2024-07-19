// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/users.dart';

class DanbooruPostVersion extends Equatable {
  final int id;
  final int postId;
  final String tags;
  final List<String> addedTags;
  final List<String> removedTags;
  final int updaterId;
  final DateTime updatedAt;
  final String rating;
  final bool ratingChanged;
  final int? parentId;
  final bool parentChanged;
  final String source;
  final bool sourceChanged;
  final int version;
  final String obsoleteAddedTags;
  final String obsoleteRemovedTags;
  final String unchangedTags;

  final Creator updater;

  const DanbooruPostVersion({
    required this.id,
    required this.postId,
    required this.tags,
    required this.addedTags,
    required this.removedTags,
    required this.updaterId,
    required this.updatedAt,
    required this.rating,
    required this.ratingChanged,
    required this.parentId,
    required this.parentChanged,
    required this.source,
    required this.sourceChanged,
    required this.version,
    required this.obsoleteAddedTags,
    required this.obsoleteRemovedTags,
    required this.unchangedTags,
    required this.updater,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        tags,
        addedTags,
        removedTags,
        updaterId,
        updatedAt,
        rating,
        ratingChanged,
        parentId,
        parentChanged,
        source,
        sourceChanged,
        version,
        obsoleteAddedTags,
        obsoleteRemovedTags,
        unchangedTags,
        updater,
      ];
}
