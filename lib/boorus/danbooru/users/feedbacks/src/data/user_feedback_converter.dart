// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/user_feedback.dart';

DanbooruUserFeedback userFeedbackDtoToUserFeedback(UserFeedbackDto dto) =>
    DanbooruUserFeedback(
      id: dto.id ?? 0,
      userId: dto.userId ?? 0,
      creatorId: dto.creatorId ?? 0,
      body: dto.body ?? '',
      category: UserFeedbackCategory.fromString(dto.category),
      createdAt: DateTime.tryParse(dto.createdAt ?? '') ?? DateTime(1),
      updatedAt: DateTime.tryParse(dto.updatedAt ?? '') ?? DateTime(1),
      isDeleted: dto.isDeleted ?? false,
    );

List<DanbooruUserFeedback> userFeedbackDtosToUserFeedbacks(
  List<UserFeedbackDto> dtos,
) =>
    dtos.map(userFeedbackDtoToUserFeedback).toList();
