// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../details_parts/types.dart';

const _kDefaultView = 'default';

class CustomDetailsPartKey extends Equatable {
  const CustomDetailsPartKey(
    this.name,
  );

  const CustomDetailsPartKey.defaultValue() : name = _kDefaultView;

  factory CustomDetailsPartKey.fromJson(dynamic json) {
    final name = json['name'] as String?;

    if (name == null) {
      return const CustomDetailsPartKey.defaultValue();
    }

    return CustomDetailsPartKey(name);
  }

  final String name;

  @override
  String toString() => name;

  Map<String, dynamic> toJson() => {
    'name': name,
  };

  @override
  List<Object?> get props => [name];
}

List<CustomDetailsPartKey> convertDetailsParts(List<DetailsPart> parts) {
  return parts.map(convertDetailsPart).toList();
}

CustomDetailsPartKey convertDetailsPart(DetailsPart part) {
  return CustomDetailsPartKey(part.name);
}
