// Package imports:
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';
import 'package:version/version.dart';

// Project imports:
import 'package:boorusama/foundation/package_info.dart';
import 'app_update_checker.dart';

class PlayStoreUpdateChecker implements AppUpdateChecker {
  PlayStoreUpdateChecker({
    required this.packageInfo,
    required this.countryCode,
    required this.languageCode,
    this.playStorePrefixURL = 'play.google.com',
    Client? client,
  }) : _client = client ?? Client();

  final PackageInfo packageInfo;
  final String countryCode;
  final String languageCode;
  final String playStorePrefixURL;

  final Client _client;

  @override
  Future<UpdateStatus> checkForUpdate() async {
    final id = packageInfo.packageName;
    assert(id.isNotEmpty);
    if (id.isEmpty) return const UpdateError('package name is empty');

    final url = lookupURLById(
      id,
      country: countryCode,
      language: languageCode,
    )!;

    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return UpdateError(
            "Can't find an app in the Play Store with the id: $id");
      }

      final document = _decodeResults(response.body);

      if (document == null) {
        return const UpdateError('Failed to decode results');
      }

      final version = document.extractVersion();
      final releaseNotes = document.extractReleaseNotes();
      if (version == null || releaseNotes == null) {
        return const UpdateError('Failed to parse results');
      }

      final storeVersion = Version.parse(version);
      final currentVersion = Version.parse(packageInfo.version);

      if (currentVersion < storeVersion) {
        return UpdateAvailable(
          storeVersion: storeVersion.toString(),
          currentVersion: currentVersion.toString(),
          releaseNotes: releaseNotes,
          storeUrl: url,
        );
      } else {
        return const UpdateNotAvailable();
      }
    } on Exception catch (e) {
      return UpdateError(e);
    }
  }

  String? lookupURLById(
    String id, {
    String? country = 'US',
    String? language = 'en',
    bool useCacheBuster = true,
  }) {
    assert(id.isNotEmpty);
    if (id.isEmpty) return null;

    final Map<String, dynamic> parameters = {'id': id};
    if (country != null && country.isNotEmpty) {
      parameters['gl'] = country;
    }
    if (language != null && language.isNotEmpty) {
      parameters['hl'] = language;
    }
    if (useCacheBuster) {
      parameters['_cb'] = DateTime.now().microsecondsSinceEpoch.toString();
    }
    final url = Uri.https(playStorePrefixURL, '/store/apps/details', parameters)
        .toString();

    return url;
  }
}

extension DocumentX on Document {
  String? extractVersion() {
    try {
      const patternName = ',"name":"';
      const patternVersion = ',[[["';
      const patternCallback = 'AF_initDataCallback';
      const patternEndOfString = '"';

      final scripts = getElementsByTagName('script');
      final infoElements =
          scripts.where((element) => element.text.contains(patternName));
      final additionalInfoElements =
          scripts.where((element) => element.text.contains(patternCallback));
      final additionalInfoElementsFiltered = additionalInfoElements
          .where((element) => element.text.contains(patternVersion));

      final nameElement = infoElements.first.text;
      final storeNameStartIndex =
          nameElement.indexOf(patternName) + patternName.length;
      final storeNameEndIndex = storeNameStartIndex +
          nameElement
              .substring(storeNameStartIndex)
              .indexOf(patternEndOfString);
      final storeName =
          nameElement.substring(storeNameStartIndex, storeNameEndIndex);

      final versionElement = additionalInfoElementsFiltered
          .where((element) => element.text.contains('"$storeName"'))
          .first
          .text;
      final storeVersionStartIndex =
          versionElement.lastIndexOf(patternVersion) + patternVersion.length;
      final storeVersionEndIndex = storeVersionStartIndex +
          versionElement
              .substring(storeVersionStartIndex)
              .indexOf(patternEndOfString);
      final storeVersion = versionElement.substring(
          storeVersionStartIndex, storeVersionEndIndex);

      // storeVersion might be: 'Varies with device', which is not a valid version.
      return Version.parse(storeVersion).toString();
    } catch (e) {
      return null;
    }
  }

  String? extractReleaseNotes() {
    try {
      final sectionElements = querySelectorAll('[itemprop="description"]');

      final rawReleaseNotes = sectionElements.last;
      final releaseNotes = _multilineReleaseNotes(rawReleaseNotes);
      return releaseNotes;
    } catch (e) {
      return null;
    }
  }

  String? extractDescription() {
    try {
      final sectionElements = getElementsByClassName('bARER');
      final descriptionElement = sectionElements.last;
      final description = descriptionElement.text;
      return description;
    } catch (e) {
      return null;
    }
  }

  String? _multilineReleaseNotes(Element rawReleaseNotes) {
    final innerHtml = rawReleaseNotes.innerHtml;
    String? releaseNotes = innerHtml;

    if (releaseNotesSpan.hasMatch(innerHtml)) {
      releaseNotes = releaseNotesSpan.firstMatch(innerHtml)!.group(1);
    }
    // Detect default multiline replacement
    releaseNotes = releaseNotes!.replaceAll('<br>', '\n');

    return releaseNotes;
  }
}

Document? _decodeResults(String jsonResponse) {
  if (jsonResponse.isNotEmpty) {
    final decodedResults = parse(jsonResponse);
    return decodedResults;
  }
  return null;
}

final releaseNotesSpan = RegExp('>(.*?)</span>');
