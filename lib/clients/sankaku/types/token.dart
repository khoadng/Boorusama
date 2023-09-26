class Token {
  final bool success;
  final String tokenType;
  final String accessToken;
  final String refreshToken;
  final CurrentUser currentUser;

  Token({
    required this.success,
    required this.tokenType,
    required this.accessToken,
    required this.refreshToken,
    required this.currentUser,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      success: json['success'],
      tokenType: json['token_type'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      currentUser: CurrentUser.fromJson(json['current_user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token_type': tokenType,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'current_user': currentUser.toJson(),
    };
  }

  @override
  String toString() => 'Token: $accessToken';
}

class CurrentUser {
  final int id;
  final String name;
  final int level;
  final String createdAt;
  final bool favsArePrivate;
  final String avatarUrl;
  final String avatarRating;
  final int postUploadCount;
  final int poolUploadCount;
  final int commentCount;
  final int postUpdateCount;
  final int noteUpdateCount;
  final int wikiUpdateCount;
  final int forumPostCount;
  final int poolUpdateCount;
  final int artistUpdateCount;
  final String lastLoggedInAt;
  final String emailVerificationStatus;
  final bool isVerified;
  final String email;
  final bool hideAds;
  final int subscriptionLevel;
  final bool filterContent;
  final bool receiveDmails;

  CurrentUser({
    required this.id,
    required this.name,
    required this.level,
    required this.createdAt,
    required this.favsArePrivate,
    required this.avatarUrl,
    required this.avatarRating,
    required this.postUploadCount,
    required this.poolUploadCount,
    required this.commentCount,
    required this.postUpdateCount,
    required this.noteUpdateCount,
    required this.wikiUpdateCount,
    required this.forumPostCount,
    required this.poolUpdateCount,
    required this.artistUpdateCount,
    required this.lastLoggedInAt,
    required this.emailVerificationStatus,
    required this.isVerified,
    required this.email,
    required this.hideAds,
    required this.subscriptionLevel,
    required this.filterContent,
    required this.receiveDmails,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      createdAt: json['created_at'],
      favsArePrivate: json['favs_are_private'],
      avatarUrl: json['avatar_url'],
      avatarRating: json['avatar_rating'],
      postUploadCount: json['post_upload_count'],
      poolUploadCount: json['pool_upload_count'],
      commentCount: json['comment_count'],
      postUpdateCount: json['post_update_count'],
      noteUpdateCount: json['note_update_count'],
      wikiUpdateCount: json['wiki_update_count'],
      forumPostCount: json['forum_post_count'],
      poolUpdateCount: json['pool_update_count'],
      artistUpdateCount: json['artist_update_count'],
      lastLoggedInAt: json['last_logged_in_at'],
      emailVerificationStatus: json['email_verification_status'],
      isVerified: json['is_verified'],
      email: json['email'],
      hideAds: json['hide_ads'],
      subscriptionLevel: json['subscription_level'],
      filterContent: json['filter_content'],
      receiveDmails: json['receive_dmails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'created_at': createdAt,
      'favs_are_private': favsArePrivate,
      'avatar_url': avatarUrl,
      'avatar_rating': avatarRating,
      'post_upload_count': postUploadCount,
      'pool_upload_count': poolUploadCount,
      'comment_count': commentCount,
      'post_update_count': postUpdateCount,
      'note_update_count': noteUpdateCount,
      'wiki_update_count': wikiUpdateCount,
      'forum_post_count': forumPostCount,
      'pool_update_count': poolUpdateCount,
      'artist_update_count': artistUpdateCount,
      'last_logged_in_at': lastLoggedInAt,
      'email_verification_status': emailVerificationStatus,
      'is_verified': isVerified,
      'email': email,
      'hide_ads': hideAds,
      'subscription_level': subscriptionLevel,
      'filter_content': filterContent,
      'receive_dmails': receiveDmails,
    };
  }
}
