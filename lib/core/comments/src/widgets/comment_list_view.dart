// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../widgets/widgets.dart';

class CommentListView<T> extends StatelessWidget {
  const CommentListView({
    required this.comments,
    required this.authenticated,
    required this.isSelf,
    required this.itemBuilder,
    super.key,
    this.onEdit,
    this.onReply,
    this.onDelete,
    this.scrollController,
  });

  final List<T> comments;
  final bool authenticated;
  final bool Function(T comment) isSelf;
  final void Function(T comment)? onEdit;
  final void Function(T comment)? onReply;
  final void Function(T comment)? onDelete;
  final ScrollController? scrollController;
  final Widget Function(
    BuildContext context,
    T comment,
    VoidCallback? onReply,
    Widget Function(BuildContext context)? moreBuilder,
  )
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Center(
        child: Text(context.t.comment.list.no_comments),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final canEdit = authenticated && isSelf(comment);
        final canReply = authenticated && onReply != null;
        final canDelete = authenticated && isSelf(comment);
        final hasMenu =
            (canEdit && onEdit != null) ||
            canReply ||
            (canDelete && onDelete != null);

        return ListTile(
          title: itemBuilder(
            context,
            comment,
            canReply ? () => onReply?.call(comment) : null,
            hasMenu
                ? (context) => BooruPopupMenuButton(
                    items: [
                      if (canEdit && onEdit != null)
                        BooruPopupMenuItem(
                          title: Text(context.t.comment.list.edit),
                          onTap: () => onEdit?.call(comment),
                        ),
                      if (canReply)
                        BooruPopupMenuItem(
                          title: Text(context.t.comment.list.reply),
                          onTap: () => onReply?.call(comment),
                        ),
                      if (canDelete && onDelete != null)
                        BooruPopupMenuItem(
                          title: Text(context.t.comment.list.delete),
                          onTap: () => onDelete?.call(comment),
                        ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}
