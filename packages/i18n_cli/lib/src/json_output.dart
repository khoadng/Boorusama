import 'dart:convert';
import 'dart:io';

void writeJsonLine(Object? value, {IOSink? output}) {
  (output ?? stdout).writeln(const JsonEncoder().convert(value));
}
