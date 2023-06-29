// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/foundation/http/http.dart';
import 'converter.dart';
import 'user.dart';
import 'user_dto.dart';
import 'user_self.dart';
import 'user_self_dto.dart';

List<UserDto> parseUserDtos(
  HttpResponse<dynamic> value,
) =>
    parseResponse(
      value: value,
      converter: (item) => UserDto.fromJson(item),
    );

List<User> parseUsers(List<UserDto> value) => value.map(userDtoToUser).toList();

List<UserSelf> parseUserSelf(
  HttpResponse<dynamic> value,
  List<String> defaultBlacklistedTags,
) =>
    parseResponse(
      value: value,
      converter: (item) => UserSelfDto.fromJson(item),
    ).map((u) => userDtoToUserSelf(u, defaultBlacklistedTags)).toList();
