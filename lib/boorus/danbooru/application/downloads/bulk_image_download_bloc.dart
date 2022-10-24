// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
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

enum FilteredReason {
  bannedArtist,
  censoredTag,
  unknown,
}

class FilteredOutPost extends Equatable {
  const FilteredOutPost({
    required this.postId,
    required this.reason,
  });

  factory FilteredOutPost.from(Post post) {
    return FilteredOutPost(
      postId: post.id,
      reason: post.isBanned
          ? FilteredReason.bannedArtist
          : post.hasCensoredTags
              ? FilteredReason.censoredTag
              : FilteredReason.unknown,
    );
  }

  final int postId;
  final FilteredReason reason;

  @override
  List<Object?> get props => [postId, reason];
}

class BulkImageDownloadState extends Equatable {
  const BulkImageDownloadState({
    required this.totalCount,
    required this.doneCount,
    required this.filteredPosts,
    required this.storagePath,
    required this.status,
    required this.selectedTags,
    required this.didFetchAllPage,
    required this.downloadQueue,
    required this.downloaded,
    required this.options,
  });

  factory BulkImageDownloadState.initial() => const BulkImageDownloadState(
        totalCount: 0,
        doneCount: 0,
        filteredPosts: [],
        storagePath: '',
        status: BulkImageDownloadStatus.initial,
        selectedTags: [],
        didFetchAllPage: false,
        downloadQueue: [],
        downloaded: [],
        options: DownloadOptions(
          createNewFolderIfExists: false,
          folderName: '',
          randomNameIfExists: 'Default Folder-123',
          defaultNameIfEmpty: 'Default Folder',
        ),
      );

  final int totalCount;
  final int doneCount;
  final List<FilteredOutPost> filteredPosts;
  final String storagePath;
  final BulkImageDownloadStatus status;
  final List<String> selectedTags;
  final bool didFetchAllPage;
  final List<int> downloadQueue;
  final List<DownloadImageData> downloaded;
  final DownloadOptions options;

  BulkImageDownloadState copyWith({
    int? totalCount,
    int? doneCount,
    List<FilteredOutPost>? filteredPosts,
    String? storagePath,
    BulkImageDownloadStatus? status,
    List<String>? selectedTags,
    bool? didFetchAllPage,
    List<int>? downloadQueue,
    List<DownloadImageData>? downloaded,
    DownloadOptions? options,
  }) =>
      BulkImageDownloadState(
        totalCount: totalCount ?? this.totalCount,
        doneCount: doneCount ?? this.doneCount,
        filteredPosts: filteredPosts ?? this.filteredPosts,
        storagePath: storagePath ?? this.storagePath,
        status: status ?? this.status,
        selectedTags: selectedTags ?? this.selectedTags,
        didFetchAllPage: didFetchAllPage ?? this.didFetchAllPage,
        downloadQueue: downloadQueue ?? this.downloadQueue,
        downloaded: downloaded ?? this.downloaded,
        options: options ?? this.options,
      );

  @override
  List<Object?> get props => [
        totalCount,
        doneCount,
        filteredPosts,
        storagePath,
        downloadQueue,
        status,
        selectedTags,
        didFetchAllPage,
        downloaded,
        options,
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
  List<Object?> get props => [
        tags,
      ];
}

class BulkImageDownloadReset extends BulkImageDownloadEvent {
  const BulkImageDownloadReset();

  @override
  List<Object?> get props => [];
}

class BulkImageDownloadOptionsChanged extends BulkImageDownloadEvent {
  const BulkImageDownloadOptionsChanged({
    required this.options,
  });

  final DownloadOptions options;

  @override
  List<Object?> get props => [options];
}

class BulkImageDownloadTagsAdded extends BulkImageDownloadEvent {
  const BulkImageDownloadTagsAdded({
    required this.tags,
  });

  final List<String>? tags;

  @override
  List<Object?> get props => [tags];
}

class BulkImageDownloadTagRemoved extends BulkImageDownloadEvent {
  const BulkImageDownloadTagRemoved({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
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
    required String Function() randomGenerator,
  }) : super(BulkImageDownloadState.initial()) {
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

      // Create new folder to store downloaded images
      final storagePath = await _createFolder(
        state.options,
      );

      emit(state.copyWith(
        storagePath: storagePath,
        status: BulkImageDownloadStatus.downloadInProgress,
      ));

      var page = 1;
      final tags = event.tags.join(' ');

      // Local function to configure the equivalent repository's function
      Future<List<Post>> getPosts(String tags, int page) =>
          postRepository.getPosts(tags, page, limit: 100, includeInvalid: true);

      final intPosts = await getPosts(tags, page);
      final postStack = [intPosts];
      var count = 0;
      final filtedPosts = [];

      while (postStack.isNotEmpty) {
        final posts = postStack.removeLast();
        for (final p in posts) {
          if (state.downloadQueue.contains(p.id)) continue;

          if (isPostValid(p)) {
            add(_DownloadRequested(post: p, tagName: tags));
            count += 1;
            emit(state.copyWith(
              totalCount: count,
            ));
          } else {
            filtedPosts.add(FilteredOutPost.from(p));

            emit(state.copyWith(
              filteredPosts: [...filtedPosts],
            ));
          }
        }
        page += 1;
        final next = await getPosts(tags, page);
        if (next.isNotEmpty) {
          postStack.add(next);
        }
      }

      emit(state.copyWith(
        didFetchAllPage: true,
      ));
    });

    on<BulkImageDownloadTagsAdded>((event, emit) {
      if (event.tags == null) return;

      final tags = [...state.selectedTags, ...event.tags!];
      final folderName = generateFolderName(tags);
      final randomFolderName = generateRandomFolderNameWith(
        folderName,
        randomGenerator,
      );

      emit(state.copyWith(
        selectedTags: tags,
        options: state.options.copyWith(
          randomNameIfExists: randomFolderName,
          defaultNameIfEmpty: generateFolderName(tags),
        ),
        status: BulkImageDownloadStatus.dataSelected,
      ));
    });

    on<BulkImageDownloadTagRemoved>((event, emit) {
      final tags = [
        ...state.selectedTags..remove(event.tag),
      ];
      final folderName = generateFolderName(tags);
      final randomFolderName = generateRandomFolderNameWith(
        folderName,
        randomGenerator,
      );

      emit(state.copyWith(
        selectedTags: tags,
        options: state.options.copyWith(
          randomNameIfExists: randomFolderName,
          defaultNameIfEmpty: generateFolderName(tags),
        ),
        status: BulkImageDownloadStatus.dataSelected,
      ));
    });

    on<BulkImageDownloadReset>((event, emit) {
      emit(BulkImageDownloadState.initial());
    });

    on<BulkImageDownloadOptionsChanged>((event, emit) {
      final folderName = event.options.folderName;
      emit(state.copyWith(
        options: event.options.copyWith(
          randomNameIfExists: generateRandomFolderNameWith(
            folderName.isEmpty
                ? generateFolderName(state.selectedTags)
                : folderName,
            randomGenerator,
          ),
        ),
      ));
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

String randomStringWithDatetime(DateTime time) =>
    '${time.year}.${time.month}.${time.day} at ${time.hour}.${time.minute}.${time.second}';

String generateRandomFolderNameWith(
  String baseName,
  String Function() generator,
) {
  final randomString = generator.call();

  return '$baseName $randomString';
}

String generateFolderName(List<String>? tags) {
  if (tags == null) return 'Default folder';

  return fixInvalidCharacterForPathName(tags.join(' '));
}

class DownloadOptions extends Equatable {
  const DownloadOptions({
    required this.createNewFolderIfExists,
    required this.folderName,
    required this.randomNameIfExists,
    required this.defaultNameIfEmpty,
  });

  DownloadOptions copyWith({
    bool? createNewFolderIfExists,
    String? folderName,
    String? randomNameIfExists,
    String? defaultNameIfEmpty,
  }) =>
      DownloadOptions(
        createNewFolderIfExists:
            createNewFolderIfExists ?? this.createNewFolderIfExists,
        folderName: folderName ?? this.folderName,
        randomNameIfExists: randomNameIfExists ?? this.randomNameIfExists,
        defaultNameIfEmpty: defaultNameIfEmpty ?? this.defaultNameIfEmpty,
      );

  final bool createNewFolderIfExists;
  final String folderName;
  final String randomNameIfExists;
  final String defaultNameIfEmpty;

  @override
  List<Object?> get props => [
        createNewFolderIfExists,
        folderName,
        randomNameIfExists,
        defaultNameIfEmpty,
      ];
}

Future<String> _createFolder(
  DownloadOptions options,
) async {
  final folderName = options.folderName.isEmpty
      ? options.defaultNameIfEmpty
      : options.folderName;
  final downloadDir = await IOHelper.getDownloadPath();
  final folder = '$downloadDir/$folderName';

  var path = folder;

  if (!Directory(path).existsSync()) {
    Directory(path).createSync();
  } else {
    if (options.createNewFolderIfExists) {
      path = '$downloadDir/${options.randomNameIfExists}';
      Directory(path).createSync();
    }
  }

  return path;
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
