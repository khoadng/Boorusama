sealed class KnownExtension {
  const KnownExtension(this.extensionName);

  final String extensionName;

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
