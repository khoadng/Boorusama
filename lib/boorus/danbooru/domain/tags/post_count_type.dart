// Package imports:
import 'package:intl/intl.dart';

class PostCountType {
  int _value;

  PostCountType(this._value);

  int get value => _value;

  @override
  String toString() => NumberFormat.compact().format(_value);
}
