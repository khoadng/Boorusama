// Package imports:
import 'package:equatable/equatable.dart';

enum UserFeedbackCategory {
  positive,
  negative,
  neutral;

  factory UserFeedbackCategory.parse(dynamic value) => switch (value) {
    final String str => switch (str.toLowerCase()) {
      'positive' => UserFeedbackCategory.positive,
      'negative' => UserFeedbackCategory.negative,
      'neutral' => UserFeedbackCategory.neutral,
      _ => UserFeedbackCategory.neutral,
    },
    _ => UserFeedbackCategory.neutral,
  };
}

class DanbooruUserFeedback extends Equatable {
  const DanbooruUserFeedback({
    required this.id,
    required this.userId,
    required this.creatorId,
    required this.body,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory DanbooruUserFeedback.placeholder() => const DanbooruUserFeedback(
    id: 0,
    userId: 0,
    creatorId: 0,
    body: '',
    category: UserFeedbackCategory.neutral,
    createdAt: null,
    updatedAt: null,
    isDeleted: false,
  );

  final int id;
  final int userId;
  final int creatorId;
  final String body;
  final UserFeedbackCategory category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  @override
  List<Object?> get props => [
    id,
    userId,
    creatorId,
    body,
    category,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}

extension DanbooruUserFeedbackX on DanbooruUserFeedback {
  DanbooruUserFeedback copyWith({
    int? id,
    int? userId,
    int? creatorId,
    String? body,
    UserFeedbackCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) => DanbooruUserFeedback(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    creatorId: creatorId ?? this.creatorId,
    body: body ?? this.body,
    category: category ?? this.category,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
}

abstract class DanbooruUserFeedbacksRepository {
  Future<List<DanbooruUserFeedback>> getUserFeedbacks({
    required int userId,
    int? limit,
    int? page,
  });
}
