class Setting {
  bool safeMode;
  bool hideBlacklist;

  Setting(this.safeMode, this.hideBlacklist);

  Setting.fromJson(Map<String, dynamic> json)
      : safeMode = json["safeMode"],
        hideBlacklist = json["hideBlacklist"];

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': hideBlacklist,
      };
}
