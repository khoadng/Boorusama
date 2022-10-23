import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BulkDownloadPage extends StatefulWidget {
  const BulkDownloadPage({
    super.key,
  });

  @override
  State<BulkDownloadPage> createState() => _BulkDownloadPageState();
}

class _BulkDownloadPageState extends State<BulkDownloadPage> {
  final selectedTag = ValueNotifier<AutocompleteData?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk downloads'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ValueListenableBuilder<AutocompleteData?>(
                      valueListenable: selectedTag,
                      builder: (context, value, child) {
                        return value == null
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                height: 100,
                                color: Theme.of(context).cardColor,
                                child: const Text('Empty'),
                              )
                            : Column(
                                children: [
                                  Text('${value.label} (${value.postCount}) '),
                                  TextButton.icon(
                                    onPressed: () => print('fetch'),
                                    icon: const Icon(Icons.info),
                                    label: const Text('fetch metadata'),
                                  ),
                                ],
                              );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: SearchBar(
              enabled: false,
              hintText: 'Add tag',
              onTap: () {
                showBarModalBottomSheet(
                  context: context,
                  builder: (context) => SimpleTagSearchView(
                    onSelected: (tag) {
                      selectedTag.value = tag;
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
