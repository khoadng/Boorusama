enum FilterOperator {
  none,
  not,
  or,
}

String stripFilterOperator(String value, FilterOperator operator) =>
    switch (operator) {
      FilterOperator.or || FilterOperator.not => value.substring(1),
      FilterOperator.none => value,
    };

FilterOperator stringToFilterOperator(String value) => switch (value) {
      '-' => FilterOperator.not,
      '~' => FilterOperator.or,
      _ => FilterOperator.none
    };

String filterOperatorToString(FilterOperator operator) => switch (operator) {
      FilterOperator.not => '-',
      FilterOperator.or => '~',
      FilterOperator.none => ''
    };

String filterOperatorToStringCharacter(FilterOperator operator) =>
    switch (operator) {
      FilterOperator.not => 'not'.toUpperCase(),
      FilterOperator.or => 'or'.toUpperCase(),
      FilterOperator.none => ''
    };
