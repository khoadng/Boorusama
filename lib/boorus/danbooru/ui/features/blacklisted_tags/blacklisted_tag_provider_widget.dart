// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/core/utils.dart';

enum BlacklistedOperation {
  add,
}

void _add(
  BuildContext context,
  Tag tag,
) {
  context.read<BlacklistedTagsBloc>().add(BlacklistedTagAdded(
        tag: tag.rawName,
      ));
}

typedef BlacklistedDelegate = void Function(Tag tag);

class BlacklistedTagProviderWidget extends StatelessWidget {
  const BlacklistedTagProviderWidget({
    super.key,
    required this.builder,
    required this.operation,
    this.onTagAdded,
  });

  final Widget Function(
    BuildContext context,
    BlacklistedDelegate action,
  ) builder;
  final BlacklistedOperation operation;
  final void Function()? onTagAdded;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlacklistedTagsBloc, BlacklistedTagsState>(
      listenWhen: (previous, current) => current.status == LoadStatus.success,
      listener: (context, state) {
        showSimpleSnackBar(
          context: context,
          duration: const Duration(seconds: 1),
          content: const Text('blacklisted_tags.updated').tr(),
        );
      },
      builder: (context, state) => builder(
        context,
        (tag) => _add(
          context,
          tag,
        ),
      ),
    );
  }
}
