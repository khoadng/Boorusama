// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: settings.yaml; regenerate with boorusama settings gen.

import 'package:i18n/i18n.dart';

import 'settings_category.g.dart';
import 'settings_environment.g.dart';
import '../types/settings_search_entry.dart';

class SettingsAppearance {
  SettingsAppearance._();

  final colors = SettingDefinition(
    id: 'appearance.colors',
    label: (t) => t.settings.theme.viewer.colors,
    keywords: 'dark light system customize',
    placements: _appearance_colorsPlacements,
  );

  final theme = SettingDefinition(
    id: 'appearance.theme',
    label: (t) => t.settings.theme.theme,
    keywords: 'dark light system amoled',
    placements: _appearancePlacements,
  );

  final dynamicColor = SettingDefinition(
    id: 'appearance.dynamicColor',
    label: (t) => t.settings.theme.dynamic_color,
    placements: _appearancePlacements,
  );
}

class SettingsDownloads {
  SettingsDownloads._();

  final sidecar = SettingDefinition(
    id: 'downloads.sidecar',
    label: (t) => t.settings.download.sidecar.title,
    keywords: 'metadata tags json export',
    placements: _downloadsPlacements,
  );

  final folder = SettingDefinition(
    id: 'downloads.folder',
    label: (t) => t.settings.download.path,
    keywords: 'folder location directory save storage',
    placements: _downloads_folderPlacements,
  );

  final quality = SettingDefinition(
    id: 'downloads.quality',
    label: (t) => t.settings.download.quality,
    keywords: 'original sample preview resolution',
    optionTerms: (t) => [
      t.settings.download.qualities.original,
      t.settings.download.qualities.sample,
      t.settings.download.qualities.preview,
    ].join(" "),
    placements: _downloadsPlacements,
  );

  final network = SettingDefinition(
    id: 'downloads.network',
    label: (t) => t.settings.download.network.title,
    keywords: 'wifi wi-fi cellular mobile data',
    optionTerms: (t) => [
      t.settings.download.network.any_network,
      t.settings.download.network.wifi_only,
      t.settings.download.network.ask_on_mobile_data,
    ].join(" "),
    placements: _downloads_networkPlacements,
  );

  final notifications = SettingDefinition(
    id: 'downloads.notifications',
    label: (t) => t.bulk_downloads.options.enable_notification,
    placements: _downloadsPlacements,
  );

  final skipExistingFiles = SettingDefinition(
    id: 'downloads.skipExistingFiles',
    label: (t) => t.settings.download.skip_existing_files,
    keywords: 'duplicates overwrite',
    description: (t) => t.settings.download.skip_existing_files_explanation,
    placements: _downloadsPlacements,
  );
}

class SettingsSearch {
  SettingsSearch._();

  final autoFocus = SettingDefinition(
    id: 'search.autoFocus',
    label: (t) => t.settings.search.auto_focus_search_bar,
    placements: _searchPlacements,
  );

  final persistentBar = SettingDefinition(
    id: 'search.persistentBar',
    label: (t) => t.settings.search.search_bar.scroll_behavior.persistent,
    description: (t) =>
        t.settings.search.search_bar.scroll_behavior.persistent_description,
    placements: _searchPlacements,
  );

  final barPosition = SettingDefinition(
    id: 'search.barPosition',
    label: (t) => t.settings.search.search_bar.position.search_bar_position,
    placements: _searchPlacements,
  );

  final hideBookmarkedPosts = SettingDefinition(
    id: 'search.hideBookmarkedPosts',
    label: (t) => t.settings.search.hide_bookmarked_posts_from_search_results,
    placements: _searchPlacements,
  );
}

class SettingsAccessibility {
  SettingsAccessibility._();

  final reverseProfileScroll = SettingDefinition(
    id: 'accessibility.reverseProfileScroll',
    label: (t) =>
        t.settings.accessibility.reverseBooruConfigSelectorScrollDirection,
    keywords: 'reverseBooruConfigSelectorScrollDirection',
    placements: _accessibilityPlacements,
  );

  final sidebarSwipeArea = SettingDefinition(
    id: 'accessibility.sidebarSwipeArea',
    label: (t) => t.settings.accessibility.swipeAreaToOpenSidebar,
    keywords: 'swipeAreaToOpenSidebar',
    description: (t) =>
        t.settings.accessibility.swipeAreaToOpenSidebarDescription,
    placements: _accessibilityPlacements,
  );

  final reduceAnimations = SettingDefinition(
    id: 'accessibility.reduceAnimations',
    label: (t) => t.settings.accessibility.reduce_animations,
    keywords: 'motion animation',
    description: (t) => t.settings.accessibility.reduce_animations_description,
    placements: _accessibilityPlacements,
  );

  final volumeNavigation = SettingDefinition(
    id: 'accessibility.volumeNavigation',
    label: (t) => t.settings.accessibility.volume_navigation,
    description: (t) => t.settings.accessibility.volume_navigation_description,
    placements: _accessibilityPlacements,
  );

  final hapticFeedback = SettingDefinition(
    id: 'accessibility.hapticFeedback',
    label: (t) => t.settings.accessibility.haptic_feedback.haptic_feedback,
    keywords: 'vibration vibrate',
    placements: _accessibilityPlacements,
  );
}

class SettingsPrivacy {
  SettingsPrivacy._();

  final appLock = SettingDefinition(
    id: 'privacy.appLock',
    label: (t) => t.settings.privacy.app_lock.title,
    keywords: 'pin biometrics fingerprint face security password',
    placements: _privacyPlacements,
  );

  final hideAppPreview = SettingDefinition(
    id: 'privacy.hideAppPreview',
    label: (t) => t.settings.privacy.app_lock.hide_app_preview,
    description: (t) =>
        t.settings.privacy.app_lock.hide_app_preview_description,
    placements: _privacyPlacements,
  );

  final incognitoKeyboard = SettingDefinition(
    id: 'privacy.incognitoKeyboard',
    label: (t) => t.settings.privacy.enable_incognito_keyboard,
    description: (t) => t.settings.privacy.enable_incognito_keyboard_notice,
    placements: _privacy_incognitoKeyboardPlacements,
  );
}

class SettingsAppLock {
  SettingsAppLock._();

  final type = SettingDefinition(
    id: 'appLock.type',
    label: (t) => t.settings.privacy.app_lock.title,
    keywords: 'pin biometrics fingerprint face security password',
    description: (t) => t.settings.privacy.app_lock.description,
    placements: _appLockPlacements,
  );

  final changePin = SettingDefinition(
    id: 'appLock.changePin',
    label: (t) => t.settings.privacy.app_lock.change_pin,
    description: (t) => t.settings.privacy.app_lock.change_pin_description,
    placements: _appLock_changePinPlacements,
  );

  final timeout = SettingDefinition(
    id: 'appLock.timeout',
    label: (t) => t.settings.privacy.app_lock.lock_after,
    description: (t) => t.settings.privacy.app_lock.lock_after_description,
    placements: _appLock_timeoutPlacements,
  );
}

class SettingsStorage {
  SettingsStorage._();

  final clearCacheOnStartUp = SettingDefinition(
    id: 'storage.clearCacheOnStartUp',
    label: (t) => t.settings.data_and_storage.clear_cache_on_start_up,
    keywords: 'delete clean',
    placements: _storagePlacements,
  );

  final imageOnlyCache = SettingDefinition(
    id: 'storage.imageOnlyCache',
    label: (t) => t.settings.data_and_storage.image_only_cache,
    placements: _storagePlacements,
  );

  final videoCache = SettingDefinition(
    id: 'storage.videoCache',
    label: (t) => t.settings.data_and_storage.video_cache,
    placements: _storagePlacements,
  );

  final tagCache = SettingDefinition(
    id: 'storage.tagCache',
    label: (t) => t.settings.data_and_storage.tag_cache,
    placements: _storagePlacements,
  );

  final allCache = SettingDefinition(
    id: 'storage.allCache',
    label: (t) => t.settings.data_and_storage.all_cache,
    placements: _storagePlacements,
  );

  final bookmarkImages = SettingDefinition(
    id: 'storage.bookmarkImages',
    label: (t) => t.settings.data_and_storage.bookmark_images,
    placements: _storagePlacements,
  );

  final videoCacheLimit = SettingDefinition(
    id: 'storage.videoCacheLimit',
    label: (t) => t.settings.data_and_storage.video_cache_limit,
    description: (t) =>
        t.settings.data_and_storage.video_cache_limit_description,
    placements: _storagePlacements,
  );
}

class SettingsListing {
  SettingsListing._();

  final gridSize = SettingDefinition(
    id: 'listing.gridSize',
    label: (t) => t.settings.image_grid.grid_size.grid_size,
    placements: _listingPlacements,
  );

  final list = SettingDefinition(
    id: 'listing.list',
    label: (t) => t.settings.image_list.image_list,
    placements: _listingPlacements,
  );

  final imageQuality = SettingDefinition(
    id: 'listing.imageQuality',
    label: (t) => t.settings.image_grid.image_quality.image_quality,
    keywords: 'original sample preview resolution',
    placements: _listingPlacements,
  );

  final layout = SettingDefinition(
    id: 'listing.layout',
    label: (t) => t.settings.result_layout.result_layout,
    placements: _listingPlacements,
  );

  final pageIndicator = SettingDefinition(
    id: 'listing.pageIndicator',
    label: (t) => t.settings.page_indicator.page_indicator,
    placements: _listing_pageIndicatorPlacements,
  );

  final postsPerPage = SettingDefinition(
    id: 'listing.postsPerPage',
    label: (t) => t.settings.performance.posts_per_page,
    description: (t) => t.settings.performance.posts_per_page_explain,
    placements: _listingPlacements,
  );

  final showScores = SettingDefinition(
    id: 'listing.showScores',
    label: (t) => t.settings.appearance.show_scores,
    placements: _listingPlacements,
  );

  final showConfigHeader = SettingDefinition(
    id: 'listing.showConfigHeader',
    label: (t) => t.settings.appearance.show_post_list_config_header,
    placements: _listingPlacements,
  );

  final blurExplicitMedia = SettingDefinition(
    id: 'listing.blurExplicitMedia',
    label: (t) => t.settings.appearance.blur_explicit_media,
    placements: _listingPlacements,
  );

  final autoPlayGif = SettingDefinition(
    id: 'listing.autoPlayGif',
    label: (t) => t.settings.appearance.auto_play_gif,
    placements: _listingPlacements,
  );

  final cornerRadius = SettingDefinition(
    id: 'listing.cornerRadius',
    label: (t) => t.settings.image_grid.corner_radius,
    placements: _listingPlacements,
  );

  final spacing = SettingDefinition(
    id: 'listing.spacing',
    label: (t) => t.settings.image_grid.spacing,
    placements: _listingPlacements,
  );

  final padding = SettingDefinition(
    id: 'listing.padding',
    label: (t) => t.settings.image_grid.padding,
    placements: _listingPlacements,
  );

  final aspectRatio = SettingDefinition(
    id: 'listing.aspectRatio',
    label: (t) => t.settings.image_grid.aspect_ratio,
    placements: _listingPlacements,
  );

  final profilePlacement = SettingDefinition(
    id: 'listing.profilePlacement',
    label: (t) => t.settings.appearance.booru_config_placement,
    placements: _listing_profilePlacementPlacements,
  );

  final profileLabel = SettingDefinition(
    id: 'listing.profileLabel',
    label: (t) => t.settings.appearance.booru_config_label,
    placements: _listing_profilePlacementPlacements,
  );

  final tooltip = SettingDefinition(
    id: 'listing.tooltip',
    label: (t) => t.booru.listing.tooltip_on_hover_title,
    keywords: 'mouse preview',
    description: (t) => t.booru.listing.tooltip_on_hover_description,
    placements: _listing_tooltipPlacements,
  );

  final thumbnailActions = SettingDefinition(
    id: 'listing.thumbnailActions',
    label: (t) => t.settings_search.thumbnail_actions,
    keywords: 'primary secondary buttons favorite bookmark download grid',
    placements: _listing_tooltipPlacements,
  );

  final profileOverrides = SettingDefinition(
    id: 'listing.profileOverrides',
    label: (t) => t.booru.listing.enable_profile_specific_settings,
    description: (t) =>
        t.booru.listing.enable_profile_specific_settings_description,
    placements: _listing_tooltipPlacements,
  );
}

class SettingsViewer {
  SettingsViewer._();

  final overlay = SettingDefinition(
    id: 'viewer.overlay',
    label: (t) => t.settings.image_details.ui_overlay.ui_overlay,
    placements: _viewerPlacements,
  );

  final swipeMode = SettingDefinition(
    id: 'viewer.swipeMode',
    label: (t) => t.settings.image_viewer.swipe_mode,
    keywords: 'horizontal vertical direction',
    placements: _viewerPlacements,
  );

  final slideshowMode = SettingDefinition(
    id: 'viewer.slideshowMode',
    label: (t) => t.settings.image_viewer.slideshow_mode,
    placements: _viewerPlacements,
  );

  final slideshowInterval = SettingDefinition(
    id: 'viewer.slideshowInterval',
    label: (t) => t.settings.image_viewer.slideshow_interval,
    description: (t) => t.settings.image_viewer.slideshow_interval_explanation,
    placements: _viewerPlacements,
  );

  final slideshowSkip = SettingDefinition(
    id: 'viewer.slideshowSkip',
    label: (t) => t.settings.image_viewer.slideshow_skip,
    placements: _viewerPlacements,
  );

  final slideshowVideoBehavior = SettingDefinition(
    id: 'viewer.slideshowVideoBehavior',
    label: (t) => t.settings.image_viewer.slideshow_video_behavior,
    placements: _viewerPlacements,
  );

  final videoEngine = SettingDefinition(
    id: 'viewer.videoEngine',
    label: (t) => t.settings.image_viewer.video.video_player_engine,
    placements: _viewerPlacements,
  );

  final muteVideo = SettingDefinition(
    id: 'viewer.muteVideo',
    label: (t) => t.settings.image_viewer.mute_video,
    keywords: 'sound audio silent',
    placements: _viewerPlacements,
  );

  final doubleTapSeek = SettingDefinition(
    id: 'viewer.doubleTapSeek',
    label: (t) => t.settings.image_viewer.double_tap_seek,
    placements: _viewerPlacements,
  );

  final videoCache = SettingDefinition(
    id: 'viewer.videoCache',
    label: (t) => t.settings.image_viewer.enable_video_cache,
    description: (t) => t.settings.image_viewer.enable_video_cache_description,
    placements: _viewerPlacements,
  );

  final profileOverrides = SettingDefinition(
    id: 'viewer.profileOverrides',
    label: (t) => t.booru.listing.enable_profile_specific_settings,
    description: (t) =>
        t.booru.listing.enable_profile_specific_settings_description,
    placements: _viewer_profileOverridesPlacements,
  );

  final imageQuality = SettingDefinition(
    id: 'viewer.imageQuality',
    label: (t) => t.settings.image_grid.image_quality.image_quality,
    keywords: 'original sample preview resolution',
    description: (t) => t.settings.image_grid.image_quality.high_quality_notice,
    placements: _viewer_profileOverridesPlacements,
  );

  final autoFetchNotes = SettingDefinition(
    id: 'viewer.autoFetchNotes',
    label: (t) => t.booru.viewer.auto_fetch_notes,
    description: (t) => t.booru.viewer.auto_fetch_notes_description,
    placements: _viewer_autoFetchNotesPlacements,
  );

  final videoQuality = SettingDefinition(
    id: 'viewer.videoQuality',
    label: (t) => t.video_player.video_quality,
    keywords: 'original sample preview resolution',
    placements: _viewer_videoQualityPlacements,
  );
}

class SettingsProfileAppearance {
  SettingsProfileAppearance._();

  final theme = SettingDefinition(
    id: 'profileAppearance.theme',
    label: (t) => t.settings.theme.theme,
    keywords: 'colors dark light customize',
    placements: _profileAppearancePlacements,
  );

  final viewerLayout = SettingDefinition(
    id: 'profileAppearance.viewerLayout',
    label: (t) => t.booru.appearance.image_viewer_layout.title,
    keywords: 'details reorder sections',
    placements: _profileAppearancePlacements,
  );

  final icon = SettingDefinition(
    id: 'profileAppearance.icon',
    label: (t) => t.settings_search.profile_icon,
    keywords: 'avatar image url',
    placements: _profileAppearancePlacements,
  );

  final homeScreen = SettingDefinition(
    id: 'profileAppearance.homeScreen',
    label: (t) => t.booru.appearance.home_screen,
    description: (t) => t.booru.appearance.home_screen_description,
    placements: _profileAppearancePlacements,
  );
}

class SettingsProfile {
  SettingsProfile._();

  final name = SettingDefinition(
    id: 'profile.name',
    label: (t) => t.booru.config_name_label,
    keywords: 'profile rename',
    placements: _listing_tooltipPlacements,
  );
}

class SettingsGestures {
  SettingsGestures._();

  final previewLongPress = SettingDefinition(
    id: 'gestures.previewLongPress',
    label: (t) => t.gestures.long_press,
    keywords: 'thumbnail grid preview hold gesture',
    section: (t) => t.settings.image_grid.image_grid,
    placements: _gesturesPlacements,
  );

  final swipeDown = SettingDefinition(
    id: 'gestures.swipeDown',
    label: (t) => t.gestures.swipe_down,
    section: (t) => t.settings.image_viewer.image_viewer,
    placements: _gesturesPlacements,
  );

  final doubleTap = SettingDefinition(
    id: 'gestures.doubleTap',
    label: (t) => t.gestures.double_tap,
    section: (t) => t.settings.image_viewer.image_viewer,
    placements: _gesturesPlacements,
  );

  final longPress = SettingDefinition(
    id: 'gestures.longPress',
    label: (t) => t.gestures.long_press,
    section: (t) => t.settings.image_viewer.image_viewer,
    placements: _gesturesPlacements,
  );

  final tap = SettingDefinition(
    id: 'gestures.tap',
    label: (t) => t.gestures.tap,
    section: (t) => t.settings.image_grid.image_grid,
    placements: _gesturesPlacements,
  );
}

class SettingsNetwork {
  SettingsNetwork._();

  final mediaHosts = SettingDefinition(
    id: 'network.mediaHosts',
    label: (t) => t.booru.network.media_hosts.title,
    keywords: 'host override cdn image domain',
    placements: _networkPlacements,
  );

  final proxyPassword = SettingDefinition(
    id: 'network.proxyPassword',
    label: (t) => t.booru.network.proxy.password,
    placements: _networkPlacements,
  );

  final proxy = SettingDefinition(
    id: 'network.proxy',
    label: (t) => t.booru.network.proxy.title,
    placements: _networkPlacements,
  );

  final proxyType = SettingDefinition(
    id: 'network.proxyType',
    label: (t) => t.booru.network.proxy.type,
    placements: _networkPlacements,
  );

  final skipCertificateVerification = SettingDefinition(
    id: 'network.skipCertificateVerification',
    label: (t) => t.booru.network.http.skip_cert_verification,
    description: (t) => t.booru.network.http.skip_cert_verification_description,
    placements: _networkPlacements,
  );

  final proxyPort = SettingDefinition(
    id: 'network.proxyPort',
    label: (t) => t.booru.network.proxy.port,
    placements: _networkPlacements,
  );

  final proxyHost = SettingDefinition(
    id: 'network.proxyHost',
    label: (t) => t.booru.network.proxy.host_or_ip,
    placements: _networkPlacements,
  );

  final proxyUsername = SettingDefinition(
    id: 'network.proxyUsername',
    label: (t) => t.booru.network.proxy.username,
    placements: _networkPlacements,
  );

  final httpProtocol = SettingDefinition(
    id: 'network.httpProtocol',
    label: (t) => t.booru.network.http.protocol,
    description: (t) => t.booru.network.http.protocol_description,
    placements: _networkPlacements,
  );
}

class SettingsProfileSearch {
  SettingsProfileSearch._();

  final excludeTags = SettingDefinition(
    id: 'profileSearch.excludeTags',
    label: (t) => t.booru.search.exclude_from_search,
    keywords: 'tags always default query',
    placements: _profileSearchPlacements,
  );

  final includeTags = SettingDefinition(
    id: 'profileSearch.includeTags',
    label: (t) => t.booru.search.include_in_search,
    keywords: 'tags always default query',
    placements: _profileSearchPlacements,
  );

  final hideDeleted = SettingDefinition(
    id: 'profileSearch.hideDeleted',
    label: (t) => t.booru.hide_deleted_label,
    keywords: 'removed posts',
    placements: _profileSearch_hideDeletedPlacements,
  );

  final rating = SettingDefinition(
    id: 'profileSearch.rating',
    label: (t) => t.booru.content_filtering_label,
    keywords: 'rating filter safe sensitive questionable explicit nsfw',
    placements: _profileSearch_ratingPlacements,
  );

  final profileOverrides = SettingDefinition(
    id: 'profileSearch.profileOverrides',
    label: (t) => t.booru.search.enable_profile_specific_settings,
    placements: _profileSearchPlacements,
  );

  final hideBanned = SettingDefinition(
    id: 'profileSearch.hideBanned',
    label: (t) => t.booru.hide_banned_label,
    description: (t) => t.booru.hide_banned_description,
    placements: _profileSearch_hideDeletedPlacements,
  );
}

class SettingsProfileDownloads {
  SettingsProfileDownloads._();

  final filenameFormat = SettingDefinition(
    id: 'profileDownloads.filenameFormat',
    label: (t) => t.booru.downloads.custom_filename_format_invidual,
    keywords: 'naming rename template',
    placements: _profileDownloadsPlacements,
  );

  final bulkFilenameFormat = SettingDefinition(
    id: 'profileDownloads.bulkFilenameFormat',
    label: (t) => t.booru.downloads.custom_filename_format_bulk,
    keywords: 'naming rename template',
    placements: _profileDownloadsPlacements,
  );
}

abstract class SettingsIndex {
  static final appearance = SettingsAppearance._();

  static final downloads = SettingsDownloads._();

  static final search = SettingsSearch._();

  static final accessibility = SettingsAccessibility._();

  static final privacy = SettingsPrivacy._();

  static final appLock = SettingsAppLock._();

  static final storage = SettingsStorage._();

  static final listing = SettingsListing._();

  static final viewer = SettingsViewer._();

  static final profileAppearance = SettingsProfileAppearance._();

  static final profile = SettingsProfile._();

  static final gestures = SettingsGestures._();

  static final network = SettingsNetwork._();

  static final profileSearch = SettingsProfileSearch._();

  static final profileDownloads = SettingsProfileDownloads._();

  static final all = List<SettingDefinition>.unmodifiable([
    appearance.colors,
    appearance.theme,
    appearance.dynamicColor,
    downloads.sidecar,
    downloads.folder,
    downloads.quality,
    downloads.network,
    downloads.notifications,
    downloads.skipExistingFiles,
    search.autoFocus,
    search.persistentBar,
    search.barPosition,
    search.hideBookmarkedPosts,
    accessibility.reverseProfileScroll,
    accessibility.sidebarSwipeArea,
    accessibility.reduceAnimations,
    accessibility.volumeNavigation,
    accessibility.hapticFeedback,
    privacy.appLock,
    privacy.hideAppPreview,
    privacy.incognitoKeyboard,
    appLock.type,
    appLock.changePin,
    appLock.timeout,
    storage.clearCacheOnStartUp,
    storage.imageOnlyCache,
    storage.videoCache,
    storage.tagCache,
    storage.allCache,
    storage.bookmarkImages,
    storage.videoCacheLimit,
    listing.gridSize,
    listing.list,
    listing.imageQuality,
    listing.layout,
    listing.pageIndicator,
    listing.postsPerPage,
    listing.showScores,
    listing.showConfigHeader,
    listing.blurExplicitMedia,
    listing.autoPlayGif,
    listing.cornerRadius,
    listing.spacing,
    listing.padding,
    listing.aspectRatio,
    listing.profilePlacement,
    listing.profileLabel,
    listing.tooltip,
    listing.thumbnailActions,
    listing.profileOverrides,
    viewer.overlay,
    viewer.swipeMode,
    viewer.slideshowMode,
    viewer.slideshowInterval,
    viewer.slideshowSkip,
    viewer.slideshowVideoBehavior,
    viewer.videoEngine,
    viewer.muteVideo,
    viewer.doubleTapSeek,
    viewer.videoCache,
    viewer.profileOverrides,
    viewer.imageQuality,
    viewer.autoFetchNotes,
    viewer.videoQuality,
    profileAppearance.theme,
    profileAppearance.viewerLayout,
    profileAppearance.icon,
    profileAppearance.homeScreen,
    profile.name,
    gestures.previewLongPress,
    gestures.swipeDown,
    gestures.doubleTap,
    gestures.longPress,
    gestures.tap,
    network.mediaHosts,
    network.proxyPassword,
    network.proxy,
    network.proxyType,
    network.skipCertificateVerification,
    network.proxyPort,
    network.proxyHost,
    network.proxyUsername,
    network.httpProtocol,
    profileSearch.excludeTags,
    profileSearch.includeTags,
    profileSearch.hideDeleted,
    profileSearch.rating,
    profileSearch.profileOverrides,
    profileSearch.hideBanned,
    profileDownloads.filenameFormat,
    profileDownloads.bulkFilenameFormat,
  ]);

  static final _appSettings = List<SettingDefinition>.unmodifiable(
    all.where(
      (setting) => setting.placements.any(
        (placement) => placement.scope == SettingsSearchScope.app,
      ),
    ),
  );

  static final _profileSettings = List<SettingDefinition>.unmodifiable(
    all.where(
      (setting) => setting.placements.any(
        (placement) => placement.scope == SettingsSearchScope.profile,
      ),
    ),
  );

  static final pages = List<SettingPageDefinition>.unmodifiable([
    for (final scope in SettingsSearchScope.values)
      for (final category in SettingsCategory.pagesForScope(scope))
        SettingPageDefinition(
          scope: scope,
          category: category,
          keywords: category.keywords,
        ),
  ]);

  static List<SettingDefinition> forScope(SettingsSearchScope scope) =>
      switch (scope) {
        SettingsSearchScope.app => _appSettings,
        SettingsSearchScope.profile => _profileSettings,
      };
}

const _appearance_colorsPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.appearance,
    available: _condition_hasPremium,
  ),
];
const _appearancePlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.appearance,
    available: _condition_notHasPremium,
  ),
];
const _downloadsPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.download,
  ),
];
const _downloads_folderPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.download,
    status: _downloads_folderPlacementsAppStatus,
  ),
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.download,
    status: _downloads_folderPlacementsProfileStatus,
  ),
];
const _downloads_networkPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.download,
    available: _condition_mobileDownloadPolicy,
  ),
];
const _searchPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.search,
  ),
];
const _accessibilityPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.accessibility,
  ),
];
const _privacyPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.privacy,
    searchable: false,
  ),
];
const _privacy_incognitoKeyboardPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.privacy,
    available: _condition_incognitoKeyboardAvailable,
    searchable: false,
  ),
];
const _appLockPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.appLock,
  ),
];
const _appLock_changePinPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.appLock,
    available: _condition_appLockIsPin,
  ),
];
const _appLock_timeoutPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.appLock,
    available: _condition_appLockEnabled,
  ),
];
const _storagePlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.dataAndStorage,
  ),
];
const _listingPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.appearance,
  ),
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.listing,
    status: _listingPlacementsProfileStatus,
  ),
];
const _listing_pageIndicatorPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.appearance,
    available: _condition_appListingPaginated,
  ),
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.listing,
    available: _condition_profileListingPaginated,
    status: _listingPlacementsProfileStatus,
  ),
];
const _listing_profilePlacementPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.appearance,
  ),
];
const _listing_tooltipPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.listing,
  ),
];
const _viewerPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.app,
    category: SettingsCategory.viewer,
  ),
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.viewer,
    status: _viewerPlacementsProfileStatus,
  ),
];
const _viewer_profileOverridesPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.viewer,
  ),
];
const _viewer_autoFetchNotesPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.viewer,
    available: _booruMatches,
  ),
];
const _viewer_videoQualityPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.viewer,
    available: _booruMatches2,
  ),
];
const _profileAppearancePlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.appearance,
  ),
];
const _gesturesPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.gestures,
  ),
];
const _networkPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.network,
  ),
];
const _profileSearchPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.search,
  ),
];
const _profileSearch_hideDeletedPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.search,
    available: _booruMatches3,
  ),
];
const _profileSearch_ratingPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.search,
    available: _booruMatches4,
  ),
];
const _profileDownloadsPlacements = [
  SettingPlacement(
    scope: SettingsSearchScope.profile,
    category: SettingsCategory.download,
  ),
];
bool _condition_hasPremium(SettingsEnvironment env) => env.hasPremium;
bool _condition_notHasPremium(SettingsEnvironment env) => !env.hasPremium;
String? _downloads_folderPlacementsAppStatus(
  Translations t,
  SettingsEnvironment env,
  String profileLabel,
) => env.customDownloadFolder && env.hasProfile
    ? t.settings_search.overridden(profile: profileLabel)
    : null;
String? _downloads_folderPlacementsProfileStatus(
  Translations t,
  SettingsEnvironment env,
  String profileLabel,
) => env.customDownloadFolder
    ? t.settings_search.custom_location
    : t.settings_search.app_folder;
bool _condition_mobileDownloadPolicy(SettingsEnvironment env) =>
    env.mobileDownloadPolicy;
bool _condition_incognitoKeyboardAvailable(SettingsEnvironment env) =>
    env.incognitoKeyboardAvailable;
bool _condition_appLockIsPin(SettingsEnvironment env) => env.appLockIsPin;
bool _condition_appLockEnabled(SettingsEnvironment env) => env.appLockEnabled;
String? _listingPlacementsProfileStatus(
  Translations t,
  SettingsEnvironment env,
  String profileLabel,
) => !env.profileListingEnabled ? t.settings_search.enable_profile : null;
bool _condition_appListingPaginated(SettingsEnvironment env) =>
    env.appListingPaginated;
bool _condition_profileListingPaginated(SettingsEnvironment env) =>
    env.profileListingPaginated;
String? _viewerPlacementsProfileStatus(
  Translations t,
  SettingsEnvironment env,
  String profileLabel,
) => !env.profileViewerEnabled ? t.settings_search.enable_profile : null;
bool _booruMatches(SettingsEnvironment env) =>
    const {20, 21, 23, 25}.contains(env.booruId);
bool _booruMatches2(SettingsEnvironment env) =>
    const {25}.contains(env.booruId);
bool _booruMatches3(SettingsEnvironment env) =>
    const {20}.contains(env.booruId);
bool _booruMatches4(SettingsEnvironment env) =>
    const {20, 21, 23, 24, 25, 30}.contains(env.booruId);
