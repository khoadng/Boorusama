// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'profile.dart';

abstract class IProfileRepository {
  Future<Profile> getProfile({
    CancelToken cancelToken,
    String apiKey,
    String username,
  });
}
