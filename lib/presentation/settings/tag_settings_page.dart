import 'package:boorusama/application/users/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TagSettingsPage extends StatefulWidget {
  TagSettingsPage({Key key}) : super(key: key);

  @override
  _TagSettingsPageState createState() => _TagSettingsPageState();
}

class _TagSettingsPageState extends State<TagSettingsPage> {
  List<String> _blacklistedTags = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blacklisted tags"),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.sync),
        //     //TODO: should hide this button when user is not logged in
        //     onPressed: () =>
        //         BlocProvider.of<UserBloc>(context).add(UserRequested()),
        //   )
        // ],
      ),
      body: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserFetched) {
              setState(() {
                _blacklistedTags = state.user.blacklistedTags;
              });
            }
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_blacklistedTags[index]),
              );
            },
            itemCount: _blacklistedTags.length,
          )),
    );
  }
}
