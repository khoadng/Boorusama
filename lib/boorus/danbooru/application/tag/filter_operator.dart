enum FilterOperator {
  none,
  not,
  or,
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
    default:
      return '';
  }
}
