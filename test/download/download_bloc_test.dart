// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';

class MockBulkDownloader extends Mock implements BulkDownloader {}

Stream<DownloadData> _downloadStream({
  required int times,
  Duration duration = const Duration(milliseconds: 200),
}) async* {
  await Future.delayed(const Duration(milliseconds: 100));
  for (var i = 1; i <= times; i++) {
    await Future.delayed(duration);
    yield DownloadData(i, '$i', i.toString());
  }
}

void main() {
  final downloader = MockBulkDownloader();

  group('[download success tests]', () {
    blocTest<DownloadBloc, DownloadState>(
      'download 2 items, no duplicates, no folder name provided',
      setUp: () {
        when(() => downloader.getDownloadDirPath())
            .thenAnswer((invocation) async => 'storage/foobar');
        when(() => downloader.enqueueDownload(
              any(),
              folder: '',
              // folderName: any(named: 'folderName'),
              // ifExistName: any(named: 'ifExistName'),
            )).thenAnswer((invocation) async => true);
        when(() => downloader.stream)
            .thenAnswer((_) => _downloadStream(times: 2));
      },
      tearDown: () {
        reset(downloader);
      },
      build: () => DownloadBloc(
        downloader: downloader,
        duplicateChecker: (item, storagePath) => false,
        fileSizeSelector: (item) => 0,
        filterSelector: (item) => false,
        idSelector: (item) => item,
        itemFetcher: (page, arg, emit, state) async {
          return page == 1 ? [1, 2] : [];
        },
        totalFetcher: (arg) async => 2,
      ),
      act: (bloc) async {
        bloc.add(const DownloadRequested(
          arg: 'foo',
          options: DownloadOptions(
            onlyDownloadNewFile: true,
            storagePath: '',
          ),
        ));

        await Future.delayed(const Duration(seconds: 1));
      },
      expect: () => [
        DownloadState.initial().copyWith(
          //Changed
          totalCount: 2,
          status: DownloadStatus.inProgress,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          //Changed
          queueCount: 1,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          //Changed
          queueCount: 2,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 2,
          //Changed
          didFetchAllPage: true,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 2,
          didFetchAllPage: true,
          //Changed
          downloadQueue: [const QueueData(1, 0)],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 2,
          didFetchAllPage: true,
          //Changed
          downloadQueue: [const QueueData(1, 0), const QueueData(2, 0)],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 2,
          didFetchAllPage: true,
          //Changed
          doneCount: 1,
          downloadQueue: [const QueueData(2, 0)],
          downloaded: [
            const DownloadImageData(
              absolutePath: '1',
              relativeToPublicFolderPath: '1',
              fileName: '1',
            ),
          ],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 2,
          didFetchAllPage: true,
          //Changed
          doneCount: 2,
          downloadQueue: [],
          downloaded: [
            const DownloadImageData(
              absolutePath: '1',
              relativeToPublicFolderPath: '1',
              fileName: '1',
            ),
            const DownloadImageData(
              absolutePath: '2',
              relativeToPublicFolderPath: '2',
              fileName: '2',
            ),
          ],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          queueCount: 2,
          didFetchAllPage: true,
          //Changed
          doneCount: 2,
          downloadQueue: [],
          downloaded: [
            const DownloadImageData(
              absolutePath: '1',
              relativeToPublicFolderPath: '1',
              fileName: '1',
            ),
            const DownloadImageData(
              absolutePath: '2',
              relativeToPublicFolderPath: '2',
              fileName: '2',
            ),
          ],
          //Changed
          status: DownloadStatus.done,
          allDownloadCompleted: true,
        ),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'download 2 items, with first item duplicate, no folder name provided',
      setUp: () {
        when(() => downloader.getDownloadDirPath())
            .thenAnswer((invocation) async => 'storage/foobar');
        when(() => downloader.enqueueDownload(
              any(),
              folder: '',

              // folderName: any(named: 'folderName'),
              // ifExistName: any(named: 'ifExistName'),
            )).thenAnswer((invocation) async => true);
        when(() => downloader.stream)
            .thenAnswer((_) => _downloadStream(times: 2));
      },
      tearDown: () {
        reset(downloader);
      },
      build: () => DownloadBloc(
        downloader: downloader,
        duplicateChecker: (item, storagePath) => item == 1,
        fileSizeSelector: (item) => 0,
        filterSelector: (item) => false,
        idSelector: (item) => item,
        itemFetcher: (page, arg, emit, state) async {
          return page == 1 ? [1, 2] : [];
        },
        totalFetcher: (arg) async => 2,
      ),
      act: (bloc) async {
        bloc.add(const DownloadRequested(
          arg: 'foo',
          options: DownloadOptions(
            onlyDownloadNewFile: true,
            storagePath: '',
          ),
        ));

        await Future.delayed(const Duration(seconds: 1));
      },
      expect: () => [
        DownloadState.initial().copyWith(
          //Changed
          totalCount: 2,
          status: DownloadStatus.inProgress,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          //Changed
          duplicate: 1,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          duplicate: 1,
          //Changed
          queueCount: 1,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 1,
          duplicate: 1,
          //Changed
          didFetchAllPage: true,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 1,
          duplicate: 1,
          didFetchAllPage: true,
          //Changed
          downloadQueue: [const QueueData(2, 0)],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 1,
          duplicate: 1,
          didFetchAllPage: true,
          //Changed
          doneCount: 1,
          downloadQueue: [],
          downloaded: [
            const DownloadImageData(
              absolutePath: '2',
              relativeToPublicFolderPath: '2',
              fileName: '2',
            ),
          ],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          queueCount: 1,
          duplicate: 1,
          didFetchAllPage: true,
          //Changed
          doneCount: 1,
          downloadQueue: [],
          downloaded: [
            const DownloadImageData(
              absolutePath: '2',
              relativeToPublicFolderPath: '2',
              fileName: '2',
            ),
          ],
          //Changed
          status: DownloadStatus.done,
          allDownloadCompleted: true,
        ),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'download 2 items, with first item filtered, no folder name provided',
      setUp: () {
        when(() => downloader.getDownloadDirPath())
            .thenAnswer((invocation) async => 'storage/foobar');
        when(() => downloader.enqueueDownload(
              any(),
              folder: '',

              // folderName: any(named: 'folderName'),
              // ifExistName: any(named: 'ifExistName'),
            )).thenAnswer((invocation) async => true);
        when(() => downloader.stream)
            .thenAnswer((_) => _downloadStream(times: 2));
      },
      tearDown: () {
        reset(downloader);
      },
      build: () => DownloadBloc(
        downloader: downloader,
        duplicateChecker: (item, storagePath) => false,
        fileSizeSelector: (item) => 0,
        filterSelector: (item) => item == 1,
        idSelector: (item) => item,
        itemFetcher: (page, arg, emit, state) async {
          return page == 1 ? [1, 2] : [];
        },
        totalFetcher: (arg) async => 2,
      ),
      act: (bloc) async {
        bloc.add(const DownloadRequested(
          arg: 'foo',
          options: DownloadOptions(
            onlyDownloadNewFile: true,
            storagePath: '',
          ),
        ));

        await Future.delayed(const Duration(seconds: 1));
      },
      expect: () => [
        DownloadState.initial().copyWith(
          //Changed
          totalCount: 2,
          status: DownloadStatus.inProgress,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          //Changed
          filtered: [1],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          filtered: [1],
          //Changed
          queueCount: 1,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 1,
          filtered: [1],
          //Changed
          didFetchAllPage: true,
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 1,
          filtered: [1],
          didFetchAllPage: true,
          //Changed
          downloadQueue: [const QueueData(2, 0)],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          status: DownloadStatus.inProgress,
          queueCount: 1,
          filtered: [1],
          didFetchAllPage: true,
          //Changed
          doneCount: 1,
          downloadQueue: [],
          downloaded: [
            const DownloadImageData(
              absolutePath: '2',
              relativeToPublicFolderPath: '2',
              fileName: '2',
            ),
          ],
        ),
        DownloadState.initial().copyWith(
          totalCount: 2,
          queueCount: 1,
          filtered: [1],
          didFetchAllPage: true,
          doneCount: 1,
          downloadQueue: [],
          downloaded: [
            const DownloadImageData(
              absolutePath: '2',
              relativeToPublicFolderPath: '2',
              fileName: '2',
            ),
          ],
          //Changed
          status: DownloadStatus.done,
          allDownloadCompleted: true,
        ),
      ],
    );
  });

  group('[download misc tests]', () {
    blocTest<DownloadBloc, DownloadState>(
      'download reset',
      setUp: () {
        when(() => downloader.getDownloadDirPath())
            .thenAnswer((invocation) async => 'storage/foobar');
        when(() => downloader.enqueueDownload(
              any(),
              folder: '',

              // folderName: any(named: 'folderName'),
              // ifExistName: any(named: 'ifExistName'),
            )).thenAnswer((invocation) async => true);
        when(() => downloader.stream).thenAnswer((_) => const Stream.empty());
      },
      tearDown: () {
        reset(downloader);
      },
      seed: () => DownloadState.initial().copyWith(
        totalCount: 1,
        queueCount: 1,
        didFetchAllPage: true,
        doneCount: 1,
        downloaded: [
          const DownloadImageData(
            absolutePath: '1',
            relativeToPublicFolderPath: '1',
            fileName: '1',
          ),
        ],
        status: DownloadStatus.done,
        allDownloadCompleted: true,
      ),
      build: () => DownloadBloc(
        downloader: downloader,
        duplicateChecker: (item, storagePath) => false,
        fileSizeSelector: (item) => 0,
        filterSelector: (item) => false,
        idSelector: (item) => item,
        itemFetcher: (page, arg, emit, state) async => [],
        totalFetcher: (arg) async => 2,
      ),
      act: (bloc) => bloc.add(const DownloadReset()),
      expect: () => [
        DownloadState.initial(),
      ],
    );
  });
}
