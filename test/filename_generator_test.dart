// Package imports:
import 'package:clock/clock.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/feats/filename_generators/filename_generator.dart';

void main() {
  test('generateFileName replaces tokens correctly', () {
    // Arrange
    Map<String, String> metadata = {
      'id': '123',
      'md5': 'f7deda9c6934179779f63910d5e8d2dc',
      'extension': 'png',
      'artist': 'namu',
      'copyright': 'sword:art/online',
      'character': 'lea:fa'
    };
    String format = '{id}_{artist}_{copyright}_{character}_{md5}.{extension}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(
        filename,
        equals(
            '123_namu_sword_art_online_lea_fa_f7deda9c6934179779f63910d5e8d2dc.png'));
  });

  test('generateFileName replaces tokens correctly when missing data', () {
    // Arrange
    Map<String, String> metadata = {
      'md5': 'f7deda9c6934179779f63910d5e8d2dc',
      'extension': 'png',
      'copyright': 'sword art online',
      'character': 'leafa'
    };
    String format = '{artist}_{copyright}_{character}_{md5}.{extension}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename,
        equals('_sword art online_leafa_f7deda9c6934179779f63910d5e8d2dc.png'));
  });

  test('generateFileName keeps invalid filename characters', () {
    // Arrange
    Map<String, String> metadata = {
      'md5': 'f7deda9c6934179779f63910d5e8d2dc',
      'extension': 'png',
      'artist': 'namu',
      'copyright': 'sword:art/online',
      'character': 'leafa'
    };
    String format = '{artist}_{copyright:unsafe}_{character}_{md5}.{extension}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(
        filename,
        equals(
            'namu_sword:art/online_leafa_f7deda9c6934179779f63910d5e8d2dc.png'));
  });

  test('generateFileName applies maxlength option', () {
    // Arrange
    Map<String, String> metadata = {
      'md5': 'f7deda9c6934179779f63910d5e8d2dc',
      'extension': 'png',
      'artist': 'namu',
      'copyright': 'sword art online',
      'character': 'leafa'
    };
    String format =
        '{artist}_{copyright}_{character}_{md5:maxlength=8}.{extension}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('namu_sword art online_leafa_f7deda9c.png'));
  });

  test('generateFileName applies delimiter option', () {
    // Arrange
    Map<String, String> metadata = {
      'md5': 'f7deda9c6934179779f63910d5e8d2dc',
      'extension': 'png',
      'artist': 'artist_1 artist_2',
      'copyright': 'foo_1 bar_2',
      'character': 'character_1 character_2'
    };
    String format =
        '{artist:delimiter=~} {copyright:delimiter= } {character:delimiter=comma ,case=upper} {md5}.{extension}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(
        filename,
        equals(
            'artist_1~artist_2 foo_1 bar_2 CHARACTER_1, CHARACTER_2 f7deda9c6934179779f63910d5e8d2dc.png'));
  });

  test('generateFileName ignores unknown options', () {
    // Arrange
    Map<String, String> metadata = {
      'md5': 'f7deda9c6934179779f63910d5e8d2dc',
      'extension': 'png',
      'artist': 'namu',
      'copyright': 'sword art online',
      'character': 'leafa'
    };
    String format = '{artist}_{copyright}_{character}_{md5:foo=8}.{extension}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(
        filename,
        equals(
            'namu_sword art online_leafa_f7deda9c6934179779f63910d5e8d2dc.png'));
  });

  test('generateFileName ignores unknown data', () {
    // Arrange
    Map<String, String> metadata = {
      'md5': 'f7deda9c6934179779f63910d5e8d2dc',
      'extension': 'png',
      'foo': 'bar',
      'artist': 'namu',
      'copyright': 'sword art online',
      'character': 'leafa'
    };
    String format = '{artist}_{copyright}_{character}_{md5:foo=8}.{extension}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(
        filename,
        equals(
            'namu_sword art online_leafa_f7deda9c6934179779f63910d5e8d2dc.png'));
  });

  test('generateFileName with date option', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'namu',
    };
    String format = '{artist}_{date:format=dd.MM.yyyy hh:mm}';
    final clock = Clock.fixed(DateTime(2020, 1, 1, 12, 0, 0));

    // Act
    String filename = generateFileName(metadata, format, clock: clock);

    // Assert
    expect(filename, equals('namu_01.01.2020 12:00'));
  });

  test('generateFileName with date token with options', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'namu',
    };
    String format = '{artist}_{date}';
    final clock = Clock.fixed(DateTime(2020, 1, 1, 12, 0, 0));

    // Act
    String filename = generateFileName(metadata, format, clock: clock);

    // Assert
    expect(filename, equals('namu_01-01-2020 12.00'));
  });

  test('generateFileName with rating single letter', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo',
      'rating': 'general',
    };
    String format = '{artist}_{rating:single_letter}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('foo_g'));
  });

  test('generateFileName with source', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo',
      'source': 'https://www.example.com',
    };
    String format = '{artist}_{source}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('foo_https%3A%2F%2Fwww.example.com'));
  });

  test('generateFileName with tag sorted by name', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'b c a d',
      'character': 'b c a d',
    };
    String format = '{artist:sort[name]=asc}_{character:sort[name]=desc}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('a b c d_d c b a'));
  });

  test('generateFileName with tag sorted by length', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'aa aaaa aaa a',
      'character': 'b bbbb bb bbb',
    };
    String format = '{artist:sort[length]=asc}_{character:sort[length]=desc}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('a aa aaa aaaa_bbbb bbb bb b'));
  });

  // test tag with case options (upper, lower, upper_first)
  test('generateFileName with tag case options', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo',
      'character': 'bar',
      'copyright': 'sword art online',
    };
    String format =
        '{artist:case=upper}_{character:case=lower}_{copyright:case=upper_first}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('FOO_bar_Sword art online'));
  });

  test('generateFileName with no modifers options', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo_(123)',
      'character': 'bar_foo_(abc) foobar_(123)_(456) foobar',
    };
    String format = '{character:nomod} drawn by {artist}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('bar_foo foobar drawn by foo_(123)'));
  });

  // test limit option
  test('generateFileName with limit option', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo foo1 foo2 foo3 foo4 foo5 foo6 foo7',
      'character': 'bar',
    };
    String format = '{character} by {artist:limit=2}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('bar by foo foo1'));
  });

  // test unique counter option
  test('generateFileName with unique counter option', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo',
      'character': 'bar',
      'index': '1',
    };
    String format = '{character} by {artist} ({index})';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('bar by foo (1)'));
  });

  // test pad_left option
  test('generateFileName with pad_left option', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo',
      'character': 'bar',
      'index': '1',
    };
    String format = '{character} by {artist} ({index:pad_left=3})';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('bar by foo (001)'));
  });

  // test include_namespace option
  test('generateFileName with include_namespace option', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo/a',
      'character': 'bar',
    };
    String format =
        '{character:include_namespace} by {artist:include_namespace,unsafe=true}';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('character:bar by artist:foo/a'));
  });

  // test floating point separator option
  test('generateFileName with floating point separator option', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo',
      'character': 'bar',
      'aspect_ratio': '1.23',
      'mpixels': '1,23',
    };

    String format =
        '{character} by {artist} ({aspect_ratio:separator=comma}) ({mpixels:separator=dot})';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('bar by foo (1,23) (1.23)'));
  });

  // test floating point precision option
  test('generateFileName with floating point precision option', () {
    // Arrange
    Map<String, String> metadata = {
      'artist': 'foo',
      'character': 'bar',
      'aspect_ratio': '1.23456789',
      'mpixels': '1.23456789',
    };

    String format =
        '{character} by {artist} ({aspect_ratio:precision=0}) ({mpixels:precision=2})';

    // Act
    String filename = generateFileName(metadata, format);

    // Assert
    expect(filename, equals('bar by foo (1) (1.23)'));
  });
}
