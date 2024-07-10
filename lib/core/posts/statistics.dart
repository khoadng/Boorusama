// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/dart.dart';

typedef PostStats = ({
  StatisticalSummary scores,
  StatisticalSummary tags,
  double generalRatingPercentage,
  double sensitiveRatingPercentage,
  double questionableRatingPercentage,
  double explicitRatingPercentage,
  Map<String, int> domains,
  Map<String, int> mediaTypes,
});

extension PostStatsDisplay on PostStats {
  String get generalRatingPercentageDisplay =>
      '${(generalRatingPercentage * 100).toStringAsFixed(1)}%';
  String get sensitiveRatingPercentageDisplay =>
      '${(sensitiveRatingPercentage * 100).toStringAsFixed(1)}%';
  String get questionableRatingPercentageDisplay =>
      '${(questionableRatingPercentage * 100).toStringAsFixed(1)}%';
  String get explicitRatingPercentageDisplay =>
      '${(explicitRatingPercentage * 100).toStringAsFixed(1)}%';
}

extension PostStatisticsX on Iterable<Post> {
  PostStats getStats() {
    final scores = map((x) => x.score.toDouble()).toList();
    final tagCounts = map((e) => e.tags.length.toDouble()).toList();

    final ratingMap =
        map((e) => e.rating).toList().count(selector: (e) => e.name);

    final generalRatingPercentage = ratingMap.containsKey(Rating.general.name)
        ? ratingMap[Rating.general.name]! / length
        : 0.0;
    final sensitiveRatingPercentage =
        ratingMap.containsKey(Rating.sensitive.name)
            ? ratingMap[Rating.sensitive.name]! / length
            : 0.0;
    final questionableRatingPercentage =
        ratingMap.containsKey(Rating.questionable.name)
            ? ratingMap[Rating.questionable.name]! / length
            : 0.0;
    final explicitRatingPercentage = ratingMap.containsKey(Rating.explicit.name)
        ? ratingMap[Rating.explicit.name]! / length
        : 0.0;

    final domainMap = countDomain(this);
    final mediaTypeMap =
        map((e) => e.format).toList().count(selector: (e) => e);

    return (
      scores: calculateStats(scores),
      tags: calculateStats(tagCounts),
      generalRatingPercentage: generalRatingPercentage,
      sensitiveRatingPercentage: sensitiveRatingPercentage,
      questionableRatingPercentage: questionableRatingPercentage,
      explicitRatingPercentage: explicitRatingPercentage,
      domains: domainMap,
      mediaTypes: mediaTypeMap,
    );
  }
}

Map<String, int> countDomain(Iterable<Post> posts) {
  final domainMap = <String, int>{};

  for (final post in posts) {
    var domain = switch (post.source) {
      WebSource w => w.uri.host,
      NonWebSource _ => '<non-web source>',
      NoSource _ => '<no source>',
    };

    // remove www. prefix
    if (domain.startsWith('www.')) {
      domain = domain.substring(4);
    }

    if (domainMap.containsKey(domain)) {
      domainMap[domain] = domainMap[domain]! + 1;
    } else {
      domainMap[domain] = 1;
    }
  }

  final toBeMergedDomains = {
    '.fanbox.cc': 'fanbox.cc',
    '.lofter.com': 'lofter.com',
    '.pixiv.net': 'pixiv.net',
    '.pximg.net': 'pixiv.net',
    '.dlsite.com': 'dlsite.com',
    '.tumblr.com': 'tumblr.com',
    '.yande.re': 'yande.re',
    '.fantia.jp': 'fantia.jp',
    '.deviantart.com': 'deviantart.com',
    '.patreon.com': 'patreon.com',
    '.bilibili.com': 'bilibili.com',
    '.artstation.com': 'artstation.com',
    '.nijie.': 'nijie.info',
    '.catbox.moe': 'catbox.moe',
    'imgur.com': 'imgur.com',
    '.gumroad.com': 'gumroad.com',
    '.wixmp.com': 'deviantart.com',
  };

  for (final entry in toBeMergedDomains.entries) {
    _mergeDomain(
      domainMap,
      pattern: entry.key,
      mergedDomain: entry.value,
    );
  }

  // merge x.com and twitter.com to twitter.com
  final count = domainMap['x.com'] ?? 0;
  domainMap.remove('x.com');
  domainMap.update(
    'twitter.com',
    (value) => value + count,
    ifAbsent: () => count,
  );

  return domainMap;
}

void _mergeDomain(
  Map<String, int> domainMap, {
  required String pattern,
  required String mergedDomain,
}) {
  final domains =
      domainMap.keys.where((domain) => domain.contains(pattern)).toList();

  for (final domain in domains) {
    final count = domainMap[domain]!;
    domainMap.remove(domain);
    domainMap.update(
      mergedDomain,
      (value) => value + count,
      ifAbsent: () => count,
    );
  }
}
