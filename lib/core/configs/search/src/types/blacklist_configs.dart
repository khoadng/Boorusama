// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'blacklist_combination_mode.dart';

class BlacklistConfigs extends Equatable {
  const BlacklistConfigs({
    required this.combinationMode,
    required this.blacklistedTags,
    required this.enable,
  });

  BlacklistConfigs.defaults()
    : combinationMode = BlacklistCombinationMode.merge.id,
      blacklistedTags = null,
      enable = false;

  factory BlacklistConfigs._fromJson(Map<String, dynamic> json) {
    try {
      return BlacklistConfigs(
        combinationMode: json['combinationMode'] as String,
        blacklistedTags: json['blacklistedTags'] as String?,
        enable: json['enable'] as bool,
      );
    } on Exception catch (_) {
      return BlacklistConfigs.defaults();
    }
  }

  factory BlacklistConfigs._fromJsonString(String? jsonString) =>
      switch (jsonString) {
        null => BlacklistConfigs.defaults(),
        final String s => tryDecodeJson(s).fold(
          (_) => BlacklistConfigs.defaults(),
          (json) => BlacklistConfigs._fromJson(json),
        ),
      };

  static BlacklistConfigs? tryParse(dynamic data) => switch (data) {
    final Map<String, dynamic> json => BlacklistConfigs._fromJson(json),
    final String jsonString => BlacklistConfigs._fromJsonString(jsonString),
    _ => null,
  };

  BlacklistConfigs copyWith({
    String? combinationMode,
    String? Function()? blacklistedTags,
    bool? enable,
  }) {
    return BlacklistConfigs(
      combinationMode: combinationMode ?? this.combinationMode,
      blacklistedTags: blacklistedTags != null
          ? blacklistedTags()
          : this.blacklistedTags,
      enable: enable ?? this.enable,
    );
  }

  final String combinationMode;
  final String? blacklistedTags;
  final bool enable;

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {
      'combinationMode': combinationMode,
      'blacklistedTags': blacklistedTags,
      'enable': enable,
    };
  }

  @override
  List<Object?> get props => [combinationMode, blacklistedTags, enable];
}
