// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../configs/config.dart';
import '../settings/settings.dart';

class RebootData extends Equatable {
  const RebootData({
    required this.config,
    required this.configs,
    required this.settings,
  });
  final BooruConfig config;
  final Settings settings;
  final List<BooruConfig> configs;

  @override
  List<Object?> get props => [config, configs, settings];
}

class Reboot extends StatefulWidget {
  const Reboot({
    required this.initialData,
    required this.builder,
    super.key,
  });

  final RebootData initialData;

  final Widget Function(
    BuildContext context,
    RebootData rebootData,
    // Need to pass a key to force child rebuild
    Key uniqueKey,
  )
  builder;

  @override
  State<Reboot> createState() => _RebootState();

  static void start(
    BuildContext context,
    RebootData? rebootData,
  ) {
    context.findAncestorStateOfType<_RebootState>()!.restartApp(rebootData);
  }
}

class _RebootState extends State<Reboot> {
  Key _key = UniqueKey();
  late var _rebootData = widget.initialData;

  void restartApp(RebootData? rebootData) {
    setState(() {
      if (rebootData != null) {
        _rebootData = rebootData;
      }
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.builder(context, _rebootData, _key),
    );
  }
}
