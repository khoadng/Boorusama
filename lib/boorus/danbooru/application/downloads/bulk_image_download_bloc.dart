// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
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

enum BulkImageDownloadStatus {
  initial,
  dataSelected,
  downloadInProgress,
  failure,
  done,
}

class BulkImageDownloadState extends Equatable {
  const BulkImageDownloadState({
    required this.totalCount,
    required this.doneCount,
    required this.storagePath,
    required this.status,
    required this.selectedTags,
    required this.didFetchAllPage,
    required this.downloadQueue,
    required this.downloaded,
  });

  factory BulkImageDownloadState.initial() => const BulkImageDownloadState(
        totalCount: 0,
        doneCount: 0,
        storagePath: '',
        status: BulkImageDownloadStatus.initial,
        selectedTags: [],
        didFetchAllPage: false,
        downloadQueue: [],
        downloaded: [],
      );

  final int totalCount;
  final int doneCount;
  final String storagePath;
  final BulkImageDownloadStatus status;
  final List<String> selectedTags;
  final bool didFetchAllPage;
  final List<int> downloadQueue;
  final List<DownloadImageData> downloaded;

  BulkImageDownloadState copyWith({
    int? totalCount,
    int? doneCount,
    String? storagePath,
    BulkImageDownloadStatus? status,
    List<String>? selectedTags,
    bool? didFetchAllPage,
    List<int>? downloadQueue,
    List<DownloadImageData>? downloaded,
  }) =>
      BulkImageDownloadState(
        totalCount: totalCount ?? this.totalCount,
        doneCount: doneCount ?? this.doneCount,
        storagePath: storagePath ?? this.storagePath,
        status: status ?? this.status,
        selectedTags: selectedTags ?? this.selectedTags,
        didFetchAllPage: didFetchAllPage ?? this.didFetchAllPage,
        downloadQueue: downloadQueue ?? this.downloadQueue,
        downloaded: downloaded ?? this.downloaded,
      );

  @override
  List<Object?> get props => [
        totalCount,
        doneCount,
        storagePath,
        downloadQueue,
        status,
        selectedTags,
        didFetchAllPage,
        downloaded,
      ];
}

abstract class BulkImageDownloadEvent extends Equatable {
  const BulkImageDownloadEvent();
}

class BulkImagesDownloadRequested extends BulkImageDownloadEvent {
  const BulkImagesDownloadRequested({
    required this.tags,
  });

  final List<String> tags;

  @override
  List<Object?> get props => [tags];
}

class BulkImageDownloadReset extends BulkImageDownloadEvent {
  const BulkImageDownloadReset();

  @override
  List<Object?> get props => [];
}

class BulkImageDownloadTagsAdded extends BulkImageDownloadEvent {
  const BulkImageDownloadTagsAdded({
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
    List<String>? initialSelected,
  }) : super(BulkImageDownloadState.initial().copyWith(
          selectedTags: initialSelected,
          status: initialSelected != null && initialSelected.isNotEmpty
              ? BulkImageDownloadStatus.dataSelected
              : null,
        )) {
    // on<BulkImageDownloadRequested>((event, emit) async {
    //   final permission = await Permission.storage.status;
    //   //TODO: ask permission here, set some state to notify user
    //   if (permission != PermissionStatus.granted) {
    //     final status = await Permission.storage.request();
    //     if (status != PermissionStatus.granted) {
    //       emit(state.copyWith(status: BulkImageDownloadStatus.failure));

    //       return;
    //     }
    //   }

    //   final storagePath = await _createSubfolderIfNeeded(
    //     fixInvalidCharacterForPathName(event.tag),
    //   );
    //   emit(state.copyWith(
    //     totalCount: event.postCount,
    //     storagePath: storagePath,
    //   ));

    //   final pages = (event.postCount / 60).ceil();
    //   for (var i = 1; i <= pages; i += 1) {
    //     final posts = await postRepository.getPosts(event.tag, i);

    //     for (final p in posts) {
    //       if (state.downloadItemIds.contains(p.id)) continue;

    //       add(_DownloadRequested(post: p, tagName: event.tag));

    //       emit(state.copyWith(
    //         downloadItemIds: {
    //           ...state.downloadItemIds,
    //           p.id,
    //         },
    //       ));
    //     }
    //   }
    // });

    on<BulkImagesDownloadRequested>((event, emit) async {
      final permission = await Permission.storage.status;
      //TODO: ask permission here, set some state to notify user
      if (permission != PermissionStatus.granted) {
        final status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          emit(state.copyWith(status: BulkImageDownloadStatus.failure));

          return;
        }
      }

      final storagePath = await _createSubfolderIfNeeded(
        fixInvalidCharacterForPathName(event.tags.join('_')),
      );

      emit(state.copyWith(
        storagePath: storagePath,
        status: BulkImageDownloadStatus.downloadInProgress,
      ));

      var page = 1;
      final tags = event.tags.join(' ');
      final intPosts = await postRepository.getPosts(tags, page);
      final postStack = [intPosts];
      var count = 0;

      while (postStack.isNotEmpty) {
        final posts = postStack.removeLast();
        for (final p in posts) {
          if (state.downloadQueue.contains(p.id)) continue;

          add(_DownloadRequested(post: p, tagName: tags));
          count += 1;
          emit(state.copyWith(
            totalCount: count,
          ));
        }
        page += 1;
        final next = await postRepository.getPosts(tags, page);
        if (next.isNotEmpty) {
          postStack.add(next);
        }
      }

      emit(state.copyWith(
        didFetchAllPage: true,
        totalCount: count,
      ));
    });

    on<BulkImageDownloadTagsAdded>((event, emit) {
      emit(state.copyWith(
        selectedTags: [...state.selectedTags, ...event.tags],
        status: BulkImageDownloadStatus.dataSelected,
      ));
    });

    on<BulkImageDownloadReset>((event, emit) {
      emit(BulkImageDownloadState.initial());
    });

    on<_DownloadRequested>(
      (event, emit) async {
        await downloader.enqueueDownload(event.post, folderName: event.tagName);
        emit(state.copyWith(
          downloadQueue: [
            ...state.downloadQueue,
            event.post.id,
          ],
        ));
      },
    );

    on<_DownloadDone>(
      (event, emit) async {
        final queue = [...state.downloadQueue]..remove(event.data.postId);
        print(queue);

        final from = event.data.path;
        final to = '${state.storagePath}/${event.data.fileName}';
        if (kDebugMode) {
          print('Moving $from to $to');
        }
        await moveFile(File(from), to);

        final pathParts = to.split('/').toList();

        emit(state.copyWith(
          doneCount: state.doneCount + 1,
          downloadQueue: queue,
          downloaded: [
            ...state.downloaded,
            DownloadImageData(
              absolutePath: to,
              relativeToPublicFolderPath: pathParts.length > 3
                  ? pathParts.reversed.take(3).toList().reversed.join('/')
                  : to,
              fileName: event.data.fileName,
            ),
          ],
        ));

        if (queue.isEmpty) {
          await Future.delayed(const Duration(seconds: 1));
          emit(state.copyWith(status: BulkImageDownloadStatus.done));
        }
      },
      transformer: sequential(),
    );

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

class DownloadImageData extends Equatable {
  const DownloadImageData({
    required this.absolutePath,
    required this.relativeToPublicFolderPath,
    required this.fileName,
  });

  final String absolutePath;
  final String relativeToPublicFolderPath;
  final String fileName;

  @override
  List<Object?> get props =>
      [absolutePath, relativeToPublicFolderPath, fileName];
}
