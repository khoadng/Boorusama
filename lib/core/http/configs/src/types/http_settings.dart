// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:booru_clients/generated.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

enum HttpProtocolOption {
  auto,
  https1_1,
  https2_0;

  static HttpProtocolOption parse(String? value) {
    return switch (value) {
      'auto' => HttpProtocolOption.auto,
      'https_1_1' => HttpProtocolOption.https1_1,
      'https_2_0' => HttpProtocolOption.https2_0,
      _ => HttpProtocolOption.auto,
    };
  }

  String toData() {
    return switch (this) {
      HttpProtocolOption.auto => 'auto',
      HttpProtocolOption.https1_1 => 'https_1_1',
      HttpProtocolOption.https2_0 => 'https_2_0',
    };
  }

  NetworkProtocol? toNetworkProtocol() {
    return switch (this) {
      HttpProtocolOption.auto => null,
      HttpProtocolOption.https1_1 => NetworkProtocol.https_1_1,
      HttpProtocolOption.https2_0 => NetworkProtocol.https_2_0,
    };
  }
}

class HttpSettings extends Equatable {
  const HttpSettings({
    this.protocol,
    this.skipCertificateVerification,
  });

  static HttpSettings? tryParse(dynamic data) {
    return switch (data) {
      null => null,
      final String str when str.isEmpty => null,
      final String str => switch (tryDecodeJson(str).getOrElse((_) => null)) {
        final Map<String, dynamic> json => HttpSettings(
          protocol: json['protocol'] as String?,
          skipCertificateVerification:
              json['skipCertificateVerification'] as bool?,
        ),
        _ => null,
      },
      final Map<String, dynamic> json => HttpSettings(
        protocol: json['protocol'] as String?,
        skipCertificateVerification:
            json['skipCertificateVerification'] as bool?,
      ),
      _ => null,
    };
  }

  final String? protocol;
  final bool? skipCertificateVerification;

  HttpProtocolOption get protocolOption => HttpProtocolOption.parse(protocol);

  HttpSettings copyWith({
    String? Function()? protocol,
    bool? Function()? skipCertificateVerification,
  }) {
    return HttpSettings(
      protocol: switch (protocol) {
        final fn? => fn(),
        null => this.protocol,
      },
      skipCertificateVerification: switch (skipCertificateVerification) {
        final fn? => fn(),
        null => this.skipCertificateVerification,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocol': ?protocol,
      'skipCertificateVerification': ?skipCertificateVerification,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [protocol, skipCertificateVerification];
}
