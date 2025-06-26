// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'create_booru_config_scaffold.dart';

class CreateAnonConfigPage extends ConsumerWidget {
  const CreateAnonConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigScaffold(
      backgroundColor: backgroundColor,
      initialTab: initialTab,
    );
  }
}
