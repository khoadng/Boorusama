// Package imports:
import 'package:equatable/equatable.dart';

class E621Artist extends Equatable {
  const E621Artist({
    required this.name,
    required this.otherNames,
  });

  const E621Artist.empty()
      : name = '',
        otherNames = const [];

  final String name;
  final List<String> otherNames;

  @override
  List<Object> get props => [name, otherNames];
}
