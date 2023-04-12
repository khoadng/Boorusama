// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/downloads.dart';

enum BulkImageDownloadStatus {
  initial,
  dataSelected,
  downloadInProgress,
  failure,
  done,
}

class BulkImageDownloadState extends Equatable {
  const BulkImageDownloadState({
    required this.status,
    required this.selectedTags,
    required this.options,
    required DownloadState<DanbooruPost> downloadState,
  }) : _downloadState = downloadState;

  factory BulkImageDownloadState.initial() => BulkImageDownloadState(
        status: BulkImageDownloadStatus.initial,
        selectedTags: const [],
        options: const DownloadOptions(
          onlyDownloadNewFile: true,
          storagePath: '',
        ),
        downloadState: DownloadState<DanbooruPost>.initial(),
      );

  int get totalCount => _downloadState.totalCount;
  int get doneCount => _downloadState.doneCount;
  int get queueCount => _downloadState.queueCount;
  int get duplicate => _downloadState.duplicate;
  int get estimateDownloadSize => _downloadState.estimateDownloadSize;
  int get downloadedSize => _downloadState.downloadedSize;
  List<FilteredOutPost> get filteredPosts =>
      _downloadState.filtered.map((e) => FilteredOutPost.from(e)).toList();
  List<DownloadImageData> get downloaded => _downloadState.downloaded;
  bool get allDownloadCompleted => _downloadState.allDownloadCompleted;
  String get message => _downloadState.errorMessage;

  final BulkImageDownloadStatus status;
  final List<String> selectedTags;
  final DownloadOptions options;

  final DownloadState<DanbooruPost> _downloadState;

  BulkImageDownloadState copyWith({
    BulkImageDownloadStatus? status,
    List<String>? selectedTags,
    DownloadOptions? options,
    DownloadState<DanbooruPost>? downloadState,
  }) =>
      BulkImageDownloadState(
        status: status ?? this.status,
        selectedTags: selectedTags ?? this.selectedTags,
        options: options ?? this.options,
        downloadState: downloadState ?? _downloadState,
      );

  @override
  List<Object?> get props => [
        status,
        selectedTags,
        options,
        message,
        _downloadState,
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

class _DownloadStateChanged extends BulkImageDownloadEvent {
  const _DownloadStateChanged({
    required this.dState,
  });

  final DownloadState<DanbooruPost> dState;

  @override
  List<Object?> get props => [dState];
}

class BulkImageDownloadBloc
    extends Bloc<BulkImageDownloadEvent, BulkImageDownloadState> {
  BulkImageDownloadBloc({
    required BulkPostDownloadBloc bulkPostDownloadBloc,
    required Future<PermissionStatus> Function() permissionChecker,
    required Future<PermissionStatus> Function() permissionRequester,
  }) : super(BulkImageDownloadState.initial()) {
    on<BulkImagesDownloadRequested>((event, emit) async {
      final permission = await permissionChecker();
      //TODO: ask permission here, set some state to notify user
      if (permission != PermissionStatus.granted) {
        final status = await permissionRequester();
        if (status != PermissionStatus.granted) {
          emit(state.copyWith(status: BulkImageDownloadStatus.failure));

          return;
        }
      }

      emit(state.copyWith(
        status: BulkImageDownloadStatus.downloadInProgress,
      ));

      bulkPostDownloadBloc.add(
        DownloadRequested(arg: event.tags.join(' '), options: state.options),
      );
    });

    on<BulkImagesDownloadCancel>((event, emit) async {
      bulkPostDownloadBloc.add(const DownloadCancel());
      emit(state.copyWith(status: BulkImageDownloadStatus.done));
    });

    on<BulkImageDownloadTagsAdded>((event, emit) {
      if (event.tags == null) return;

      final tags = [...state.selectedTags, ...event.tags!];

      emit(state.copyWith(
        selectedTags: tags,
        status: BulkImageDownloadStatus.dataSelected,
      ));
    });

    on<BulkImageDownloadTagRemoved>((event, emit) {
      final tags = [
        ...state.selectedTags,
      ]..remove(event.tag);

      emit(state.copyWith(
        selectedTags: tags,
        status: BulkImageDownloadStatus.dataSelected,
      ));
    });

    on<BulkImageDownloadReset>((event, emit) {
      bulkPostDownloadBloc.add(const DownloadReset());
      emit(BulkImageDownloadState.initial());
    });

    on<BulkImageDownloadOptionsChanged>((event, emit) {
      emit(state.copyWith(
        options: event.options,
      ));
    });

    on<BulkImageDownloadSwitchToResutlView>((event, emit) {
      if (state.status == BulkImageDownloadStatus.downloadInProgress) {
        emit(state.copyWith(status: BulkImageDownloadStatus.done));
      }
    });

    on<_DownloadStateChanged>((event, emit) {
      emit(state.copyWith(downloadState: event.dState));
    });

    bulkPostDownloadBloc.stream
        .distinct()
        .listen((event) => add(_DownloadStateChanged(dState: event)))
        .addTo(compositeSubscription);
  }

  final CompositeSubscription compositeSubscription = CompositeSubscription();

  @override
  Future<void> close() {
    compositeSubscription.dispose();

    return super.close();
  }
}

extension BulkImageDownloadStateX on BulkImageDownloadState {
  bool isValidToStartDownload({
    required bool hasScopeStorage,
  }) =>
      selectedTags.isNotEmpty &&
      options.storagePath.isNotEmpty &&
      hasValidStoragePath(hasScopeStorage: hasScopeStorage);

  bool shouldDisplayWarning({
    required bool hasScopeStorage,
  }) {
    if (options.storagePath.isEmpty) return false;

    return !hasValidStoragePath(hasScopeStorage: hasScopeStorage);
  }

  bool hasValidStoragePath({
    required bool hasScopeStorage,
  }) {
    if (options.storagePath.isEmpty) return false;
    if (!isInternalStorage(options.storagePath)) return false;

    // ignore: avoid_bool_literals_in_conditional_expressions
    return hasScopeStorage
        ? !isNonPublicDirectories(options.storagePath)
        : true;
  }

  List<String> get allowedFolders => _allowedFolders;

  double get percentCompletion {
    if (estimateDownloadSize == 0) return 0;

    return downloadedSize / estimateDownloadSize;
  }
}

const String _basePath = '/storage/emulated/0';
const List<String> _allowedFolders = [
  'Download',
  'Downloads',
  'Documents',
  'Pictures',
];

bool isInternalStorage(String? path) {
  if (path == null) return false;

  return path.startsWith(_basePath);
}

bool isNonPublicDirectories(String? path) {
  try {
    if (path == null) return false;
    if (!isInternalStorage(path)) return false;

    final nonBasePath = path.replaceAll('$_basePath/', '');
    final paths = nonBasePath.split('/');

    if (paths.isEmpty) return true;
    if (!_allowedFolders.contains(paths.first)) return true;

    return false;
  } catch (e) {
    return false;
  }
}
