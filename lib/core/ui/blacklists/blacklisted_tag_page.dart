// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/application/blacklists/blacklisted_tags_cubit.dart';
import 'package:boorusama/core/ui/blacklists/blacklisted_tag_sheet.dart';

class BlacklistedTagPage extends StatefulWidget {
  const BlacklistedTagPage({super.key});

  @override
  State<BlacklistedTagPage> createState() => _BlacklistedTagPageState();
}

class _BlacklistedTagPageState extends State<BlacklistedTagPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<BlacklistedTagCubit>().getBlacklist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blacklist'),
      ),
      body: BlocBuilder<BlacklistedTagCubit, BlacklistState>(
        builder: (context, state) {
          if (state is BlacklistLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is BlacklistLoaded) {
            return ListView.builder(
              itemCount: state.tags.length,
              itemBuilder: (context, index) {
                final tag = state.tags[index];
                return ListTile(
                  title: Text(tag.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.read<BlacklistedTagCubit>().removeTag(tag);
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('Error loading blacklist'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showMaterialModalBottomSheet(
              context: context,
              builder: (_) => BlacklistedTagSheet(
                  onSubmit: (tag) =>
                      context.read<BlacklistedTagCubit>().addTag(tag)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
