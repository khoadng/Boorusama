// Package imports:
import 'package:equatable/equatable.dart';

class MediaHostOverride extends Equatable {
  MediaHostOverride({required String from, required String to})
    : from = normalizeHost(from),
      to = normalizeHost(to) {
    if (this.from == this.to) {
      throw const FormatException();
    }
  }

  static MediaHostOverride? tryParse(dynamic json) {
    if (json case {'from': final String from, 'to': final String to}) {
      try {
        return MediaHostOverride(from: from, to: to);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  final String from;
  final String to;

  static String normalizeHost(String value) {
    final host = value.trim().toLowerCase();
    final label = RegExp(r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$');
    if (host.isEmpty ||
        host.length > 253 ||
        !host.split('.').every(label.hasMatch)) {
      throw const FormatException();
    }
    return host;
  }

  Map<String, dynamic> toJson() => {'from': from, 'to': to};

  @override
  List<Object?> get props => [from, to];
}
