// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../boorus/booru/types.dart';
import '../../../config/types.dart';

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
  ) : id = config.id,
      booruType = config.auth.booruType,
      url = config.url;

  static EditBooruConfigId? fromUri(Uri uri) => switch (uri.queryParameters) {
    {
      'type': final typeStr,
      'url': final url,
      'id': final idStr,
    } =>
      switch ((
        int.tryParse(typeStr),
        int.tryParse(idStr),
      )) {
        (final type?, final id?) => EditBooruConfigId(
          id: id,
          booruType: BooruType.fromLegacyId(type),
          url: url,
        ),
        _ => null,
      },
    _ => null,
  };

  final int id;
  final BooruType booruType;
  final String url;

  bool get isNew => id == -1;

  Map<String, String> toQueryParameters() => {
    'type': booruType.id.toString(),
    'url': url,
    'id': id.toString(),
  };

  @override
  List<Object> get props => [id, booruType, url];
}
