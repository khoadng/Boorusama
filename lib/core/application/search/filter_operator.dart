enum FilterOperator {
  none,
  not,
  or,
}

String stripFilterOperator(String value, FilterOperator operator) {
  switch (operator) {
    case FilterOperator.not:
    case FilterOperator.or:
      return value.substring(1);
    case FilterOperator.none:
      return value;
  }
}

FilterOperator stringToFilterOperator(String value) {
  switch (value) {
    case '-':
      return FilterOperator.not;
    case '~':
      return FilterOperator.or;
    default:
      return FilterOperator.none;
  }
}

String filterOperatorToString(FilterOperator operator) {
  switch (operator) {
    case FilterOperator.not:
      return '-';
    case FilterOperator.or:
      return '~';
    case FilterOperator.none:
      return '';
  }
}

String filterOperatorToStringCharacter(FilterOperator operator) {
  switch (operator) {
    case FilterOperator.not:
      return 'not'.toUpperCase();
    case FilterOperator.or:
      return 'or'.toUpperCase();
    case FilterOperator.none:
      return '';
  }
}
