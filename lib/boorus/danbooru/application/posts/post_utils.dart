// Project imports:
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/functional.dart';

Option<String> tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? const Some('order:score') : none();
