// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

Future<List<DanbooruPostData>> Function(List<DanbooruPostData> posts)
    filterFlashFiles() => filterUnsupportedFormat({'swf'});
