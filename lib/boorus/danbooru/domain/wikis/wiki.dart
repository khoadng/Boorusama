// Package imports:
import 'package:meta/meta.dart';

class Wiki {
  int id;
  String title;
  String body;
  List<dynamic> otherNames;

  Wiki({
    required this.id,
    required this.title,
    required this.body,
    required this.otherNames,
  });

  factory Wiki.empty() => Wiki(
        body: "",
        id: 0,
        title: "",
        otherNames: [],
      );
}
