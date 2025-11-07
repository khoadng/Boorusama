// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../post/types.dart';
import '../../providers.dart';

class VideoUrlParam extends Equatable {
  const VideoUrlParam({
    required this.post,
    required this.viewer,
    required this.auth,
  });

  final Post post;
  final BooruConfigViewer viewer;
  final BooruConfigAuth auth;

  @override
  List<Object?> get props => [post, viewer, auth];
}

class VideoUrlNotifier
    extends AutoDisposeFamilyNotifier<String, VideoUrlParam> {
  @override
  String build(VideoUrlParam arg) {
    final mediaUrlResolver = ref.watch(
      mediaUrlResolverProvider(arg.auth),
    );
    final initialVideoUrl = mediaUrlResolver.resolveVideoUrl(
      arg.post,
      arg.viewer,
    );

    return initialVideoUrl;
  }

  void setUrl(String value) {
    state = value;
  }
}

final postDetailsVideoUrlProvider =
    AutoDisposeNotifierProviderFamily<VideoUrlNotifier, String, VideoUrlParam>(
      VideoUrlNotifier.new,
    );
