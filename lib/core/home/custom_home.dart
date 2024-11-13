// Package imports:
import 'package:equatable/equatable.dart';

const _kDefaultView = 'default';

class CustomHomeViewKey extends Equatable {
  const CustomHomeViewKey(
    this.name,
  );

  const CustomHomeViewKey.defaultValue() : name = _kDefaultView;

  factory CustomHomeViewKey.fromJson(dynamic json) {
    final name = json['name'] as String?;

    if (name == null) {
      return const CustomHomeViewKey.defaultValue();
    }

    return CustomHomeViewKey(name);
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

extension CustomViewKeyX on CustomHomeViewKey? {
  bool get isDefault => this == const CustomHomeViewKey.defaultValue();
  bool get isAlt => !isDefault;
}

final kDefaultAltHomeView = {
  CustomHomeViewKey.defaultValue(): {
    'displayName': 'Default',
  },
  CustomHomeViewKey('search'): {
    'displayName': 'Search',
  },
  CustomHomeViewKey('bookmark'): {
    'displayName': 'Bookmark',
  }
};
