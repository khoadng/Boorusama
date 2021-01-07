import 'package:boorusama/application/comments/bloc/comment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'fab_fill_transition.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({
    Key key,
    @required this.sourceRect,
    @required this.postId,
    this.initialContent,
  })  : assert(sourceRect != null),
        assert(
          postId != null,
        ),
        super(key: key);

  final Rect sourceRect;
  final int postId;
  final String initialContent;

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  String _subject = '';
  TextEditingController _textEditingController;
  String _initialContent = "";

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _initialContent = widget.initialContent ?? "";
    _textEditingController.text = _initialContent;
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FabFillTransition(
      source: widget.sourceRect,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: double.infinity,
            margin: const EdgeInsets.all(4),
            child: Material(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _subjectRow,
                    _spacer,
                    // _senderAddressRow,
                    // _spacer,
                    // _recipientRow,
                    _spacer,
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _textEditingController,
                        minLines: 6,
                        maxLines: 20,
                        decoration:
                            InputDecoration.collapsed(hintText: 'Comment'),
                        autofocus: false,
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get _spacer {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        height: 1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }

  Widget get _subjectRow {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
            ),
          ),
          Expanded(
              child:
                  Text(_subject, style: Theme.of(context).textTheme.headline6)),
          BlocListener<CommentBloc, CommentState>(
            listener: (context, state) {
              state.maybeWhen(
                addedSuccess: () {
                  Navigator.of(context).pop();
                },
                loading: () => Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("Please wait..."))),
                error: () => Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("Error"))),
                orElse: () {},
              );
            },
            child: IconButton(
                onPressed: () {
                  BlocProvider.of<CommentBloc>(context).add(
                    CommentEvent.added(
                      postId: widget.postId,
                      content: _textEditingController.text,
                    ),
                  );
                },
                icon: Icon(Icons.send)),
          ),
        ],
      ),
    );
  }
}
