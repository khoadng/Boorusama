// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'tag_store.dart';

class TagStoreScope extends StatefulWidget {
  const TagStoreScope({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(TagStore tagStore) builder;

  static TagStore of(BuildContext context) {
    final _TagStoreScopeState? tagStoreScopeState =
        context.findAncestorStateOfType<_TagStoreScopeState>();
    assert(tagStoreScopeState != null,
        'No TagStoreScope found in the widget tree');
    return tagStoreScopeState!.tagStore;
  }

  @override
  State<TagStoreScope> createState() => _TagStoreScopeState();
}

class _TagStoreScopeState extends State<TagStoreScope> {
  late final TagStore tagStore = TagStore(context.read<TagInfo>());

  @override
  void dispose() {
    tagStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(tagStore);
  }
}
