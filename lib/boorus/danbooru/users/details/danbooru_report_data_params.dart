// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../user/user.dart';

class DanbooruReportDataParams extends Equatable {
  const DanbooruReportDataParams({
    required this.username,
    required this.tag,
    required this.uploadCount,
  });

  DanbooruReportDataParams.forUser(
    DanbooruUser user,
  )   : username = user.name,
        tag = 'user:${user.name}',
        uploadCount = user.uploadCount;

  DanbooruReportDataParams withDateRange({
    DateTime? from,
    DateTime? to,
  }) {
    return DanbooruReportDataParams(
      username: username,
      tag: tag,
      uploadCount: uploadCount,
    );
  }

  final String username;
  final String tag;
  final int uploadCount;

  @override
  List<Object?> get props => [username, tag, uploadCount];
}
