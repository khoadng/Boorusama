// Project imports:
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';

class DanbooruConfig implements IConfig {
  @override
  String get cheatSheetUrl =>
      "https://danbooru.donmai.us/wiki_pages/help:cheatsheet";

  @override
  Map<String, String> get searchOptionHitns => {
        // "fav": "user",
        "favcount": ">10",
        // "id": "1000, >=1000,",
        // "date": "2007-01-01",
        "age": "2weeks..1year or age:2w..1y",
        "rating": "safe or s,...",
        "score": "100",
      };

  @override
  List<String> get searchOptions => [
        // "fav",
        "favcount",
        // "id",
        // "date",
        "age",
        "rating",
        "score",
      ];
}
