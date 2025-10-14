enum FilterOperator {
  none,
  not,
  or;

  factory FilterOperator.fromString(String value) => switch (value) {
    '-' => not,
    '~' => or,
    _ => none,
  };

  @override
  String toString() => switch (this) {
    not => '-',
    or => '~',
    none => '',
  };
}

String stripFilterOperator(String value, FilterOperator operator) =>
    switch (operator) {
      FilterOperator.or || FilterOperator.not => value.substring(1),
      FilterOperator.none => value,
    };
