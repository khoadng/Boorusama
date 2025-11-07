// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config/types.dart';
import '../../../../foundation/platform.dart';
import '../../constants.dart';

final danbooruLoginDetailsProvider =
    Provider.family<BooruLoginDetails, BooruConfigAuth>(
      (ref, config) => DanbooruLoginDetails(auth: config),
    );

class DanbooruLoginDetails implements BooruLoginDetails {
  DanbooruLoginDetails({
    required this.auth,
  });

  final BooruConfigAuth auth;

  String? get login => auth.login;
  String? get apiKey => auth.apiKey;
  String get url => auth.url;

  @override
  bool hasLogin() {
    if (login == null || apiKey == null) return false;
    if (login!.isEmpty && apiKey!.isEmpty) return false;

    return true;
  }

  @override
  bool get hasStrictSFW => url == kDanbooruSafeUrl && isIOS();

  @override
  bool get hasSoftSFW => url == kDanbooruSafeUrl;
}
