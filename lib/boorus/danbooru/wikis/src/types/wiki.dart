// Package imports:
import 'package:equatable/equatable.dart';

class Wiki extends Equatable {
  const Wiki({
    required this.id,
    required this.title,
    required this.body,
    required this.otherNames,
  });

  factory Wiki.empty() => const Wiki(
        body: '',
        id: 0,
        title: '',
        otherNames: [],
      );

  final int id;
  final String title;
  final String body;
  final List<String> otherNames;

  @override
  List<Object?> get props => [id, title, body, otherNames];
}
