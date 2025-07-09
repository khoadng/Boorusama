enum NetworkProtocol {
  https_1_1,
  https_2_0,
}

NetworkProtocol? stringToNetworkProtocol(String value) => switch (value) {
  'https_1_1' || 'https_1' => NetworkProtocol.https_1_1,
  'https_2_0' || 'https_2' => NetworkProtocol.https_2_0,
  _ => null,
};

NetworkProtocol parseProtocol(dynamic value) => switch (value) {
  final String s => stringToNetworkProtocol(s) ?? NetworkProtocol.https_1_1,
  _ => NetworkProtocol.https_1_1,
};
