class Setting {
  bool safeMode;
  String blacklistedTags;

  Setting(this.safeMode, this.blacklistedTags);

  Setting.fromJson(Map<String, dynamic> json)
      : safeMode = json["safeMode"],
        blacklistedTags = json["hideBlacklist"];

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
      };
}
