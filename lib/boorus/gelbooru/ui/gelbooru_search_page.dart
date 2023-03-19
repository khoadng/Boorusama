// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class GelbooruSearchPage extends StatefulWidget {
  const GelbooruSearchPage({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
    this.autoFocusSearchBar = true,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;
  final bool autoFocusSearchBar;

  @override
  State<GelbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<GelbooruSearchPage> {
  late final _tags = widget.metatags.map((e) => e.name).join('|');
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      RegExp('($_tags)+:'): TextStyle(
        fontWeight: FontWeight.w800,
        color: widget.metatagHighlightColor,
      ),
    },
    // ignore: no-empty-block
    onMatch: (List<String> match) {},
  );
  final compositeSubscription = CompositeSubscription();
  final focus = FocusNode();

  @override
  void dispose() {
    compositeSubscription.dispose();
    queryEditingController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildSearchBar(context),
      ),
      body: Container(),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    return SearchBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back,
        ),
      ),
      queryEditingController: queryEditingController,
      autofocus: true,
      trailing: IconButton(
        onPressed: () {
          queryEditingController.clear();
        },
        icon: const Icon(Icons.close),
      ),
      onChanged: (value) => print(value),
      onSubmitted: (value) {
        print(value);
      },
      // hintText: 'pool.search.hint'.tr(),
      // onTap: () => searchBloc.add(const PoolSearchResumed()),
    );
  }
}
