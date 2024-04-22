// Package imports:
import 'package:equatable/equatable.dart';

class Metatag extends Equatable {
  const Metatag({
    required this.name,
    required this.description,
    required this.example,
    this.isFree = false,
  });

  const Metatag.simple({
    required this.name,
    this.isFree = false,
  })  : description = '',
        example = '';

  final String name;
  final String description;
  final String example;
  final bool isFree;

  @override
  List<Object?> get props => [name, description, example, isFree];
}
