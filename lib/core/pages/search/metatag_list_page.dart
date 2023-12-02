// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class MetatagListPage extends StatelessWidget {
  const MetatagListPage({
    super.key,
    required this.metatags,
    required this.onSelected,
  });

  final List<Metatag> metatags;
  final void Function(Metatag tag) onSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metatags'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          InfoContainer(
            contentBuilder: (context) =>
                const Text('search.metatags_notice').tr(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: metatags.length,
              itemBuilder: (context, index) {
                final tag = metatags[index];

                return ListTile(
                  onTap: () {
                    context.navigator.pop();
                    onSelected(tag);
                  },
                  title: Text(tag.name),
                  trailing: tag.isFree ? const Chip(label: Text('Free')) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
