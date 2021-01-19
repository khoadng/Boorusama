// import 'package:boorusama/boorus/danbooru/application/search/tag_suggestions_bloc.dart';
// import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class TagSettingsPage extends StatefulWidget {
//   TagSettingsPage({
//     Key key,
//     @required this.settings,
//   }) : super(key: key);

//   final Setting settings;

//   @override
//   _TagSettingsPageState createState() => _TagSettingsPageState();
// }

// class _TagSettingsPageState extends State<TagSettingsPage> {
//   List<String> _blacklistedTags = <String>[];

//   @override
//   void initState() {
//     super.initState();
//     _blacklistedTags = widget.settings.blacklistedTags.split("\n");
//   }

//   @override
//   void dispose() {
//     // widget.settings.blacklistedTags = _blacklistedTags.join("\n");
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final tag = await showSearch(
//             context: context,
//             delegate: _Search(),
//           );
//           if (tag != null) {
//             setState(() {
//               _blacklistedTags.add(tag);
//             });
//           }
//         },
//         child: Icon(
//           Icons.add,
//         ),
//       ),
//       appBar: AppBar(
//         title: Text("Blacklisted tags"),
//       ),
//       body: ListView.builder(
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(_blacklistedTags[index]),
//             trailing: IconButton(
//               icon: Icon(Icons.close),
//               onPressed: () {
//                 setState(() {
//                   _blacklistedTags.remove(_blacklistedTags[index]);
//                 });
//               },
//             ),
//           );
//         },
//         itemCount: _blacklistedTags.length,
//       ),
//     );
//   }
// }

// class _Search extends SearchDelegate {
//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     return Theme.of(context);
//   }

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return <Widget>[
//       IconButton(
//         icon: Icon(Icons.close),
//         onPressed: () => query = "",
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () => Navigator.pop(context),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return Container();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     if (query.isNotEmpty) {
//       BlocProvider.of<TagSuggestionsBloc>(context)
//           .add(TagSuggestionsChanged(tagString: query, page: 1));

//       return BlocBuilder<TagSuggestionsBloc, TagSuggestionsState>(
//         builder: (context, state) {
//           if (state is TagSuggestionsLoaded) {
//             return ListView.builder(
//               itemCount: state.tags.length,
//               itemBuilder: (context, index) {
//                 final tag = state.tags[index];
//                 return ListTile(
//                   title: Text(tag.displayName),
//                   trailing: Text(tag.postCount.toString()),
//                   onTap: () {
//                     close(context, tag.rawName);
//                   },
//                 );
//               },
//             );
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       );
//     } else {
//       return Center(
//         child: Text("Such empty"),
//       );
//     }
//   }
// }
