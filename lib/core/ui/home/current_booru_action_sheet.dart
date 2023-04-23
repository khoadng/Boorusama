// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/home/switch_booru_modal.dart';

class CurrentBooruActionSheet extends StatelessWidget {
  const CurrentBooruActionSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Switch booru'),
            onTap: () {
              Navigator.of(context).pop();
              context.read<ManageBooruBloc>().add(const ManageBooruFetched());
              showMaterialModalBottomSheet(
                context: context,
                builder: (_) => const SwitchBooruModal(),
              );
            },
          ),
          ListTile(
            title: const Text('Add and switch booru'),
            onTap: () {
              Navigator.of(context).pop();
              goToAddBooruPage(
                context,
                setCurrentBooruOnSubmit: true,
              );
            },
          ),
        ],
      ),
    );
  }
}
