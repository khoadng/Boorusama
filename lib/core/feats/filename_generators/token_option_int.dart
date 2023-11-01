part of 'token_option.dart';

final class MaxLengthOption extends IntegerTokenOption {
  MaxLengthOption(
    String? value,
  ) : super(name: 'maxlength', value: value);
}

final class PadLeftOption extends IntegerTokenOption {
  PadLeftOption(
    String? value,
  ) : super(name: 'pad_left', value: value);
}

final class LimitOption extends IntegerTokenOption {
  LimitOption(
    String? value,
  ) : super(name: 'limit', value: value);
}

final class FloatingPointPrecisionOption extends IntegerTokenOption {
  FloatingPointPrecisionOption(
    String? value,
  ) : super(name: 'precision', value: value);
}
