// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../types/metatag.dart';

class MetatagListPage extends StatelessWidget {
  const MetatagListPage({
    required this.metatags,
    required this.onSelected,
    super.key,
  });

  final List<Metatag> metatags;
  final void Function(Metatag tag) onSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metatags'.hc),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Symbols.close),
          ),
        ],
      ),
      body: Column(
        children: [
          InfoContainer(
            title: 'Free tags'.hc,
            contentBuilder: (context) => Text(context.t.search.metatags_notice),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: metatags.length,
              itemBuilder: (context, index) {
                final tag = metatags[index];

                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(tag);
                  },
                  title: Text(tag.name),
                  trailing: tag.isFree
                      ? Chip(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          label: Text(
                            'Free'.hc,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
