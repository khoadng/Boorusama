import 'package:boorusama/application/wikis/wiki/bloc/wiki_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WikiPage extends StatelessWidget {
  final String title;

  const WikiPage({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Center(child: Text(title)),
          ),
          body: BlocBuilder<WikiBloc, WikiState>(
            builder: (context, state) {
              if (state is WikiFetched) {
                return SingleChildScrollView(
                  child: Text(state.wiki.body),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
