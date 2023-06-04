// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/comment_section.dart';

class CommentPage extends ConsumerStatefulWidget {
  const CommentPage({
    super.key,
    required this.postId,
    this.useAppBar = true,
  });

  final int postId;
  final bool useAppBar;

  @override
  ConsumerState<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends ConsumerState<CommentPage> {
  late final _focus = FocusNode();
  final _commentReply = ValueNotifier<CommentData?>(null);
  final isEditing = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    ref.read(danbooruCommentsProvider.notifier).load(widget.postId);

    isEditing.addListener(_onEditing);

    _focus.addListener(() {
      if (_focus.hasPrimaryFocus) {
        isEditing.value = true;
      }
    });
  }

  void _onEditing() {
    if (!isEditing.value) {
      _commentReply.value = null;
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    isEditing.removeListener(_onEditing);
    _focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(danbooruCommentsProvider)[widget.postId];

    return WillPopScope(
      onWillPop: () async {
        if (isEditing.value) {
          isEditing.value = false;

          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: widget.useAppBar
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            : null,
        body: comments.toOption().fold(
              () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              (comments) => GestureDetector(
                onTap: () => isEditing.value = false,
                child: CommentSection(
                  comments: comments,
                  commentReply: _commentReply,
                  focus: _focus,
                  isEditing: isEditing,
                  postId: widget.postId,
                ),
              ),
            ),
      ),
    );
  }
}

Future<T?> showCommentPage<T>(
  BuildContext context, {
  required int postId,
  RouteSettings? settings,
  required Widget Function(BuildContext context, bool useAppBar) builder,
}) =>
    Screen.of(context).size == ScreenSize.small
        ? showMaterialModalBottomSheet<T>(
            context: context,
            settings: settings,
            duration: const Duration(milliseconds: 250),
            builder: (context) => builder(context, true),
          )
        : showSideSheetFromRight(
            settings: settings,
            width: MediaQuery.of(context).size.width * 0.41,
            body: Container(
              color: Colors.transparent,
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
              child: Column(
                children: [
                  Container(
                    height: kToolbarHeight * 0.8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'comment.comments',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).tr(),
                        const Spacer(),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            onTap: Navigator.of(context).pop,
                            child: const Icon(Icons.close),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: builder(context, false),
                  ),
                ],
              ),
            ),
            context: context,
          );
