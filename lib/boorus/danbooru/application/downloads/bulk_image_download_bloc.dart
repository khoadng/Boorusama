// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/core/infra/infra.dart';

class BulkImageDownloadState extends Equatable {
  const BulkImageDownloadState({
    required this.totalCount,
    required this.doneCount,
    required this.downloadItemIds,
    required this.isDone,
    required this.storagePath,
  });

  factory BulkImageDownloadState.initial() => const BulkImageDownloadState(
        totalCount: 0,
        doneCount: 0,
        downloadItemIds: {},
        isDone: false,
        storagePath: '',
      );

  final int totalCount;
  final int doneCount;
  final Set<int> downloadItemIds;
  final bool isDone;
  final String storagePath;

  BulkImageDownloadState copyWith({
    int? totalCount,
    int? doneCount,
    Set<int>? downloadItemIds,
    bool? isDone,
    String? storagePath,
  }) =>
      BulkImageDownloadState(
        totalCount: totalCount ?? this.totalCount,
        doneCount: doneCount ?? this.doneCount,
        downloadItemIds: downloadItemIds ?? this.downloadItemIds,
        isDone: isDone ?? this.isDone,
        storagePath: storagePath ?? this.storagePath,
      );

  @override
  List<Object?> get props => [totalCount, doneCount, downloadItemIds, isDone];
}

abstract class BulkImageDownloadEvent extends Equatable {
  const BulkImageDownloadEvent();
}

class BulkImageDownloadRequested extends BulkImageDownloadEvent {
  const BulkImageDownloadRequested({
    required this.tag,
    required this.postCount,
  });

  final String tag;
  final int postCount;

  @override
  List<Object?> get props => [tag, postCount];
}

class BulkImagesDownloadRequested extends BulkImageDownloadEvent {
  const BulkImagesDownloadRequested({
    required this.tags,
  });

  final List<String> tags;

  @override
  List<Object?> get props => [tags];
}

class _DownloadRequested extends BulkImageDownloadEvent {
  const _DownloadRequested({
    required this.post,
    required this.tagName,
  });

  final Post post;
  final String tagName;

  @override
  List<Object?> get props => [post, tagName];
}

class _DownloadDone extends BulkImageDownloadEvent {
  const _DownloadDone({
    required this.data,
  });

  final DownloadData data;

  @override
  List<Object?> get props => [data];
}

class BulkImageDownloadBloc
    extends Bloc<BulkImageDownloadEvent, BulkImageDownloadState> {
  BulkImageDownloadBloc({
    required PostRepository postRepository,
    required BulkDownloader downloader,
  }) : super(BulkImageDownloadState.initial()) {
    on<BulkImageDownloadRequested>((event, emit) async {
      final permission = await Permission.storage.status;
      //TODO: ask permission here, set some state to notify user
      if (permission != PermissionStatus.granted) {
        final status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          return;
        }
      }

      final storagePath = await _createSubfolderIfNeeded(
        fixInvalidCharacterForPathName(event.tag),
      );
      emit(state.copyWith(
        totalCount: event.postCount,
        storagePath: storagePath,
      ));

      final pages = (event.postCount / 60).ceil();
      for (var i = 1; i <= pages; i += 1) {
        final posts = await postRepository.getPosts(event.tag, i);

        for (final p in posts) {
          if (state.downloadItemIds.contains(p.id)) continue;

          add(_DownloadRequested(post: p, tagName: event.tag));

          emit(state.copyWith(
            downloadItemIds: {
              ...state.downloadItemIds,
              p.id,
            },
          ));
        }
      }
    });

    on<BulkImagesDownloadRequested>((event, emit) async {
      final permission = await Permission.storage.status;
      //TODO: ask permission here, set some state to notify user
      if (permission != PermissionStatus.granted) {
        final status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          return;
        }
      }

      final storagePath = await _createSubfolderIfNeeded(
        fixInvalidCharacterForPathName(event.tags.join('_')),
      );

      emit(state.copyWith(
        storagePath: storagePath,
      ));

      var page = 1;
      final tags = event.tags.join(' ');
      final intPosts = await postRepository.getPosts(tags, page);
      final postStack = [intPosts];

      while (postStack.isNotEmpty) {
        final posts = postStack.removeLast();
        for (final p in posts) {
          if (state.downloadItemIds.contains(p.id)) continue;

          add(_DownloadRequested(post: p, tagName: tags));

          emit(state.copyWith(
            downloadItemIds: {
              ...state.downloadItemIds,
              p.id,
            },
          ));
        }
        page += 1;
        final next = await postRepository.getPosts(tags, page);
        if (next.isNotEmpty) {
          postStack.add(next);
        }
      }
    });

    on<_DownloadRequested>(
      (event, emit) async {
        await downloader.enqueueDownload(event.post, folderName: event.tagName);
        final newset = {
          ...state.downloadItemIds,
          event.post.id,
        };
        emit(state.copyWith(
          downloadItemIds: newset,
          totalCount: newset.length,
        ));
      },
    );

    on<_DownloadDone>((event, emit) async {
      if (state.downloadItemIds.contains(event.data.postId)) {
        final newset = {...state.downloadItemIds};
        // ignore: cascade_invocations
        newset.remove(event.data.postId);
        final from = event.data.path;
        final to = '${state.storagePath}/${event.data.fileName}';
        if (kDebugMode) {
          print('Moving $from to $to');
        }
        await moveFile(File(from), to);
        emit(state.copyWith(
          doneCount: state.totalCount - newset.length,
          downloadItemIds: newset,
        ));
      }
    });

    downloader.stream
        .listen(
          (data) => add(_DownloadDone(data: data)),
        )
        .addTo(compositeSubscription);
  }

  final CompositeSubscription compositeSubscription = CompositeSubscription();

  @override
  Future<void> close() {
    compositeSubscription.dispose();

    return super.close();
  }
}

Future<String> _createSubfolderIfNeeded(
  String folderName,
) async {
  final downloadDir = await IOHelper.getDownloadPath();
  final folder = '$downloadDir/$folderName';

  if (!Directory(folder).existsSync()) {
    Directory(folder).createSync();
  }

  return folder;
}
