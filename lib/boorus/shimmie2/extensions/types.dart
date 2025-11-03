// Package imports:
import 'package:equatable/equatable.dart';

class Extension extends Equatable {
  const Extension({
    required this.name,
    required this.description,
    required this.category,
    this.docLink,
  });

  factory Extension.fromJson(Map<String, dynamic> json) {
    return Extension(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      docLink: json['docLink'] as String?,
    );
  }

  final String name;
  final String description;
  final String category;
  final String? docLink;

  bool matches(KnownExtension known) =>
      name.toLowerCase() == known.name.toLowerCase();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'docLink': docLink,
    };
  }

  @override
  List<Object?> get props => [
    name,
    description,
    category,
    docLink,
  ];
}

sealed class KnownExtension {
  const KnownExtension(this.name);

  final String name;

  static const danbooruApi = DanbooruApiExtension();
  static const graphql = GraphqlExtension();
  static const bulkActions = BulkActionsExtension();
  static const userApiKey = UserApiKeyExtension();

  static const all = [
    danbooruApi,
    graphql,
    bulkActions,
    userApiKey,
  ];
}

class DanbooruApiExtension extends KnownExtension {
  const DanbooruApiExtension() : super('Danbooru Client API');
}

class GraphqlExtension extends KnownExtension {
  const GraphqlExtension() : super('GraphQL');
}

class BulkActionsExtension extends KnownExtension {
  const BulkActionsExtension() : super('Bulk Actions');
}

class UserApiKeyExtension extends KnownExtension {
  const UserApiKeyExtension() : super('User API Key');
}
