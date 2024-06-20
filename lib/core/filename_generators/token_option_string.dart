part of 'token_option.dart';

final class DateFormatOption extends StringTokenOption {
  DateFormatOption(
    String? value,
  ) : super(name: 'format', value: value);
}

final class DelimiterOption extends StringTokenOption {
  DelimiterOption(
    String? value,
  ) : super(name: 'delimiter', value: value);
}

final class UnknownOption extends StringTokenOption {
  UnknownOption(
    String name,
    String? value,
  ) : super(name: name, value: value);
}
