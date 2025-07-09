// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../http/src/dio/dio.dart';
import '../../../../proxy/proxy.dart';

const _kCheckProxyTimeout = Duration(seconds: 10);

class TestProxyNotifier extends AutoDisposeNotifier<TestProxyState> {
  @override
  TestProxyState build() {
    ref.onDispose(_cancel);

    return const TestProxyState(TestProxyStatus.idle);
  }

  Future<bool> check(
    ProxySettings proxySettings,
  ) async {
    final token = CancelToken();

    unawaited(
      Future.delayed(
        _kCheckProxyTimeout,
        () {
          // if still checking after a while, change status
          if (state.status == TestProxyStatus.checking) {
            state = state.copyWith(
              status: TestProxyStatus.checkingPendingTimeout,
            );
          }
        },
      ),
    );

    state = state.copyWith(
      status: TestProxyStatus.checking,
      cancelToken: token,
    );

    try {
      final dio = newGenericDio(
        baseUrl: 'https://example.com',
        proxySettings: proxySettings.copyWith(
          // Enable proxy for testing
          enable: true,
        ),
      );

      final res = await dio.get(
        '/',
        cancelToken: token,
        options: Options(
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      final statusCode = res.statusCode;

      if (statusCode == null) return false;

      return statusCode >= 200 && statusCode < 300;
    } on Exception catch (_) {
      return false;
    } finally {
      state = const TestProxyState(TestProxyStatus.idle);
    }
  }

  void _cancel() {
    final token = state.cancelToken;
    if (token != null && !token.isCancelled) {
      token.cancel();
    }
  }

  void cancel() {
    _cancel();

    state = const TestProxyState(TestProxyStatus.idle);
  }
}

enum TestProxyStatus {
  idle,
  checking,
  checkingPendingTimeout,
}

final testProxyProvider =
    NotifierProvider.autoDispose<TestProxyNotifier, TestProxyState>(
      TestProxyNotifier.new,
    );

class TestProxyState extends Equatable {
  const TestProxyState(this.status, {this.cancelToken});

  final TestProxyStatus status;
  final CancelToken? cancelToken;

  TestProxyState copyWith({
    TestProxyStatus? status,
    CancelToken? cancelToken,
  }) {
    return TestProxyState(
      status ?? this.status,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  @override
  List<Object?> get props => [status, cancelToken];
}
