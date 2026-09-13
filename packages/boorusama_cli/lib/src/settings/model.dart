final class CatalogLabel {
  CatalogLabel(Object value)
    : key = value is String ? value : null,
      literal = value is Map ? value['literal'] as String : null;
  final String? key;
  final String? literal;
}

final class CatalogDestination {
  CatalogDestination(Map<String, dynamic> data, String scope)
    : title = CatalogLabel(data['title'] as Object),
      target = data[scope == 'app' ? 'route' : 'tab'] as String,
      parent = data['parent'] as String?,
      boorus = List.unmodifiable((data['boorus'] as List? ?? []).cast<int>()),
      condition = Map.unmodifiable(
        Map<String, bool>.from(data['when'] as Map? ?? {}),
      ),
      menu = data['menu'] as bool,
      order = data['order'] as int,
      pageEntry = data['pageEntry'] != false;
  final CatalogLabel title;
  final String target;
  final String? parent;
  final List<int> boorus;
  final Map<String, bool> condition;
  final bool menu;
  final int order;
  final bool pageEntry;
}

final class CatalogCategory {
  CatalogCategory(Map<String, dynamic> data)
    : id = data['id'] as String,
      iconFamily = (data['icon'] as Map)['family'] as String,
      iconName = (data['icon'] as Map)['name'] as String,
      keywords = List.unmodifiable(
        (data['keywords'] as List? ?? []).cast<String>(),
      ),
      scopes = Map.unmodifiable({
        for (final scope in ['app', 'profile'])
          if (data[scope] != null)
            scope: CatalogDestination(
              data[scope] as Map<String, dynamic>,
              scope,
            ),
      });
  final String id;
  final String iconFamily;
  final String iconName;
  final List<String> keywords;
  final Map<String, CatalogDestination> scopes;
}

final class CatalogStatus {
  CatalogStatus(Map<String, dynamic> data)
    : condition = Map.unmodifiable(
        Map<String, bool>.from(data['when'] as Map? ?? {}),
      ),
      text = CatalogLabel(data['text'] as Object),
      arguments = Map.unmodifiable(
        Map<String, String>.from(data['arguments'] as Map),
      );
  final Map<String, bool> condition;
  final CatalogLabel text;
  final Map<String, String> arguments;
}

final class CatalogPlacement {
  CatalogPlacement(Map<String, dynamic> data)
    : category = data['category'] as String,
      boorus = List.unmodifiable((data['boorus'] as List? ?? []).cast<int>()),
      condition = Map.unmodifiable(
        Map<String, bool>.from(data['when'] as Map? ?? {}),
      ),
      searchable = data['searchable'] != false,
      statuses = List.unmodifiable([
        for (final status in data['status'] as List? ?? [])
          CatalogStatus(status as Map<String, dynamic>),
      ]);
  final String category;
  final List<int> boorus;
  final Map<String, bool> condition;
  final bool searchable;
  final List<CatalogStatus> statuses;
}

final class CatalogSetting {
  CatalogSetting(this.group, this.name, Map<String, dynamic> data)
    : id = '$group.$name',
      title = CatalogLabel(data['title'] as Object),
      description = data['description'] == null
          ? null
          : CatalogLabel(data['description'] as Object),
      section = data['section'] == null
          ? null
          : CatalogLabel(data['section'] as Object),
      keywords = List.unmodifiable(
        (data['keywords'] as List? ?? []).cast<String>(),
      ),
      options = List.unmodifiable([
        for (final option in data['optionLabels'] as List? ?? [])
          CatalogLabel(option as Object),
      ]),
      placements = Map.unmodifiable({
        for (final entry in (data['scopes'] as Map<String, dynamic>).entries)
          entry.key: CatalogPlacement(entry.value as Map<String, dynamic>),
      });
  final String group;
  final String name;
  final String id;
  final CatalogLabel title;
  final CatalogLabel? description;
  final CatalogLabel? section;
  final List<String> keywords;
  final List<CatalogLabel> options;
  final Map<String, CatalogPlacement> placements;
}
