class NumericScoreVoteDto {
  NumericScoreVoteDto({
    this.score,
    this.userName,
    this.userId,
  });

  factory NumericScoreVoteDto.fromGraphQL(Map<String, dynamic> json) {
    final user = switch (json['user']) {
      final Map<String, dynamic> u => u,
      _ => null,
    };

    return NumericScoreVoteDto(
      score: switch (json['score']) {
        final num n => n.toInt(),
        _ => null,
      },
      userName: switch (user?['name']) {
        final String s => s,
        _ => null,
      },
      userId: switch (user?['id']) {
        final num n => n.toInt(),
        _ => null,
      },
    );
  }

  final int? score;
  final String? userName;
  final int? userId;
}
