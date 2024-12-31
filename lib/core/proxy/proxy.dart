// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

enum ProxyType {
  unknown,
  http,
  // socks5,
}

class ProxySettings extends Equatable {
  const ProxySettings({
    required this.type,
    required this.host,
    required this.port,
    this.username,
    this.password,
    this.enable = true,
  });

  factory ProxySettings.unknown() => const ProxySettings(
        type: ProxyType.unknown,
        host: '',
        port: 0,
        enable: false,
      );

  factory ProxySettings.fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return ProxySettings.unknown();
    }

    final json = tryDecodeJson(jsonString).getOrElse((_) => null);

    if (json == null) return ProxySettings.unknown();

    return ProxySettings.fromJson(json);
  }

  factory ProxySettings.fromJson(Map<String, dynamic> json) {
    return ProxySettings(
      type: ProxyType.values.firstWhere(
        (e) => e.toString() == 'ProxyType.${json['type']}',
      ),
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String?,
      password: json['password'] as String?,
      enable: json['enable'] as bool? ?? true,
    );
  }

  ProxySettings copyWith({
    ProxyType? type,
    String? host,
    int? port,
    String? Function()? username,
    String? Function()? password,
    bool? enable,
  }) {
    return ProxySettings(
      type: type ?? this.type,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username != null ? username() : this.username,
      password: password != null ? password() : this.password,
      enable: enable ?? this.enable,
    );
  }

  final ProxyType type;
  final String host;
  final int port;
  final String? username;
  final String? password;
  final bool enable;

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'enable': enable,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [
        type,
        host,
        port,
        username,
        password,
        enable,
      ];

  @override
  String toString() {
    return username != null && password != null
        ? '${type.name.toUpperCase()} $username:$password@$host:$port (enabled: $enable)'
        : '${type.name.toUpperCase()} $host:$port (enabled: $enable)';
  }
}

extension ProxySettingsX on ProxySettings {
  bool get useHttpProxy =>
      this != ProxySettings.unknown() && (type == ProxyType.http);

  String? getProxyAddress() {
    final type = this.type;
    final host = this.host;
    final port = this.port;
    final username = this.username;
    final password = this.password;

    if (type == ProxyType.unknown || host.isEmpty || port == 0) {
      return null;
    }

    return username != null && password != null
        ? '$username:$password@$host:$port'
        : '$host:$port';
  }
}
