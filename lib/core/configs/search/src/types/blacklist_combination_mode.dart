enum BlacklistCombinationMode {
  merge('merge', true),
  replace('replace', false);

  const BlacklistCombinationMode(this.id, this.isDefault);

  factory BlacklistCombinationMode.fromString(String value) {
    return BlacklistCombinationMode.values.firstWhere(
      (e) => e.id == value,
      orElse: () => BlacklistCombinationMode.merge,
    );
  }

  final String id;
  final bool isDefault;
}

const kBlacklistCombinationModes = BlacklistCombinationMode.values;
