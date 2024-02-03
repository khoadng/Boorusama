// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';

class Reboot extends StatefulWidget {
  const Reboot({
    super.key,
    required this.initialConfig,
    required this.builder,
  });

  final BooruConfig initialConfig;

  final Widget Function(BuildContext context, BooruConfig config) builder;

  @override
  State<Reboot> createState() => _RebootState();

  static start(BuildContext context, BooruConfig newInitialConfig) {
    context
        .findAncestorStateOfType<_RebootState>()!
        .restartApp(newInitialConfig);
  }
}

class _RebootState extends State<Reboot> {
  Key _key = UniqueKey();
  late var _config = widget.initialConfig;

  void restartApp(BooruConfig config) {
    setState(() {
      _config = config;
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.builder(context, _config),
    );
  }
}
