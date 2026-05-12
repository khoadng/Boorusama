// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../widgets/comment_composer.dart';

enum CommentThreadScrollTarget {
  start,
  end,
}

class CommentThreadPageScaffold<T> extends StatefulWidget {
  const CommentThreadPageScaffold({
    required this.useAppBar,
    required this.authenticated,
    required this.comments,
    required this.commentListBuilder,
    required this.onSend,
    super.key,
    this.onLoad,
    this.onRefresh,
    this.replyHeaderBuilder,
    this.onOpenEditor,
    this.loading = false,
    this.error,
    this.scrollAfterSend = CommentThreadScrollTarget.start,
  });

  final bool useAppBar;
  final bool authenticated;
  final bool loading;
  final Object? error;
  final List<T>? comments;
  final Future<void> Function()? onLoad;
  final Future<void> Function()? onRefresh;
  final Future<void> Function(String content, T? replyTo) onSend;
  final Future<String?> Function(String content, T? replyTo)? onOpenEditor;
  final Widget Function(BuildContext context, T replyTo)? replyHeaderBuilder;
  final Widget Function(
    BuildContext context,
    ScrollController scrollController,
    void Function(T comment) onReply,
  )
  commentListBuilder;
  final CommentThreadScrollTarget scrollAfterSend;

  @override
  State<CommentThreadPageScaffold<T>> createState() =>
      _CommentThreadPageScaffoldState<T>();
}

class _CommentThreadPageScaffoldState<T>
    extends State<CommentThreadPageScaffold<T>> {
  late final _focus = FocusNode();
  late final _scrollController = ScrollController();
  final _commentReply = ValueNotifier<T?>(null);
  final _isEditing = ValueNotifier(false);
  int? _lastCommentCount;

  @override
  void initState() {
    super.initState();
    _lastCommentCount = widget.comments?.length;

    Future(() {
      if (!mounted) return;
      widget.onLoad?.call();
    });

    _isEditing.addListener(_onEditing);

    _focus.addListener(() {
      if (_focus.hasPrimaryFocus) {
        _isEditing.value = true;
      }
    });
  }

  @override
  void didUpdateWidget(covariant CommentThreadPageScaffold<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newCount = widget.comments?.length;
    if (_lastCommentCount != null &&
        newCount != null &&
        newCount > _lastCommentCount!) {
      _scrollAfterSend();
    }

    if (newCount != null) {
      _lastCommentCount = newCount;
    }
  }

  void _onEditing() {
    if (!_isEditing.value) {
      _commentReply.value = null;
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void dispose() {
    _isEditing.removeListener(_onEditing);
    _commentReply.dispose();
    _scrollController.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _pop() {
    if (_isEditing.value) {
      _isEditing.value = false;
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _replyTo(T comment) async {
    _commentReply.value = comment;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _focus.requestFocus();
  }

  Future<void> _send(String content) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final replyTo = _commentReply.value;
    _isEditing.value = false;
    await widget.onSend(content, replyTo);
    await _scrollAfterSend();
  }

  Future<void> _scrollAfterSend() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!_scrollController.hasClients) return;

    final position = switch (widget.scrollAfterSend) {
      CommentThreadScrollTarget.start =>
        _scrollController.position.minScrollExtent,
      CommentThreadScrollTarget.end =>
        _scrollController.position.maxScrollExtent,
    };

    await _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isEditing,
      builder: (context, edit, child) => PopScope(
        canPop: !edit,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _pop();
        },
        child: child!,
      ),
      child: Scaffold(
        appBar: widget.useAppBar
            ? AppBar(
                title: Text(context.t.comment.comments),
              )
            : null,
        body: SafeArea(
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.error case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(error.toString()),
        ),
      );
    }

    if (widget.loading || widget.comments == null) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _isEditing.value = false,
      child: Column(
        children: [
          Expanded(
            child: BooruRefreshIndicator(
              onRefresh: widget.onRefresh ?? () async {},
              child: widget.commentListBuilder(
                context,
                _scrollController,
                _replyTo,
              ),
            ),
          ),
          if (widget.authenticated)
            ValueListenableBuilder(
              valueListenable: _commentReply,
              builder: (context, replyTo, _) => CommentComposer(
                focusNode: _focus,
                isEditing: _isEditing,
                header: switch (replyTo) {
                  final replyTo? => widget.replyHeaderBuilder?.call(
                    context,
                    replyTo,
                  ),
                  _ => null,
                },
                onOpenEditor: (content) async {
                  final result = await widget.onOpenEditor?.call(
                    content,
                    replyTo,
                  );
                  _isEditing.value = false;

                  return result;
                },
                onSubmit: _send,
              ),
            ),
        ],
      ),
    );
  }
}
