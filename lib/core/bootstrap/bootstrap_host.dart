// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../foundation/boot/crash_report_writer.dart';
import '../../foundation/boot/failsafe.dart';
import '../../foundation/boot/file_system_crash_report_writer.dart';
import '../../foundation/boot/runtime_error_widget.dart';
import '../../foundation/info/device_info.dart';
import '../app.dart';
import '../app_external_effects.dart';
import '../app_scope.dart';
import 'boorusama_bootstrap.dart';
import 'boorusama_runtime.dart';

class BoorusamaBootstrapHost extends StatefulWidget {
  const BoorusamaBootstrapHost({
    required this.bootstrap,
    this.loading,
    this.crashReportWriter = const FileSystemCrashReportWriter(),
    super.key,
  });

  final BoorusamaBootstrap bootstrap;
  final Widget? loading;
  final CrashReportWriter crashReportWriter;

  @override
  State<BoorusamaBootstrapHost> createState() => _BoorusamaBootstrapHostState();
}

class _BoorusamaBootstrapHostState extends State<BoorusamaBootstrapHost> {
  late final Future<BoorusamaRuntime> _runtimeFuture;

  @override
  void initState() {
    super.initState();
    initializeRuntimeErrorWidget();
    _runtimeFuture = widget.bootstrap.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BoorusamaRuntime>(
      future: _runtimeFuture,
      builder: (context, snapshot) => switch (snapshot) {
        AsyncSnapshot(hasError: true, :final error, :final stackTrace) =>
          _buildError(error!, stackTrace),
        AsyncSnapshot(hasData: true, :final data) => _buildApp(data!),
        _ => widget.loading ?? const _DefaultLoading(),
      },
    );
  }

  Widget _buildError(Object error, StackTrace? stackTrace) {
    final failure = error is BoorusamaBootstrapFailure ? error : null;

    return ProviderScope(
      overrides: [
        deviceInfoProvider.overrideWithValue(DeviceInfo.empty()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: AppFailedToInitialize(
          error: failure?.error ?? error,
          stackTrace: failure?.stackTrace ?? stackTrace,
          logs: failure?.logs ?? '',
          crashReportWriter: widget.crashReportWriter,
        ),
      ),
    );
  }

  Widget _buildApp(BoorusamaRuntime runtime) {
    return BoorusamaAppScope(
      runtime: runtime,
      child: const BoorusamaExternalEffects(
        child: BoorusamaCoreApp(),
      ),
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
