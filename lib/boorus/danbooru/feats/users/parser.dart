// Project imports:
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'converter.dart';
import 'user.dart';

List<DanbooruUser> parseUsers(List<UserDto> value) =>
    value.map(userDtoToUser).toList();
