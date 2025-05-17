// Flutter imports:
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config.dart';
import '../../../../configs/ref.dart';
import '../../../../router.dart';
import '../../../details_manager/types.dart';
import '../../../post/post.dart';
import '../../routes.dart';

class CurrentPostDetailsPage<T extends Post> extends ConsumerWidget {
  const CurrentPostDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = InheritedDetailsContext.of<T>(context);
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final builder = booruBuilder?.postDetailsPageBuilder;
    final config = ref.watchConfig;

    return InheritedDetailsLayoutSettings(
      settings: DetailsLayoutSettings(
        layoutPreviewDetails: config.layout?.previewDetails,
        layoutDetails: config.layout?.details,
      ),
      child: InheritedDetailsSettings(
        settings: DetailsSettings(
          autoFetchNotes: config.autoFetchNotes,
          auth: config.auth,
          postGestures: config.postGestures,
          config: config,
        ),
        child: builder != null
            ? builder(context, payload)
            : const UnimplementedPage(),
      ),
    );
  }
}

class PayloadPostDetailsPage<T extends Post> extends ConsumerWidget {
  const PayloadPostDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = InheritedDetailsContext.of<T>(context);
    final booruBuilder = ref.watchBooruBuilder(payload.config?.auth);
    final builder = booruBuilder?.postDetailsPageBuilder;

    final config = payload.config;

    if (config == null) {
      return const InvalidPage(message: 'Invalid context: Missing config');
    }

    return InheritedDetailsLayoutSettings(
      settings: DetailsLayoutSettings(
        layoutPreviewDetails: config.layout?.previewDetails,
        layoutDetails: config.layout?.details,
      ),
      child: InheritedDetailsSettings(
        settings: DetailsSettings(
          autoFetchNotes: config.autoFetchNotes,
          auth: config.auth,
          postGestures: config.postGestures,
          config: config,
        ),
        child: builder != null
            ? builder(context, payload)
            : const UnimplementedPage(),
      ),
    );
  }
}

class InheritedDetailsContext<T extends Post> extends InheritedWidget {
  const InheritedDetailsContext({
    required this.context,
    required super.child,
    super.key,
  });

  final DetailsRouteContext<T> context;

  static DetailsRouteContext<T> of<T extends Post>(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<InheritedDetailsContext<T>>();

    return widget?.context ??
        (throw Exception('No InheritedDetailsContext found in context'));
  }

  @override
  bool updateShouldNotify(InheritedDetailsContext<T> oldWidget) {
    return context != oldWidget.context;
  }
}

class DetailsSettings extends Equatable {
  const DetailsSettings({
    required this.autoFetchNotes,
    required this.auth,
    required this.postGestures,
    required this.config,
  });

  final bool autoFetchNotes;
  final BooruConfigAuth auth;
  final PostGestureConfig? postGestures;
  final BooruConfig config;

  DetailsSettings copyWith({
    bool? autoFetchNotes,
    BooruConfigAuth? auth,
    PostGestureConfig? postGestures,
    BooruConfig? config,
  }) {
    return DetailsSettings(
      autoFetchNotes: autoFetchNotes ?? this.autoFetchNotes,
      auth: auth ?? this.auth,
      postGestures: postGestures ?? this.postGestures,
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [
        autoFetchNotes,
        auth,
        postGestures,
        config,
      ];
}

class InheritedDetailsSettings extends InheritedWidget {
  const InheritedDetailsSettings({
    required this.settings,
    required super.child,
    super.key,
  });

  final DetailsSettings settings;
  static DetailsSettings of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<InheritedDetailsSettings>();

    return widget?.settings ??
        (throw Exception('No InheritedDetailsSettings found in context'));
  }

  @override
  bool updateShouldNotify(InheritedDetailsSettings oldWidget) {
    return settings != oldWidget.settings;
  }
}

class DetailsLayoutSettings extends Equatable {
  const DetailsLayoutSettings({
    required this.layoutPreviewDetails,
    required this.layoutDetails,
  });

  final List<CustomDetailsPartKey>? layoutPreviewDetails;
  final List<CustomDetailsPartKey>? layoutDetails;

  DetailsLayoutSettings copyWith({
    List<CustomDetailsPartKey>? layoutPreviewDetails,
    List<CustomDetailsPartKey>? layoutDetails,
  }) {
    return DetailsLayoutSettings(
      layoutPreviewDetails: layoutPreviewDetails ?? this.layoutPreviewDetails,
      layoutDetails: layoutDetails ?? this.layoutDetails,
    );
  }

  @override
  List<Object?> get props => [
        layoutPreviewDetails,
        layoutDetails,
      ];
}

class InheritedDetailsLayoutSettings extends InheritedWidget {
  const InheritedDetailsLayoutSettings({
    required this.settings,
    required super.child,
    super.key,
  });

  final DetailsLayoutSettings settings;
  static DetailsLayoutSettings of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<InheritedDetailsLayoutSettings>();

    return widget?.settings ??
        (throw Exception('No InheritedDetailsLayoutSettings found in context'));
  }

  @override
  bool updateShouldNotify(InheritedDetailsLayoutSettings oldWidget) {
    return settings != oldWidget.settings;
  }
}
