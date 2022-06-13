// Package imports:
import 'package:intl/intl.dart';

class PostCountType {

  PostCountType(this._value);
  final int _value;

  int get value => _value;

  @override
  String toString() => NumberFormat.compact().format(_value);
}
