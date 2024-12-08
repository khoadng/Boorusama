// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/boorus/booru_type.dart';
import 'booru_config.dart';

class EditBooruConfigId extends Equatable {
  const EditBooruConfigId({
    required this.id,
    required this.booruType,
    required this.url,
  });

  const EditBooruConfigId.newId({
    required BooruType booruType,
    required String url,
  }) : this(id: -1, booruType: booruType, url: url);

  EditBooruConfigId.fromConfig(
    BooruConfig config,
  )   : id = config.id,
        booruType = config.auth.booruType,
        url = config.url;

  final int id;
  final BooruType booruType;
  final String url;

  bool get isNew => id == -1;

  @override
  List<Object> get props => [id, booruType, url];
}
