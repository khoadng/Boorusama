// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/manage_booru_user_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/boorus.dart';

class ManageBooruUserPage extends StatelessWidget {
  const ManageBooruUserPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final users =
        context.select((ManageBooruUserBloc bloc) => bloc.state.users);

    final settings =
        context.select((SettingsCubit bloc) => bloc.state.settings);

    return users != null
        ? Scaffold(
            appBar: AppBar(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final bloc = context.read<ManageBooruUserBloc>();

                showModalBottomSheet(
                  context: context,
                  builder: (context) => _AddAccountSheet(
                    onSubmit: (login, apiKey, booru) =>
                        bloc.add(ManageBooruUserAdded(
                      login: login,
                      apiKey: apiKey,
                      booru: booru,
                      onFailure: (message) => print(message),
                    )),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
            body: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return ListTile(
                  title: Text(BooruType.values[user.booruId].name),
                  subtitle:
                      Text(user.login.isEmpty ? '<Anonymous>' : user.login),
                  trailing: IconButton(
                    onPressed: () => context
                        .read<ManageBooruUserBloc>()
                        .add(ManageBooruUserRemoved(
                          user: user,
                          onFailure: print,
                        )),
                    icon: const Icon(Icons.close),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<CurrentBooruBloc>().add(CurrentBooruChanged(
                          userBooru: user,
                          settings: settings,
                        ));
                  },
                );
              },
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class _AddAccountSheet extends StatefulWidget {
  const _AddAccountSheet({
    required this.onSubmit,
  });

  final void Function(String login, String apiKey, BooruType booru) onSubmit;

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final loginController = TextEditingController();
  final apiKeyController = TextEditingController();
  var selectedBooru = BooruType.unknown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (selectedBooru != BooruType.gelbooru)
            TextField(
              controller: loginController,
            ),
          if (selectedBooru != BooruType.gelbooru)
            TextField(
              controller: apiKeyController,
            ),
          DropdownButton<BooruType>(
            value: selectedBooru,
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  selectedBooru = value;
                }
              });
            },
            items: BooruType.values
                .map((e) => DropdownMenuItem<BooruType>(
                      value: e,
                      child: Text(e.name),
                    ))
                .toList(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSubmit.call(
                loginController.text,
                apiKeyController.text,
                selectedBooru,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
