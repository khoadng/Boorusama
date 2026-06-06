import 'dart:convert';
import 'dart:io';

import 'package:googleapis/androidpublisher/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'repository.dart';
import 'status.dart';

final class GooglePlayReleaseRepository implements PlayReleaseRepository {
  const GooglePlayReleaseRepository({
    required this.serviceAccountJsonFile,
    required this.packageName,
    this.track = 'production',
    this.onProgress,
  });

  final File serviceAccountJsonFile;
  final String packageName;
  final String track;
  final void Function(String message)? onProgress;

  @override
  Future<PlayReleaseStatus> fetchStatus() {
    return _withApi((api, editId) async {
      onProgress?.call('Reading Google Play release metadata.');
      final productionTrack = await api.edits.tracks.get(
        packageName,
        editId,
        track,
      );
      final tracks = await api.edits.tracks.list(packageName, editId);
      final details = await api.edits.details.get(packageName, editId);
      final listings = await api.edits.listings.list(packageName, editId);

      return PlayReleaseStatus(
        track: track,
        production: _trackStatus(productionTrack, fallbackName: track),
        tracks: [
          for (final track in tracks.tracks ?? const <Track>[])
            _trackStatus(track),
        ],
        defaultLanguage: details.defaultLanguage,
        contactEmail: details.contactEmail,
        contactWebsite: details.contactWebsite,
        contactPhone: details.contactPhone,
        listingLanguages: [
          for (final listing in listings.listings ?? const <Listing>[])
            if (listing.language != null) listing.language!,
        ],
      );
    });
  }

  @override
  Future<int> createDraftRelease(PlayDraftRelease release) async {
    final session = await _openEdit();
    var committed = false;

    try {
      onProgress?.call('Uploading Android App Bundle to Google Play.');
      final bundle = await session.api.edits.bundles.upload(
        packageName,
        session.editId,
        uploadMedia: Media(
          release.bundle.openRead(),
          release.bundle.lengthSync(),
        ),
      );
      final versionCode = bundle.versionCode;
      if (versionCode == null) {
        throw StateError('Google Play did not return uploaded versionCode.');
      }

      onProgress?.call('Creating Google Play draft release.');
      await session.api.edits.tracks.update(
        Track(
          track: release.track,
          releases: [
            TrackRelease(
              name: release.name,
              status: 'draft',
              versionCodes: ['$versionCode'],
              releaseNotes: [
                for (final note in release.releaseNotes)
                  LocalizedText(language: note.language, text: note.text),
              ],
            ),
          ],
        ),
        packageName,
        session.editId,
        release.track,
      );

      onProgress?.call('Committing Google Play draft release.');
      await session.api.edits.commit(packageName, session.editId);
      committed = true;
      return versionCode;
    } finally {
      if (!committed) {
        await session.api.edits.delete(packageName, session.editId);
        onProgress?.call('Deleted temporary Google Play edit.');
      }
      session.close();
    }
  }

  Future<T> _withApi<T>(
    Future<T> Function(AndroidPublisherApi api, String editId) body, {
    bool deleteEdit = true,
  }) async {
    final session = await _openEdit();

    try {
      return await body(session.api, session.editId);
    } finally {
      if (deleteEdit) {
        await session.api.edits.delete(packageName, session.editId);
        onProgress?.call('Deleted temporary Google Play edit.');
      }
      session.close();
    }
  }

  Future<_PlayEditSession> _openEdit() async {
    onProgress?.call('Authenticating with Google Play.');
    final credentials = ServiceAccountCredentials.fromJson(
      jsonDecode(serviceAccountJsonFile.readAsStringSync()),
    );
    final client = await clientViaServiceAccount(
      credentials,
      [AndroidPublisherApi.androidpublisherScope],
    );
    final api = AndroidPublisherApi(client);

    onProgress?.call('Creating temporary Google Play edit.');
    final edit = await api.edits.insert(AppEdit(), packageName);
    final editId = edit.id;
    if (editId == null || editId.isEmpty) {
      client.close();
      throw StateError('Google Play did not return a temporary edit id.');
    }

    return _PlayEditSession(api: api, editId: editId, close: client.close);
  }

  PlayTrackStatus _trackStatus(Track track, {String? fallbackName}) {
    return PlayTrackStatus(
      name: track.track ?? fallbackName ?? 'unknown',
      releases: [
        for (final release in track.releases ?? const <TrackRelease>[])
          PlayTrackRelease(
            name: release.name,
            status: release.status,
            versionCodes: [
              for (final code in release.versionCodes ?? const <String>[])
                if (int.tryParse(code) != null) int.parse(code),
            ],
            releaseNotesCount: release.releaseNotes?.length ?? 0,
            userFraction: release.userFraction,
          ),
      ],
    );
  }
}

final class _PlayEditSession {
  const _PlayEditSession({
    required this.api,
    required this.editId,
    required this.close,
  });

  final AndroidPublisherApi api;
  final String editId;
  final void Function() close;
}
