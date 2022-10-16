class Profile {
  Profile({
    required this.lastLoggedInAt,
    required this.id,
    required this.name,
    required this.level,
    this.inviterId,
    // required this.createdAt,
    // required this.lastForumReadAt,
    // required this.commentThreshold,
    // required this.updatedAt,
    // required this.defaultImageSize,
    // // required this.favoriteTags,
    // required this.blacklistedTags,
    // required this.timeZone,
    // required this.postUpdateCount,
    // required this.noteUpdateCount,
    required this.favoriteCount,
    // required this.postUploadCount,
    // required this.perPage,
    // // required this.customStyle,
    // required this.theme,
    // required this.isBanned,
    // required this.canApprovePosts,
    // required this.canUploadFree,
    required this.levelString,
    // required this.unusedHasMail,
    // required this.receiveEmailNotifications,
    // required this.unusedAlwaysResizeImages,
    // required this.unusedEnablePostNavigation,
    // required this.newPostNavigationLayout,
    // required this.enablePrivateFavorites,
    // required this.unusedEnableSequentialPostNavigation,
    // required this.unusedHideDeletedPosts,
    // required this.styleUsernames,
    // required this.unusedEnableAutoComplete,
    // required this.showDeletedChildren,
    // required this.unusedHasSavedSearches,
    // required this.disableCategorizedSavedSearches,
    // required this.unusedIsSuperVoter,
    // required this.disableTaggedFilenames,
    // required this.unusedEnableRecentSearches,
    // required this.unusedDisableCroppedThumbnails,
    // required this.disableMobileGestures,
    // required this.enableSafeMode,
    // required this.enableDesktopMode,
    // required this.disablePostTooltips,
    // required this.unusedEnableRecommendedPosts,
    // required this.unusedOptOutTracking,
    // required this.unusedNoFlagging,
    // required this.unusedNoFeedback,
    // required this.requiresVerification,
    // required this.isVerified,
    // required this.showDeletedPosts,
    // required this.statementTimeout,
    // this.favoriteGroupLimit,
    // required this.tagQueryLimit,
    // required this.maxSavedSearches,
    // required this.wikiPageVersionCount,
    // required this.artistVersionCount,
    // required this.artistCommentaryVersionCount,
    // required this.poolVersionCount,
    // required this.forumPostCount,
    required this.commentCount,
    // required this.favoriteGroupCount,
    // required this.appealCount,
    // required this.flagCount,
    // required this.positiveFeedbackCount,
    // required this.neutralFeedbackCount,
    // required this.negativeFeedbackCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        lastLoggedInAt: DateTime.parse(json['last_logged_in_at']),
        id: json['id'],
        name: json['name'],
        level: json['level'],
        inviterId: json['inviter_id'],
        // createdAt: DateTime.parse(json['created_at']),
        // lastForumReadAt: DateTime.parse(json['last_forum_read_at']),
        // commentThreshold: json['comment_threshold'],
        // updatedAt: DateTime.parse(json['updated_at']),
        // defaultImageSize: json['default_image_size'],
        // favoriteTags: json["favorite_tags"],
        // blacklistedTags: json['blacklisted_tags'],
        // timeZone: json['time_zone'],
        // postUpdateCount: json['post_update_count'],
        // noteUpdateCount: json['note_update_count'],
        favoriteCount: json['favorite_count'],
        // postUploadCount: json['post_upload_count'],
        // perPage: json['per_page'],
        // customStyle: json["custom_style"],
        // theme: json['theme'],
        // isBanned: json['is_banned'],
        // canApprovePosts: json['can_approve_posts'],
        // canUploadFree: json['can_upload_free'],
        levelString: json['level_string'],
        // unusedHasMail: json['_unused_has_mail'],
        // receiveEmailNotifications: json['receive_email_notifications'],
        // unusedAlwaysResizeImages: json['_unused_always_resize_images'],
        // unusedEnablePostNavigation: json['_unused_enable_post_navigation'],
        // newPostNavigationLayout: json['new_post_navigation_layout'],
        // enablePrivateFavorites: json['enable_private_favorites'],
        // unusedEnableSequentialPostNavigation:
        //     json['_unused_enable_sequential_post_navigation'],
        // unusedHideDeletedPosts: json['_unused_hide_deleted_posts'],
        // styleUsernames: json['style_usernames'],
        // unusedEnableAutoComplete: json['_unused_enable_auto_complete'],
        // showDeletedChildren: json['show_deleted_children'],
        // unusedHasSavedSearches: json['_unused_has_saved_searches'],
        // disableCategorizedSavedSearches:
        //     json['disable_categorized_saved_searches'],
        // unusedIsSuperVoter: json['_unused_is_super_voter'],
        // disableTaggedFilenames: json['disable_tagged_filenames'],
        // unusedEnableRecentSearches: json['_unused_enable_recent_searches'],
        // unusedDisableCroppedThumbnails:
        //     json['_unused_disable_cropped_thumbnails'],
        // disableMobileGestures: json['disable_mobile_gestures'],
        // enableSafeMode: json['enable_safe_mode'],
        // enableDesktopMode: json['enable_desktop_mode'],
        // disablePostTooltips: json['disable_post_tooltips'],
        // unusedEnableRecommendedPosts: json['_unused_enable_recommended_posts'],
        // unusedOptOutTracking: json['_unused_opt_out_tracking'],
        // unusedNoFlagging: json['_unused_no_flagging'],
        // unusedNoFeedback: json['_unused_no_feedback'],
        // requiresVerification: json['requires_verification'],
        // isVerified: json['is_verified'],
        // showDeletedPosts: json['show_deleted_posts'],
        // statementTimeout: json['statement_timeout'],
        // favoriteGroupLimit: json['favorite_group_limit'],
        // tagQueryLimit: json['tag_query_limit'],
        // maxSavedSearches: json['max_saved_searches'],
        // wikiPageVersionCount: json['wiki_page_version_count'],
        // artistVersionCount: json['artist_version_count'],
        // artistCommentaryVersionCount: json['artist_commentary_version_count'],
        // poolVersionCount: json['pool_version_count'],
        // forumPostCount: json['forum_post_count'],
        commentCount: json['comment_count'],
        // favoriteGroupCount: json['favorite_group_count'],
        // appealCount: json['appeal_count'],
        // flagCount: json['flag_count'],
        // positiveFeedbackCount: json['positive_feedback_count'],
        // neutralFeedbackCount: json['neutral_feedback_count'],
        // negativeFeedbackCount: json['negative_feedback_count'],
      );

  final DateTime lastLoggedInAt;
  final int id;
  final String name;
  final int level;
  final int? inviterId;
  // final DateTime createdAt;
  // final DateTime lastForumReadAt;
  // final int commentThreshold;
  // final DateTime updatedAt;
  // final String defaultImageSize;
  // // final String favoriteTags;
  // final String blacklistedTags;
  // final String timeZone;
  // final int postUpdateCount;
  // final int noteUpdateCount;
  final int favoriteCount;
  // final int postUploadCount;
  // final int perPage;
  // // final String customStyle;
  // final String theme;
  // final bool isBanned;
  // final bool canApprovePosts;
  // final bool canUploadFree;
  final String levelString;
  // final bool unusedHasMail;
  // final bool receiveEmailNotifications;
  // final bool unusedAlwaysResizeImages;
  // final bool unusedEnablePostNavigation;
  // final bool newPostNavigationLayout;
  // final bool enablePrivateFavorites;
  // final bool unusedEnableSequentialPostNavigation;
  // final bool unusedHideDeletedPosts;
  // final bool styleUsernames;
  // final bool unusedEnableAutoComplete;
  // final bool showDeletedChildren;
  // final bool unusedHasSavedSearches;
  // final bool disableCategorizedSavedSearches;
  // final bool unusedIsSuperVoter;
  // final bool disableTaggedFilenames;
  // final bool unusedEnableRecentSearches;
  // final bool unusedDisableCroppedThumbnails;
  // final bool disableMobileGestures;
  // final bool enableSafeMode;
  // final bool enableDesktopMode;
  // final bool disablePostTooltips;
  // final bool unusedEnableRecommendedPosts;
  // final bool unusedOptOutTracking;
  // final bool unusedNoFlagging;
  // final bool unusedNoFeedback;
  // final bool requiresVerification;
  // final bool isVerified;
  // final bool showDeletedPosts;
  // final int statementTimeout;
  // final int? favoriteGroupLimit;
  // final int tagQueryLimit;
  // final int maxSavedSearches;
  // final int wikiPageVersionCount;
  // final int artistVersionCount;
  // final int artistCommentaryVersionCount;
  // final int poolVersionCount;
  // final int forumPostCount;
  final int commentCount;
  // final int favoriteGroupCount;
  // final int appealCount;
  // final int flagCount;
  // final int positiveFeedbackCount;
  // final int neutralFeedbackCount;
  // final int negativeFeedbackCount;
}
