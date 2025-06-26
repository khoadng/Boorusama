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

  factory BlacklistConfigs.fromJson(Map<String, dynamic> json) {
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

  factory BlacklistConfigs.fromJsonString(String? jsonString) =>
      switch (jsonString) {
        null => BlacklistConfigs.defaults(),
        final String s => tryDecodeJson(s).fold(
            (_) => BlacklistConfigs.defaults(),
            (json) => BlacklistConfigs.fromJson(json),
          ),
      };

  BlacklistConfigs copyWith({
    String? combinationMode,
    String? blacklistedTags,
    bool? enable,
  }) {
    return BlacklistConfigs(
      combinationMode: combinationMode ?? this.combinationMode,
      blacklistedTags: blacklistedTags ?? this.blacklistedTags,
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
