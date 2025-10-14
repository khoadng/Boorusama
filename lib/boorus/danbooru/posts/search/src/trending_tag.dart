// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../../core/tags/categories/types.dart';
import '../../../tags/trending/types.dart';

class TrendingTag extends Equatable {
  const TrendingTag({
    required this.name,
    this.category,
  });

  final Search name;
  final TagCategory? category;

  @override
  List<Object?> get props => [name, category];
}
