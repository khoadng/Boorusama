// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/downloads/filename/types.dart';
import '../posts/types.dart';

final e621DownloadFilenameGeneratorProvider =
    Provider.family<DownloadFilenameGenerator, BooruConfigAuth>((ref, config) {
      return DownloadFileNameBuilder<E621Post>(
        defaultFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
        defaultBulkDownloadFileNameFormat:
            kBoorusamaBulkDownloadCustomFileNameFormat,
        sampleData: kE621PostSamples,
        tokenHandlers: [
          WidthTokenHandler(),
          HeightTokenHandler(),
          AspectRatioTokenHandler(),
          TokenHandler('artist', (post, config) => post.artistTags.join(' ')),
          TokenHandler(
            'character',
            (post, config) => post.characterTags.join(' '),
          ),
          TokenHandler(
            'copyright',
            (post, config) => post.copyrightTags.join(' '),
          ),
          TokenHandler('general', (post, config) => post.generalTags.join(' ')),
          TokenHandler('meta', (post, config) => post.metaTags.join(' ')),
          TokenHandler(
            'species',
            (post, config) => post.speciesTags.join(' '),
          ),
          MPixelsTokenHandler(),
        ],
      );
    });

const kE621PostSamples = [
  {
    'id': '123456',
    'artist': 'artist_x_(abc) artist_2',
    'character': 'sonic_the_hedgehog classic_sonic',
    'copyright': 'sonic_the_hedgehog_(comics) sonic_the_hedgehog_(series)',
    'general': 'male solo',
    'meta': 'highres translated',
    'species': 'mammal hedgehog',
    'tags':
        'male solo sonic_the_hedgehog classic_sonic sonic_the_hedgehog_(comics) sonic_the_hedgehog_(series) highres translated mammal hedgehog',
    'extension': 'jpg',
    'md5': '9cf364e77f46183e2ebd75de757488e2',
    'width': '2232',
    'height': '1000',
    'aspect_ratio': '0.44776119402985076',
    'mpixels': '2.232356356345635',
    'source': 'https://example.com/filename.jpg',
    'rating': 'general',
    'index': '0',
  },
  {
    'id': '654321',
    'artist': 'artist_3',
    'character': 'classic_sonic',
    'copyright': 'sega',
    'general': 'male solo',
    'meta': 'highres translated',
    'species': 'mammal hedgehog',
    'tags': 'male solo classic_sonic sega highres translated mammal hedgehog',
    'extension': 'png',
    'md5': '2ebd75de757488e29cf364e77f46183e',
    'width': '1334',
    'height': '2232',
    'aspect_ratio': '0.598744769874477',
    'mpixels': '2.976527856856785678',
    'source': 'https://example.com/example_filename.jpg',
    'rating': 'general',
    'index': '1',
  },
];
