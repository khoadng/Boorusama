// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../pool/types.dart';

final danbooruSelectedPoolCategoryProvider =
    StateProvider<DanbooruPoolCategory>((ref) => DanbooruPoolCategory.series);

final danbooruSelectedPoolOrderProvider = StateProvider<DanbooruPoolOrder>(
  (ref) => DanbooruPoolOrder.latest,
);
