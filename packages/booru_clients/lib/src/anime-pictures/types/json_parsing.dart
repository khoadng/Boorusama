int? intFromJson(dynamic value) => switch (value) {
  final num value => value.toInt(),
  final String value => int.tryParse(value),
  _ => null,
};

double? doubleFromJson(dynamic value) => switch (value) {
  final num value => value.toDouble(),
  final String value => double.tryParse(value),
  _ => null,
};

bool? boolFromJson(dynamic value) => switch (value) {
  final bool value => value,
  final num value => value != 0,
  final String value => switch (value.toLowerCase()) {
    'true' => true,
    'false' => false,
    '1' => true,
    '0' => false,
    _ => null,
  },
  _ => null,
};

String? stringFromJson(dynamic value) => switch (value) {
  final String value => value,
  _ => null,
};

DateTime? dateTimeFromJson(dynamic value) => switch (stringFromJson(value)) {
  final date? => DateTime.tryParse(date),
  _ => null,
};

Map<String, dynamic>? mapFromJson(dynamic value) {
  if (value is Map<String, dynamic>) return value;

  if (value is Map) {
    try {
      return Map<String, dynamic>.from(value);
    } catch (_) {
      return null;
    }
  }

  return null;
}

List<T>? listFromJson<T>(
  dynamic value,
  T Function(Map<String, dynamic> item) parser,
) => switch (value) {
  final List value =>
    value
        .map(mapFromJson)
        .whereType<Map<String, dynamic>>()
        .map(parser)
        .toList(),
  _ => null,
};

List<String>? stringListFromJson(dynamic value) => switch (value) {
  final List value => value.whereType<String>().toList(),
  _ => null,
};
