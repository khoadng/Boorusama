// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/blacklists.dart';
import 'package:boorusama/core/router.dart';

class BlacklistedTagPage extends ConsumerStatefulWidget {
  const BlacklistedTagPage({super.key});

  @override
  ConsumerState<BlacklistedTagPage> createState() => _BlacklistedTagPageState();
}

class _BlacklistedTagPageState extends ConsumerState<BlacklistedTagPage> {
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
            if (state.tags.isEmpty) {
              return const Center(
                child: Text('No blacklisted tags'),
              );
            }
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
          goToQuickSearchPage(
            context,
            ref: ref,
            onSelected: (tag) =>
                context.read<BlacklistedTagCubit>().addTag(tag.value),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
