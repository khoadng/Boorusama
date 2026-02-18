// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

class ProfileIconConfigs extends Equatable {
  const ProfileIconConfigs({
    this.url,
  });

  static ProfileIconConfigs? tryParse(dynamic data) {
    final json = switch (data) {
      null || '' => null,
      final String str => _tryDecodeJson(str),
      final Map<String, dynamic> map => map,
      _ => null,
    };

    return switch (json) {
      final Map<String, dynamic> map => ProfileIconConfigs(
        url: map['url'] as String?,
      ),
      _ => null,
    };
  }

  static Map<String, dynamic>? _tryDecodeJson(String str) {
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  final String? url;

  ProfileIconConfigs copyWith({
    String? Function()? url,
  }) {
    return ProfileIconConfigs(
      url: url != null ? url() : this.url,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [url];
}
