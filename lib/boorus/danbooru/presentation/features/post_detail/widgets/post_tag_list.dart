// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tags/flutter_tags.dart' hide TagsState;
import 'package:popup_menu/popup_menu.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag_category.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/tag_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/webview.dart';
import 'package:boorusama/core/presentation/widgets/slide_in_route.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

final _tagsProvider = FutureProvider.autoDispose
    .family<List<Tag>, String>((ref, tagStringComma) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(tagProvider);
  final tags = await repo.getTagsByNameComma(
    tagStringComma,
    1,
    cancelToken: cancelToken,
  );

  /// Cache the tags once it was successfully obtained.
  ref.maintainState = true;

  return tags;
});

class PostTagList extends StatefulWidget {
  PostTagList({
    Key? key,
    required this.tagStringComma,
    required this.apiEndpoint,
  }) : super(key: key);

  final String tagStringComma;
  final String apiEndpoint;

  @override
  _PostTagListState createState() => _PostTagListState();
}

class _PostTagListState extends State<PostTagList> {
  List<Tag> _artistTags = <Tag>[];
  List<Tag> _characterTags = <Tag>[];
  List<Tag> _copyrightTags = <Tag>[];
  Tag? _currentPopupTag;
  List<Tag> _generalTags = <Tag>[];
  PopupMenu? _menu;
  List<Tag> _metaTags = <Tag>[];
  Map<String, GlobalKey> _tagKeys = Map<String, GlobalKey>();

  Widget _buildTags(List<Tag> tags) {
    return Tags(
      alignment: WrapAlignment.start,
      runSpacing: 0,
      itemCount: tags.length,
      itemBuilder: (index) {
        final tag = tags[index];
        final tagKey = GlobalKey();
        _tagKeys[tag.rawName] = tagKey;

        return GestureDetector(
          onTap: () => AppRouter.router.navigateTo(
            context,
            "/posts/search",
            routeSettings: RouteSettings(arguments: [tag.rawName]),
          ),
          onLongPress: () {
            if (_menu!.isShow) {
              _menu!.dismiss();
            }
            _currentPopupTag = tag;
            _menu!.show(widgetKey: _tagKeys[tag.rawName]);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            key: tagKey,
            children: [
              Chip(
                  padding: EdgeInsets.all(4.0),
                  labelPadding: EdgeInsets.all(1.0),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Color(tag.tagHexColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8))),
                  label: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85),
                    child: Text(
                      tag.displayName,
                      overflow: TextOverflow.fade,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
              Chip(
                padding: EdgeInsets.all(2.0),
                labelPadding: EdgeInsets.all(1.0),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8))),
                label: Text(
                  tag.postCount.toString(),
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _menu ??= PopupMenu(
      context: context,
      config: MenuConfig(
        backgroundColor: Theme.of(context).cardColor,
        maxColumn: 4,
      ),
      items: [
        MenuItem(
          title: 'Wiki',
          image: Icon(
            Icons.info,
            color: Colors.white70,
          ),
        )
      ],
      onClickMenu: (_) {
        print("${widget.apiEndpoint}${_currentPopupTag!.rawName}");
        Navigator.of(context).push(
          SlideInRoute(
              pageBuilder: (context, animation, secondaryAnimation) => WebView(
                  url:
                      "${widget.apiEndpoint}/wiki_pages/${_currentPopupTag!.rawName}")),
        );
      },
    );

    return Consumer(
      builder: (context, watch, child) {
        final state = watch(_tagsProvider(widget.tagStringComma));
        return state.when(
          loading: () => Center(child: CircularProgressIndicator()),
          data: (tags) {
            tags.sort((a, b) => a.rawName.compareTo(b.rawName));
            _artistTags = tags
                .where((tag) => tag.category == TagCategory.artist)
                .toList();
            _copyrightTags = tags
                .where((tag) => tag.category == TagCategory.copyright)
                .toList();
            _characterTags = tags
                .where((tag) => tag.category == TagCategory.charater)
                .toList();
            _generalTags = tags
                .where((tag) => tag.category == TagCategory.general)
                .toList();
            _metaTags =
                tags.where((tag) => tag.category == TagCategory.meta).toList();
            final headers = [];
            if (_artistTags.length > 0) headers.add(["Artist", _artistTags]);
            if (_characterTags.length > 0)
              headers.add(["Character", _characterTags]);
            if (_copyrightTags.length > 0)
              headers.add(["Copyright", _copyrightTags]);
            if (_generalTags.length > 0) headers.add(["General", _generalTags]);
            if (_metaTags.length > 0) headers.add(["Meta", _metaTags]);

            final widgets = <Widget>[];
            for (var header in headers) {
              widgets.add(_TagBlockTitle(
                title: header[0],
                isFirstBlock: header[0] == headers.first[0],
              ));
              widgets.add(_buildTags(header[1]));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widgets,
              ],
            );
          },
          error: (e, m) => Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _TagBlockTitle extends StatelessWidget {
  const _TagBlockTitle(
      {required this.title, Key? key, this.isFirstBlock = false})
      : super(key: key);

  final bool isFirstBlock;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          _TagHeader(
            title: title,
          ),
        ]);
  }
}

class _TagHeader extends StatelessWidget {
  const _TagHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
