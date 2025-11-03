// Project imports:
import 'graphql_client.dart';

class FieldDiscovery {
  FieldDiscovery({
    required GraphQLClient client,
    required List<String> allFields,
    required Set<String> coreFields,
    required String Function(Iterable<String>) buildDiscoveryQuery,
    required Map<String, dynamic> discoveryVariables,
  }) : _client = client,
       _allFields = allFields,
       _coreFields = coreFields,
       _buildDiscoveryQuery = buildDiscoveryQuery,
       _discoveryVariables = discoveryVariables;

  final GraphQLClient _client;
  final List<String> _allFields;
  final Set<String> _coreFields;
  final String Function(Iterable<String>) _buildDiscoveryQuery;
  final Map<String, dynamic> _discoveryVariables;

  Set<String>? _availableFields;
  bool _discoveryAttempted = false;

  Future<Set<String>> ensureDiscovered() async {
    return switch (_availableFields) {
      final fields? => fields,
      null => await _discover().then((_) => _availableFields!),
    };
  }

  Future<void> _discover() async {
    if (_discoveryAttempted) return;
    _discoveryAttempted = true;

    try {
      final result = await _client.executeQueryRaw(
        query: _buildDiscoveryQuery(_allFields),
        variables: _discoveryVariables,
        parseData: (data) => data,
      );

      _availableFields = switch (result) {
        GraphQLSuccess() => _allFields.toSet(),
        GraphQLError(errors: final errors) => _parseAvailableFieldsFromErrors(
          errors,
        ),
      };
    } catch (e) {
      _availableFields = _coreFields;
    }
  }

  Set<String> _parseAvailableFieldsFromErrors(List errors) {
    final unavailableFields = errors
        .whereType<Map>()
        .map((e) => e['message'] as String?)
        .whereType<String>()
        .map(_extractFieldNameFromError)
        .whereType<String>()
        .toSet();

    return _allFields.toSet()..removeAll(unavailableFields);
  }

  String? _extractFieldNameFromError(String message) {
    final patterns = [
      RegExp(r'Cannot query field "(\w+)"'),
      RegExp(r'Field "(\w+)" .* must have a sub selection'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match?.group(1) case final field?) return field;
    }

    return null;
  }
}
