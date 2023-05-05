import 'package:flutter/widgets.dart';
import 'tag_store.dart';

class TagStoreScope extends StatefulWidget {
  final Widget Function(TagStore tagStore) builder;

  const TagStoreScope({
    Key? key,
    required this.builder,
  }) : super(key: key);

  static TagStore of(BuildContext context) {
    final _TagStoreScopeState? tagStoreScopeState =
        context.findAncestorStateOfType<_TagStoreScopeState>();
    assert(tagStoreScopeState != null,
        'No TagStoreScope found in the widget tree');
    return tagStoreScopeState!.tagStore;
  }

  @override
  _TagStoreScopeState createState() => _TagStoreScopeState();
}

class _TagStoreScopeState extends State<TagStoreScope> {
  late final TagStore tagStore;

  @override
  void initState() {
    super.initState();
    tagStore = TagStore();
  }

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
