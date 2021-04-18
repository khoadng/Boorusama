class Profile {
  int id;
  String name;
  int level;
  int inviterId;
  String createdAt;
  String lastLoggedInAt;
  String lastForumReadAt;
  int commentThreshold;
  String updatedAt;
  String defaultImageSize;
  String favoriteTags;
  String blacklistedTags;
  String timeZone;
  int postUpdateCount;
  int noteUpdateCount;
  int favoriteCount;
  int postUploadCount;
  int perPage;
  String customStyle;
  String theme;
  bool isBanned;
  bool canApprovePosts;
  bool canUploadFree;
  String levelString;
  bool hasMail;
  bool receiveEmailNotifications;
  bool alwaysResizeImages;
  bool enablePostNavigation;
  bool newPostNavigationLayout;
  bool enablePrivateFavorites;
  bool enableSequentialPostNavigation;
  bool hideDeletedPosts;
  bool styleUsernames;
  bool enableAutoComplete;
  bool showDeletedChildren;
  bool hasSavedSearches;
  bool disableCategorizedSavedSearches;
  bool isSuperVoter;
  bool disableTaggedFilenames;
  bool enableRecentSearches;
  bool disableCroppedThumbnails;
  bool disableMobileGestures;
  bool enableSafeMode;
  bool enableDesktopMode;
  bool disablePostTooltips;
  bool enableRecommendedPosts;
  bool optOutTracking;
  bool noFlagging;
  bool noFeedback;
  bool requiresVerification;
  bool isVerified;
  int statementTimeout;
  int favoriteGroupLimit;
  int favoriteLimit;
  int tagQueryLimit;
  int maxSavedSearches;
  int wikiPageVersionCount;
  int artistVersionCount;
  int artistCommentaryVersionCount;
  int poolVersionCount;
  int forumPostCount;
  int commentCount;
  int favoriteGroupCount;
  int appealCount;
  int flagCount;
  int positiveFeedbackCount;
  int neutralFeedbackCount;
  int negativeFeedbackCount;

  Profile(
      {this.id,
      this.name,
      this.level,
      this.inviterId,
      this.createdAt,
      this.lastLoggedInAt,
      this.lastForumReadAt,
      this.commentThreshold,
      this.updatedAt,
      this.defaultImageSize,
      this.favoriteTags,
      this.blacklistedTags,
      this.timeZone,
      this.postUpdateCount,
      this.noteUpdateCount,
      this.favoriteCount,
      this.postUploadCount,
      this.perPage,
      this.customStyle,
      this.theme,
      this.isBanned,
      this.canApprovePosts,
      this.canUploadFree,
      this.levelString,
      this.hasMail,
      this.receiveEmailNotifications,
      this.alwaysResizeImages,
      this.enablePostNavigation,
      this.newPostNavigationLayout,
      this.enablePrivateFavorites,
      this.enableSequentialPostNavigation,
      this.hideDeletedPosts,
      this.styleUsernames,
      this.enableAutoComplete,
      this.showDeletedChildren,
      this.hasSavedSearches,
      this.disableCategorizedSavedSearches,
      this.isSuperVoter,
      this.disableTaggedFilenames,
      this.enableRecentSearches,
      this.disableCroppedThumbnails,
      this.disableMobileGestures,
      this.enableSafeMode,
      this.enableDesktopMode,
      this.disablePostTooltips,
      this.enableRecommendedPosts,
      this.optOutTracking,
      this.noFlagging,
      this.noFeedback,
      this.requiresVerification,
      this.isVerified,
      this.statementTimeout,
      this.favoriteGroupLimit,
      this.favoriteLimit,
      this.tagQueryLimit,
      this.maxSavedSearches,
      this.wikiPageVersionCount,
      this.artistVersionCount,
      this.artistCommentaryVersionCount,
      this.poolVersionCount,
      this.forumPostCount,
      this.commentCount,
      this.favoriteGroupCount,
      this.appealCount,
      this.flagCount,
      this.positiveFeedbackCount,
      this.neutralFeedbackCount,
      this.negativeFeedbackCount});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    level = json['level'];
    inviterId = json['inviter_id'];
    createdAt = json['created_at'];
    lastLoggedInAt = json['last_logged_in_at'];
    lastForumReadAt = json['last_forum_read_at'];
    commentThreshold = json['comment_threshold'];
    updatedAt = json['updated_at'];
    defaultImageSize = json['default_image_size'];
    favoriteTags = json['favorite_tags'];
    blacklistedTags = json['blacklisted_tags'];
    timeZone = json['time_zone'];
    postUpdateCount = json['post_update_count'];
    noteUpdateCount = json['note_update_count'];
    favoriteCount = json['favorite_count'];
    postUploadCount = json['post_upload_count'];
    perPage = json['per_page'];
    customStyle = json['custom_style'];
    theme = json['theme'];
    isBanned = json['is_banned'];
    canApprovePosts = json['can_approve_posts'];
    canUploadFree = json['can_upload_free'];
    levelString = json['level_string'];
    hasMail = json['has_mail'];
    receiveEmailNotifications = json['receive_email_notifications'];
    alwaysResizeImages = json['always_resize_images'];
    enablePostNavigation = json['enable_post_navigation'];
    newPostNavigationLayout = json['new_post_navigation_layout'];
    enablePrivateFavorites = json['enable_private_favorites'];
    enableSequentialPostNavigation = json['enable_sequential_post_navigation'];
    hideDeletedPosts = json['hide_deleted_posts'];
    styleUsernames = json['style_usernames'];
    enableAutoComplete = json['enable_auto_complete'];
    showDeletedChildren = json['show_deleted_children'];
    hasSavedSearches = json['has_saved_searches'];
    disableCategorizedSavedSearches =
        json['disable_categorized_saved_searches'];
    isSuperVoter = json['is_super_voter'];
    disableTaggedFilenames = json['disable_tagged_filenames'];
    enableRecentSearches = json['enable_recent_searches'];
    disableCroppedThumbnails = json['disable_cropped_thumbnails'];
    disableMobileGestures = json['disable_mobile_gestures'];
    enableSafeMode = json['enable_safe_mode'];
    enableDesktopMode = json['enable_desktop_mode'];
    disablePostTooltips = json['disable_post_tooltips'];
    enableRecommendedPosts = json['enable_recommended_posts'];
    optOutTracking = json['opt_out_tracking'];
    noFlagging = json['no_flagging'];
    noFeedback = json['no_feedback'];
    requiresVerification = json['requires_verification'];
    isVerified = json['is_verified'];
    statementTimeout = json['statement_timeout'];
    favoriteGroupLimit = json['favorite_group_limit'];
    favoriteLimit = json['favorite_limit'];
    tagQueryLimit = json['tag_query_limit'];
    maxSavedSearches = json['max_saved_searches'];
    wikiPageVersionCount = json['wiki_page_version_count'];
    artistVersionCount = json['artist_version_count'];
    artistCommentaryVersionCount = json['artist_commentary_version_count'];
    poolVersionCount = json['pool_version_count'];
    forumPostCount = json['forum_post_count'];
    commentCount = json['comment_count'];
    favoriteGroupCount = json['favorite_group_count'];
    appealCount = json['appeal_count'];
    flagCount = json['flag_count'];
    positiveFeedbackCount = json['positive_feedback_count'];
    neutralFeedbackCount = json['neutral_feedback_count'];
    negativeFeedbackCount = json['negative_feedback_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['level'] = this.level;
    data['inviter_id'] = this.inviterId;
    data['created_at'] = this.createdAt;
    data['last_logged_in_at'] = this.lastLoggedInAt;
    data['last_forum_read_at'] = this.lastForumReadAt;
    data['comment_threshold'] = this.commentThreshold;
    data['updated_at'] = this.updatedAt;
    data['default_image_size'] = this.defaultImageSize;
    data['favorite_tags'] = this.favoriteTags;
    data['blacklisted_tags'] = this.blacklistedTags;
    data['time_zone'] = this.timeZone;
    data['post_update_count'] = this.postUpdateCount;
    data['note_update_count'] = this.noteUpdateCount;
    data['favorite_count'] = this.favoriteCount;
    data['post_upload_count'] = this.postUploadCount;
    data['per_page'] = this.perPage;
    data['custom_style'] = this.customStyle;
    data['theme'] = this.theme;
    data['is_banned'] = this.isBanned;
    data['can_approve_posts'] = this.canApprovePosts;
    data['can_upload_free'] = this.canUploadFree;
    data['level_string'] = this.levelString;
    data['has_mail'] = this.hasMail;
    data['receive_email_notifications'] = this.receiveEmailNotifications;
    data['always_resize_images'] = this.alwaysResizeImages;
    data['enable_post_navigation'] = this.enablePostNavigation;
    data['new_post_navigation_layout'] = this.newPostNavigationLayout;
    data['enable_private_favorites'] = this.enablePrivateFavorites;
    data['enable_sequential_post_navigation'] =
        this.enableSequentialPostNavigation;
    data['hide_deleted_posts'] = this.hideDeletedPosts;
    data['style_usernames'] = this.styleUsernames;
    data['enable_auto_complete'] = this.enableAutoComplete;
    data['show_deleted_children'] = this.showDeletedChildren;
    data['has_saved_searches'] = this.hasSavedSearches;
    data['disable_categorized_saved_searches'] =
        this.disableCategorizedSavedSearches;
    data['is_super_voter'] = this.isSuperVoter;
    data['disable_tagged_filenames'] = this.disableTaggedFilenames;
    data['enable_recent_searches'] = this.enableRecentSearches;
    data['disable_cropped_thumbnails'] = this.disableCroppedThumbnails;
    data['disable_mobile_gestures'] = this.disableMobileGestures;
    data['enable_safe_mode'] = this.enableSafeMode;
    data['enable_desktop_mode'] = this.enableDesktopMode;
    data['disable_post_tooltips'] = this.disablePostTooltips;
    data['enable_recommended_posts'] = this.enableRecommendedPosts;
    data['opt_out_tracking'] = this.optOutTracking;
    data['no_flagging'] = this.noFlagging;
    data['no_feedback'] = this.noFeedback;
    data['requires_verification'] = this.requiresVerification;
    data['is_verified'] = this.isVerified;
    data['statement_timeout'] = this.statementTimeout;
    data['favorite_group_limit'] = this.favoriteGroupLimit;
    data['favorite_limit'] = this.favoriteLimit;
    data['tag_query_limit'] = this.tagQueryLimit;
    data['max_saved_searches'] = this.maxSavedSearches;
    data['wiki_page_version_count'] = this.wikiPageVersionCount;
    data['artist_version_count'] = this.artistVersionCount;
    data['artist_commentary_version_count'] = this.artistCommentaryVersionCount;
    data['pool_version_count'] = this.poolVersionCount;
    data['forum_post_count'] = this.forumPostCount;
    data['comment_count'] = this.commentCount;
    data['favorite_group_count'] = this.favoriteGroupCount;
    data['appeal_count'] = this.appealCount;
    data['flag_count'] = this.flagCount;
    data['positive_feedback_count'] = this.positiveFeedbackCount;
    data['neutral_feedback_count'] = this.neutralFeedbackCount;
    data['negative_feedback_count'] = this.negativeFeedbackCount;
    return data;
  }
}
