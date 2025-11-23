import 'dart:io';

bool isSocketException(dynamic e) {
  return e is SocketException;
}
