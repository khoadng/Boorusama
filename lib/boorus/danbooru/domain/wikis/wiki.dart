class Wiki {

  Wiki({
    required this.id,
    required this.title,
    required this.body,
    required this.otherNames,
  });

  factory Wiki.empty() => Wiki(
        body: '',
        id: 0,
        title: '',
        otherNames: [],
      );
  int id;
  String title;
  String body;
  List<dynamic> otherNames;
}
