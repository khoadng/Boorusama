// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/downloads/filtered_out_post.dart';
import 'package:boorusama/core/domain/posts.dart';

enum BulkDownloadManagerStatus {
  initial,
  dataSelected,
  downloadInProgress,
  failure,
  done,
}

class BulkDownloadManagerState extends Equatable {
  const BulkDownloadManagerState({
    required this.status,
    required this.selectedTags,
    required this.options,
    required DownloadState<Post> downloadState,
  }) : _downloadState = downloadState;

  factory BulkDownloadManagerState.initial() => BulkDownloadManagerState(
        status: BulkDownloadManagerStatus.initial,
        selectedTags: const [],
        options: const DownloadOptions(
          onlyDownloadNewFile: true,
          storagePath: '',
        ),
        downloadState: DownloadState<Post>.initial(),
      );

  int get totalCount => _downloadState.totalCount;
  int get doneCount => _downloadState.doneCount;
  int get queueCount => _downloadState.queueCount;
  int get duplicate => _downloadState.duplicate;
  int get estimateDownloadSize => _downloadState.estimateDownloadSize;
  int get downloadedSize => _downloadState.downloadedSize;
  List<FilteredOutPost> get filteredPosts => []; //TODO: temp
  List<DownloadImageData> get downloaded => _downloadState.downloaded;
  bool get allDownloadCompleted => _downloadState.allDownloadCompleted;
  String get message => _downloadState.errorMessage;

  final BulkDownloadManagerStatus status;
  final List<String> selectedTags;
  final DownloadOptions options;

  final DownloadState<Post> _downloadState;

  BulkDownloadManagerState copyWith({
    BulkDownloadManagerStatus? status,
    List<String>? selectedTags,
    DownloadOptions? options,
    DownloadState<Post>? downloadState,
  }) =>
      BulkDownloadManagerState(
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

abstract class BulkDownloadManagerEvent extends Equatable {
  const BulkDownloadManagerEvent();
}

class BulkDownloadManagerRequested<T> extends BulkDownloadManagerEvent {
  const BulkDownloadManagerRequested({
    required this.tags,
  });

  final List<T> tags;

  @override
  List<Object?> get props => [
        tags,
      ];
}

class BulkDownloadManagerCancel extends BulkDownloadManagerEvent {
  const BulkDownloadManagerCancel();

  @override
  List<Object?> get props => [];
}

class BulkDownloadManagerReset extends BulkDownloadManagerEvent {
  const BulkDownloadManagerReset();

  @override
  List<Object?> get props => [];
}

class BulkDownloadManagerSwitchToResutlView extends BulkDownloadManagerEvent {
  const BulkDownloadManagerSwitchToResutlView();

  @override
  List<Object?> get props => [];
}

class BulkDownloadManagerOptionsChanged extends BulkDownloadManagerEvent {
  const BulkDownloadManagerOptionsChanged({
    required this.options,
  });

  final DownloadOptions options;

  @override
  List<Object?> get props => [options];
}

class BulkDownloadManagerTagsAdded extends BulkDownloadManagerEvent {
  const BulkDownloadManagerTagsAdded({
    required this.tags,
  });

  final List<String>? tags;

  @override
  List<Object?> get props => [tags];
}

class BulkDownloadManagerTagRemoved extends BulkDownloadManagerEvent {
  const BulkDownloadManagerTagRemoved({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class _DownloadStateChanged extends BulkDownloadManagerEvent {
  const _DownloadStateChanged({
    required this.dState,
  });

  final DownloadState<Post> dState;

  @override
  List<Object?> get props => [dState];
}

class BulkDownloadManagerBloc<E extends Post>
    extends Bloc<BulkDownloadManagerEvent, BulkDownloadManagerState> {
  BulkDownloadManagerBloc({
    required this.bulkPostDownloadBloc,
    required Future<PermissionStatus> Function() permissionChecker,
    required Future<PermissionStatus> Function() permissionRequester,
  }) : super(BulkDownloadManagerState.initial()) {
    on<BulkDownloadManagerRequested>((event, emit) async {
      final permission = await permissionChecker();
      //TODO: ask permission here, set some state to notify user
      if (permission != PermissionStatus.granted) {
        final status = await permissionRequester();
        if (status != PermissionStatus.granted) {
          emit(state.copyWith(status: BulkDownloadManagerStatus.failure));

          return;
        }
      }

      emit(state.copyWith(
        status: BulkDownloadManagerStatus.downloadInProgress,
      ));

      bulkPostDownloadBloc.add(
        DownloadRequested(arg: event.tags.join(' '), options: state.options),
      );
    });

    on<BulkDownloadManagerCancel>((event, emit) async {
      bulkPostDownloadBloc.add(const DownloadCancel());
      emit(state.copyWith(status: BulkDownloadManagerStatus.done));
    });

    on<BulkDownloadManagerTagsAdded>((event, emit) {
      if (event.tags == null) return;

      final tags = [...state.selectedTags, ...event.tags!];

      emit(state.copyWith(
        selectedTags: tags,
        status: BulkDownloadManagerStatus.dataSelected,
      ));
    });

    on<BulkDownloadManagerTagRemoved>((event, emit) {
      final tags = [
        ...state.selectedTags,
      ]..remove(event.tag);

      emit(state.copyWith(
        selectedTags: tags,
        status: BulkDownloadManagerStatus.dataSelected,
      ));
    });

    on<BulkDownloadManagerReset>((event, emit) {
      bulkPostDownloadBloc.add(const DownloadReset());
      emit(BulkDownloadManagerState.initial());
    });

    on<BulkDownloadManagerOptionsChanged>((event, emit) {
      emit(state.copyWith(
        options: event.options,
      ));
    });

    on<BulkDownloadManagerSwitchToResutlView>((event, emit) {
      if (state.status == BulkDownloadManagerStatus.downloadInProgress) {
        emit(state.copyWith(status: BulkDownloadManagerStatus.done));
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
  final DownloadBloc<String, E> bulkPostDownloadBloc;

  @override
  Future<void> close() {
    compositeSubscription.dispose();
    bulkPostDownloadBloc.close();

    return super.close();
  }
}

extension BulkImageDownloadStateX on BulkDownloadManagerState {
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
