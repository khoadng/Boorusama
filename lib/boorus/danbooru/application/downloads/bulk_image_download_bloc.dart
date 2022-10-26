// Dart imports:
import 'dart:io';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_count_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/core/domain/error.dart';
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

class QueueData extends Equatable {
  const QueueData(this.postId, this.size);

  final int postId;
  final int size;

  @override
  bool? get stringify => false;

  @override
  String toString() => '$postId';

  @override
  List<Object?> get props => [postId, size];
}

class BulkImageDownloadState extends Equatable {
  const BulkImageDownloadState({
    required this.totalCount,
    required this.doneCount,
    required this.queueCount,
    required this.duplicate,
    required this.estimateDownloadSize,
    required this.downloadedSize,
    required this.filteredPosts,
    required this.storagePath,
    required this.status,
    required this.selectedTags,
    required this.didFetchAllPage,
    required this.downloadQueue,
    required this.downloaded,
    required this.options,
    required this.message,
    required this.allDownloadCompleted,
  });

  factory BulkImageDownloadState.initial() => const BulkImageDownloadState(
        totalCount: 0,
        doneCount: 0,
        queueCount: 0,
        duplicate: 0,
        estimateDownloadSize: 0,
        downloadedSize: 0,
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
          onlyDownloadNewFile: false,
        ),
        message: '',
        allDownloadCompleted: false,
      );

  final int totalCount;
  final int doneCount;
  final int queueCount;
  final int duplicate;
  final int estimateDownloadSize;
  final int downloadedSize;
  final List<FilteredOutPost> filteredPosts;
  final String storagePath;
  final BulkImageDownloadStatus status;
  final List<String> selectedTags;
  final bool didFetchAllPage;
  final List<QueueData> downloadQueue;
  final List<DownloadImageData> downloaded;
  final DownloadOptions options;
  final String message;
  final bool allDownloadCompleted;

  BulkImageDownloadState copyWith({
    int? totalCount,
    int? doneCount,
    int? queueCount,
    int? duplicate,
    int? estimateDownloadSize,
    int? downloadedSize,
    List<FilteredOutPost>? filteredPosts,
    String? storagePath,
    BulkImageDownloadStatus? status,
    List<String>? selectedTags,
    bool? didFetchAllPage,
    List<QueueData>? downloadQueue,
    List<DownloadImageData>? downloaded,
    DownloadOptions? options,
    String? message,
    bool? allDownloadCompleted,
  }) =>
      BulkImageDownloadState(
        totalCount: totalCount ?? this.totalCount,
        doneCount: doneCount ?? this.doneCount,
        queueCount: queueCount ?? this.queueCount,
        duplicate: duplicate ?? this.duplicate,
        estimateDownloadSize: estimateDownloadSize ?? this.estimateDownloadSize,
        downloadedSize: downloadedSize ?? this.downloadedSize,
        filteredPosts: filteredPosts ?? this.filteredPosts,
        storagePath: storagePath ?? this.storagePath,
        status: status ?? this.status,
        selectedTags: selectedTags ?? this.selectedTags,
        didFetchAllPage: didFetchAllPage ?? this.didFetchAllPage,
        downloadQueue: downloadQueue ?? this.downloadQueue,
        downloaded: downloaded ?? this.downloaded,
        options: options ?? this.options,
        message: message ?? this.message,
        allDownloadCompleted: allDownloadCompleted ?? this.allDownloadCompleted,
      );

  @override
  List<Object?> get props => [
        totalCount,
        doneCount,
        queueCount,
        duplicate,
        estimateDownloadSize,
        downloadedSize,
        filteredPosts,
        storagePath,
        downloadQueue,
        status,
        selectedTags,
        didFetchAllPage,
        downloaded,
        options,
        message,
        allDownloadCompleted,
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

class BulkImagesDownloadCancel extends BulkImageDownloadEvent {
  const BulkImagesDownloadCancel();

  @override
  List<Object?> get props => [];
}

class BulkImageDownloadReset extends BulkImageDownloadEvent {
  const BulkImageDownloadReset();

  @override
  List<Object?> get props => [];
}

class BulkImageDownloadSwitchToResutlView extends BulkImageDownloadEvent {
  const BulkImageDownloadSwitchToResutlView();

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

class _DownloadDoneAll extends BulkImageDownloadEvent {
  const _DownloadDoneAll();

  @override
  List<Object?> get props => [];
}

class BulkImageDownloadBloc
    extends Bloc<BulkImageDownloadEvent, BulkImageDownloadState>
    with PostErrorMixin {
  BulkImageDownloadBloc({
    required PostRepository postRepository,
    required PostCountRepository postCountRepository,
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

      final files = Directory(storagePath)
          .listSync()
          .whereType<File>()
          .map((e) => e.path)
          .map(basenameWithoutExtension)
          .toList();

      emit(state.copyWith(
        storagePath: storagePath,
        status: BulkImageDownloadStatus.downloadInProgress,
      ));

      var page = 1;
      final tags = event.tags.join(' ');

      emit(state.copyWith(
        totalCount: await postCountRepository.count(event.tags),
      ));

      // Local function to configure the equivalent repository's function
      Future<List<Post>> getPosts(String tags, int page) async {
        try {
          return await postRepository.getPosts(
            tags,
            page,
            limit: 100,
            includeInvalid: true,
          );
        } catch (e) {
          if (e is BooruError) {
            emit(state.copyWith(message: getErrorMessage(e)));
          }

          return [];
        }
      }

      final intPosts = await getPosts(tags, page);
      final postStack = [intPosts];
      var count = 0;
      var downloadSize = 0;
      var duplicateCount = 0;
      final filtedPosts = [];

      while (postStack.isNotEmpty) {
        final posts = postStack.removeLast();
        for (final p in posts) {
          if (files.contains(p.md5)) {
            duplicateCount += 1;
            emit(state.copyWith(
              duplicate: duplicateCount,
            ));
            if (state.options.onlyDownloadNewFile) {
              continue;
            }
          }
          if (state.downloadQueue.contains(QueueData(p.id, p.fileSize))) {
            continue;
          }
          if (state.status == BulkImageDownloadStatus.done) break;

          await Future.delayed(const Duration(milliseconds: 200));

          if (p.viewable) {
            add(_DownloadRequested(post: p, tagName: tags));
            count += 1;
            downloadSize += p.fileSize;
            emit(state.copyWith(
              queueCount: count,
              duplicate: duplicateCount,
              estimateDownloadSize: downloadSize,
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

    on<BulkImagesDownloadCancel>((event, emit) async {
      emit(state.copyWith(downloadQueue: []));
      await downloader.cancelAll();
      emit(state.copyWith(status: BulkImageDownloadStatus.done));
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
                : fixInvalidCharacterForPathName(folderName),
            randomGenerator,
          ),
        ),
      ));
    });

    on<BulkImageDownloadSwitchToResutlView>((event, emit) {
      if (state.status == BulkImageDownloadStatus.downloadInProgress) {
        emit(state.copyWith(status: BulkImageDownloadStatus.done));
      }
    });

    on<_DownloadRequested>(
      (event, emit) async {
        await downloader.enqueueDownload(event.post, folderName: event.tagName);
        emit(state.copyWith(
          downloadQueue: [
            ...state.downloadQueue,
            QueueData(event.post.id, event.post.fileSize),
          ],
        ));
      },
    );

    on<_DownloadDone>(
      (event, emit) async {
        var queue = <QueueData>[];
        QueueData item;

        // Sometime download queue doesn't contains the data for some reason...
        try {
          item = state.downloadQueue
              .firstWhere((e) => e.postId == event.data.postId);
          queue = <QueueData>[...state.downloadQueue]..remove(item);
        } catch (e) {
          queue = state.downloadQueue;
          item = QueueData(event.data.postId, 0);
        }

        final from = event.data.path;
        final to = '${state.storagePath}/${event.data.fileName}';
        // if (kDebugMode) {
        //   print('Moving $from to $to');
        // }
        await moveFile(File(from), to);

        final pathParts = to.split('/').toList();

        emit(state.copyWith(
          doneCount: state.doneCount + 1,
          downloadQueue: queue,
          downloadedSize: state.downloadedSize + item.size,
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
      },
      transformer: sequential(),
    );

    on<_DownloadDoneAll>((event, emit) async {
      emit(state.copyWith(allDownloadCompleted: true));
    });

    downloader.stream
        .listen(
          (data) => add(_DownloadDone(data: data)),
        )
        .addTo(compositeSubscription);

    stream
        .where((s) => s.didFetchAllPage && s.queueCount == s.doneCount)
        .listen((event) => add(const _DownloadDoneAll()))
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

extension DownloadOptionsX on DownloadOptions {
  bool hasValidFolderName() => !RegExp(r'[\\/*?:"<>|]').hasMatch(folderName);
}

extension BulkImageDownloadStateX on BulkImageDownloadState {
  bool isValidToStartDownload() =>
      selectedTags.isNotEmpty && options.hasValidFolderName();
}

class DownloadOptions extends Equatable {
  const DownloadOptions({
    required this.createNewFolderIfExists,
    required this.folderName,
    required this.randomNameIfExists,
    required this.defaultNameIfEmpty,
    required this.onlyDownloadNewFile,
  });

  DownloadOptions copyWith({
    bool? createNewFolderIfExists,
    String? folderName,
    String? randomNameIfExists,
    String? defaultNameIfEmpty,
    bool? onlyDownloadNewFile,
  }) =>
      DownloadOptions(
        createNewFolderIfExists:
            createNewFolderIfExists ?? this.createNewFolderIfExists,
        folderName: folderName ?? this.folderName,
        randomNameIfExists: randomNameIfExists ?? this.randomNameIfExists,
        defaultNameIfEmpty: defaultNameIfEmpty ?? this.defaultNameIfEmpty,
        onlyDownloadNewFile: onlyDownloadNewFile ?? this.onlyDownloadNewFile,
      );

  final bool createNewFolderIfExists;
  final String folderName;
  final String randomNameIfExists;
  final String defaultNameIfEmpty;
  final bool onlyDownloadNewFile;

  @override
  List<Object?> get props => [
        createNewFolderIfExists,
        folderName,
        randomNameIfExists,
        defaultNameIfEmpty,
        onlyDownloadNewFile,
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
