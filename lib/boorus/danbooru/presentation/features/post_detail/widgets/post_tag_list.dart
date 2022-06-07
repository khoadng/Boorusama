// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags/flutter_tags.dart' hide TagsState;
import 'package:popup_menu/popup_menu.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';

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
  Tag? _currentPopupTag;
  PopupMenu? _menu;
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
            mainAxisAlignment: MainAxisAlignment.start,
            key: tagKey,
            children: [
              Chip(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  backgroundColor: Color(tag.tagHexColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8))),
                  label: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.70),
                    child: Text(
                      tag.displayName,
                      overflow: TextOverflow.fade,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
              Chip(
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
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
  void initState() {
    super.initState();
    context.read<TagCubit>().getTagsByNameComma(widget.tagStringComma);
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
        launchExternalUrl(
          Uri.parse(
              "${widget.apiEndpoint}/wiki_pages/${_currentPopupTag!.rawName}"),
          mode: LaunchMode.platformDefault,
        );
      },
    );

    return BlocBuilder<TagCubit, AsyncLoadState<List<TagGroupItem>>>(
      builder: (context, state) {
        if (state.status == LoadStatus.success) {
          final widgets = <Widget>[];
          for (var g in state.data!) {
            widgets.add(_TagBlockTitle(
              title: g.groupName,
              isFirstBlock: g.groupName == state.data!.first.groupName,
            ));
            widgets.add(_buildTags(g.tags));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widgets,
            ],
          );
        } else if (state.status == LoadStatus.failure) {
          return SizedBox.shrink();
        } else {
          return Center(child: CircularProgressIndicator());
        }
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
