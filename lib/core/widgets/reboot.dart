// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../configs/config.dart';

class Reboot extends StatefulWidget {
  const Reboot({
    super.key,
    required this.initialConfig,
    required this.initialConfigs,
    required this.builder,
  });

  final BooruConfig initialConfig;
  final List<BooruConfig> initialConfigs;

  final Widget Function(
    BuildContext context,
    BooruConfig config,
    List<BooruConfig> configs,
  ) builder;

  @override
  State<Reboot> createState() => _RebootState();

  static void start(
    BuildContext context,
    BooruConfig newInitialConfig,
    List<BooruConfig> newInitialConfigs,
  ) {
    context
        .findAncestorStateOfType<_RebootState>()!
        .restartApp(newInitialConfig, newInitialConfigs);
  }
}

class _RebootState extends State<Reboot> {
  Key _key = UniqueKey();
  late var _config = widget.initialConfig;
  late var _configs = widget.initialConfigs;

  void restartApp(BooruConfig config, List<BooruConfig> configs) {
    setState(() {
      _config = config;
      _configs = configs;
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.builder(context, _config, _configs),
    );
  }
}
