import 'dart:io';

import 'package:retriable/retriable.dart';
import 'package:test/test.dart';

void main() {
  group('FetchStrategyBuilder', () {
    test('should attempt retry on SocketException', () async {
      const builder = FetchStrategyBuilder();
      final strategy = builder.build();
      final uri = Uri.parse('https://example.com');
      final failure = FetchFailure(
        totalDuration: const Duration(seconds: 1),
        attemptCount: 1,
        originalException: const SocketException('Failed to connect'),
        uri: uri,
      );

      final instructions = await strategy(uri, failure);

      expect(instructions.shouldGiveUp, isFalse);
      expect(instructions.timeout, equals(const Duration(seconds: 30)));
    });

    test('should give up after max attempts', () async {
      const builder = FetchStrategyBuilder(maxAttempts: 3);
      final strategy = builder.build();
      final uri = Uri.parse('https://example.com');
      final failure = FetchFailure(
        totalDuration: const Duration(seconds: 1),
        attemptCount: 4,
        httpStatusCode: 500,
        uri: uri,
      );

      final instructions = await strategy(uri, failure);

      expect(instructions.shouldGiveUp, isTrue);
    });

    test('should respect total fetch timeout', () async {
      const builder = FetchStrategyBuilder(
        totalFetchTimeout: Duration(seconds: 5),
      );
      final strategy = builder.build();
      final uri = Uri.parse('https://example.com');
      final failure = FetchFailure(
        totalDuration: const Duration(seconds: 6),
        attemptCount: 2,
        httpStatusCode: 500,
        uri: uri,
      );

      final instructions = await strategy(uri, failure);

      expect(instructions.shouldGiveUp, isTrue);
    });
  });

  group('FetchInstructions', () {
    test('should create attempt instructions', () {
      final instructions = FetchInstructions.attempt(
        uri: Uri.parse('https://example.com'),
        timeout: const Duration(seconds: 30),
      );

      expect(instructions.shouldGiveUp, isFalse);
      expect(instructions.timeout, equals(const Duration(seconds: 30)));
      expect(instructions.silent, isNull);
    });

    test('should create give up instructions', () {
      final instructions = FetchInstructions.giveUp(
        uri: Uri.parse('https://example.com'),
        silent: true,
      );

      expect(instructions.shouldGiveUp, isTrue);
      expect(instructions.timeout, equals(Duration.zero));
      expect(instructions.silent, isTrue);
    });
  });
}
