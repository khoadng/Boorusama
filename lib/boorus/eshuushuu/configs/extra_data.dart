import 'dart:convert';

class EshuushuuExtraData {
  const EshuushuuExtraData({
    this.userId,
    this.tokenExpiry,
  });

  factory EshuushuuExtraData.fromPassHash(String? passHash) {
    if (passHash == null || passHash.isEmpty) {
      return const EshuushuuExtraData();
    }

    try {
      final json = jsonDecode(passHash);
      return switch (json) {
        {'userId': final int id} => EshuushuuExtraData(
          userId: id,
          tokenExpiry: switch (json) {
            {'tokenExpiry': final int ms} =>
              DateTime.fromMillisecondsSinceEpoch(ms),
            _ => null,
          },
        ),
        _ => const EshuushuuExtraData(),
      };
    } on FormatException catch (_) {
      // Bare string = legacy userId
      return EshuushuuExtraData(userId: int.tryParse(passHash));
    }
  }

  final int? userId;
  final DateTime? tokenExpiry;

  String toPassHash() => jsonEncode({
    'userId': ?userId,
    'tokenExpiry': ?tokenExpiry?.millisecondsSinceEpoch,
  });
}
