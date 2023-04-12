// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/core/application/downloads/download_options.dart';
import 'package:boorusama/core/application/downloads/download_state.dart';

enum DownloadStatus {
  notStarted,
  inProgress,
  cancel,
  done,
}

abstract class DownloadEvent<E, T> extends Equatable {
  const DownloadEvent();
}

class DownloadRequested<E, T> extends DownloadEvent<E, T> {
  const DownloadRequested({
    required this.arg,
    required this.options,
  });

  final E arg;
  final DownloadOptions options;

  @override
  List<Object?> get props => [arg, options];
}

class DownloadCancel<E, T> extends DownloadEvent<E, T> {
  const DownloadCancel();

  @override
  List<Object?> get props => [];
}

class DownloadReset<E, T> extends DownloadEvent<E, T> {
  const DownloadReset();

  @override
  List<Object?> get props => [];
}

class _DownloadRequested<E, T> extends DownloadEvent<E, T> {
  const _DownloadRequested({
    required this.item,
    required this.arg,
    required this.options,
  });

  final T item;
  final E arg;
  final DownloadOptions options;

  @override
  List<Object?> get props => [
        item,
        arg,
        options,
      ];
}

class _DownloadDone<E, T> extends DownloadEvent<E, T> {
  const _DownloadDone({
    required this.data,
  });

  final DownloadData data;

  @override
  List<Object?> get props => [data];
}

class _DownloadDoneAll<E, T> extends DownloadEvent<E, T> {
  const _DownloadDoneAll();

  @override
  List<Object?> get props => [];
}

class DownloadBloc<E, T> extends Bloc<DownloadEvent<E, T>, DownloadState<T>> {
  DownloadBloc({
    required BulkDownloader<T> downloader,
    required Future<List<T>> Function(
      int page,
      E arg,
      Emitter<DownloadState> emit,
      DownloadState state,
    )
        itemFetcher,
    required Future<int> Function(E arg) totalFetcher,
    required bool Function(T item, String storagePath) duplicateChecker,
    required bool Function(T item) filterSelector,
    required int Function(T item) idSelector,
    required int Function(T item) fileSizeSelector,
    Future<void> Function()? waitBetweenDownloadRequest,
    void Function(String storagePath)? onDownloadDone,
  }) : super(DownloadState.initial()) {
    on<DownloadRequested<E, T>>(
      (event, emit) async {
        final path = await downloader.getDownloadDirPath();
        final storagePath = event.options.storagePath.isEmpty
            ? path
            : event.options.storagePath;

        emit(state.copyWith(
          totalCount: await totalFetcher(event.arg),
          status: DownloadStatus.inProgress,
        ));

        var page = 1;
        final initialItems = await itemFetcher(page, event.arg, emit, state);
        final itemStack = [initialItems];

        while (itemStack.isNotEmpty) {
          final items = itemStack.removeLast();
          for (final it in items) {
            if (duplicateChecker(it, storagePath)) {
              emit(state.copyWith(
                duplicate: state.duplicate + 1,
              ));
              if (event.options.onlyDownloadNewFile) {
                continue;
              }
            }

            final id = idSelector(it);
            final fileSize = fileSizeSelector(it);

            if (state.downloadQueue.contains(QueueData(id, fileSize))) {
              continue;
            }
            if (state.status == DownloadStatus.cancel) break;

            if (waitBetweenDownloadRequest != null) {
              await waitBetweenDownloadRequest();
            }

            if (filterSelector(it)) {
              emit(state.copyWith(
                filtered: [
                  ...state.filtered,
                  it,
                ],
              ));
            } else {
              add(_DownloadRequested(
                item: it,
                arg: event.arg,
                options: event.options,
              ));

              emit(state.copyWith(
                queueCount: state.queueCount + 1,
                estimateDownloadSize: state.estimateDownloadSize + fileSize,
              ));
            }
          }

          page += 1;
          final next = await itemFetcher(page, event.arg, emit, state);
          if (next.isNotEmpty) {
            itemStack.add(next);
          }
        }

        emit(state.copyWith(
          didFetchAllPage: true,
        ));
      },
      transformer: droppable(),
    );

    on<DownloadCancel<E, T>>((event, emit) async {
      emit(state.copyWith(
        downloadQueue: [],
        status: DownloadStatus.cancel,
      ));
      await downloader.cancelAll();
    });

    on<DownloadReset<E, T>>((event, emit) {
      emit(DownloadState.initial());
    });

    on<_DownloadRequested<E, T>>(
      (event, emit) async {
        await downloader.enqueueDownload(
          event.item,
          folder: event.options.storagePath,
        );

        emit(state.copyWith(
          downloadQueue: [
            ...state.downloadQueue,
            QueueData(idSelector(event.item), fileSizeSelector(event.item)),
          ],
        ));
      },
    );

    on<_DownloadDone<E, T>>(
      (event, emit) async {
        var queue = <QueueData>[];
        QueueData item;

        // Size doesn't matter here so just leave at 0 for easier comparison
        if (!state.downloadQueue.contains(QueueData(event.data.itemId, 0))) {
          return;
        }

        // Sometime download queue doesn't contains the data for some reason...
        try {
          item = state.downloadQueue
              .firstWhere((e) => e.itemId == event.data.itemId);
          queue = <QueueData>[...state.downloadQueue]..remove(item);
        } catch (e) {
          queue = state.downloadQueue;
          item = QueueData(event.data.itemId, 0);
        }

        final to = event.data.path;

        final pathParts = to.split('/').toList();

        onDownloadDone?.call(to);

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

    on<_DownloadDoneAll<E, T>>((event, emit) async {
      emit(state.copyWith(
        allDownloadCompleted: true,
        status: DownloadStatus.done,
      ));
    });

    downloader.stream
        .listen(
          (data) => add(_DownloadDone(data: data)),
        )
        .addTo(compositeSubscription);

    stream
        .where((s) => s.status == DownloadStatus.inProgress)
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
