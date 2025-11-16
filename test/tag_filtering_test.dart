// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/posts/filter/src/check_tag.dart';
import 'package:boorusama/core/posts/filter/src/tag_filter_data.dart';
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/posts/rating/types.dart';
import 'package:boorusama/core/tags/autocompletes/types.dart';

void main() {
  final simpleTestData = {'a', 'b', 'c'}.toTagFilterData();

  group('single tag expressions', () {
    group('without operator', () {
      test('should match existing tag', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, 'a'),
          true,
        );
      });

      test('should not match non-existing tag', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, 'd'),
          false,
        );
      });
    });

    group('NOT operator', () {
      test('should match when tag does not exist', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, '-d'),
          true,
        );
      });

      test('should not match when tag exists', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, '-a'),
          false,
        );
      });
    });

    group('OR operator', () {
      test('should match existing tag', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, '~a'),
          true,
        );
      });

      test('should not match non-existing tag', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, '~d'),
          false,
        );
      });
    });

    group('Metatags', () {
      group('Rating', () {
        group('General rating', () {
          test('should match when rating is general', () {
            expect(
              checkIfTagsContainsRawTagExpression(
                TagFilterData(
                  tags: {'a', 'b', 'c'},
                  rating: Rating.general,
                  score: 0,
                ),
                'rating:general',
              ),
              true,
            );
          });

          test('should not match when rating is not general', () {
            expect(
              checkIfTagsContainsRawTagExpression(
                TagFilterData(
                  tags: {'a', 'b', 'c'},
                  rating: Rating.general,
                  score: 0,
                ),
                'rating:explicit',
              ),
              false,
            );
          });
        });
      });

      group('Score', () {
        test('should match when score is below threshold', () {
          expect(
            checkIfTagsContainsRawTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.general,
                score: -10,
              ),
              'score:<-4',
            ),
            true,
          );
        });

        test('should not match when score is above threshold', () {
          expect(
            checkIfTagsContainsRawTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.general,
                score: 0,
              ),
              'score:<-4',
            ),
            false,
          );
        });
      });

      group('Status', () {
        test('should match when status is active', () {
          expect(
            checkIfTagsContainsRawTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.general,
                score: 0,
                status: StringPostStatus.tryParse('active'),
              ),
              'status:active',
            ),
            true,
          );
        });

        test('should not match when status is different', () {
          expect(
            checkIfTagsContainsRawTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.general,
                score: 0,
                status: StringPostStatus.tryParse('active'),
              ),
              'status:deleted',
            ),
            false,
          );
        });

        test('should not match when status is null', () {
          expect(
            checkIfTagsContainsRawTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.general,
                score: 0,
              ),
              'status:active',
            ),
            false,
          );
        });

        test('should match status case-insensitively', () {
          expect(
            checkIfTagsContainsRawTagExpression(
              TagFilterData(
                tags: {'a', 'b', 'c'},
                rating: Rating.general,
                score: 0,
                status: StringPostStatus.tryParse('Active'),
              ),
              'status:active',
            ),
            true,
          );
        });
      });
    });
  });

  group('multiple tag expressions', () {
    group('AND operator', () {
      test('should match when all tags exist', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, 'a b'),
          true,
        );
      });

      test('should not match when any tag is missing', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, 'a d'),
          false,
        );
      });
    });

    group('OR operator', () {
      test('should match when any tag exists', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, '~a ~b'),
          true,
        );
      });

      test('should not match when no tags exist', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, '~d ~e'),
          false,
        );
      });
    });

    group('NOT operator', () {
      test(
        'should match when required tags exist and excluded tags do not',
        () {
          expect(
            checkIfTagsContainsRawTagExpression(
              {'a', 'b', 'q', 'w'}.toTagFilterData(),
              'a b -c -d',
            ),
            true,
          );
        },
      );

      test('should not match when excluded tags exist', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            {'a', 'b', 'c', 'd'}.toTagFilterData(),
            'a b -c -d',
          ),
          false,
        );
      });

      test('should not match when excluded tags exist', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, 'a b -c -d'),
          false,
        );
      });

      test('should not match when excluded tags exist', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            {'a', 'b', 'd'}.toTagFilterData(),
            'a b -c -d',
          ),
          false,
        );
      });

      test('should not match when excluded tags exist', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            {'q', 'w', 'e', 'r'}.toTagFilterData(),
            'a b -c -d',
          ),
          false,
        );
      });
    });

    group('AND + OR operators', () {
      test('should match when required tag and any OR tag exists', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, 'a ~b ~d'),
          true,
        );
      });

      test('should match when required tag and last OR tag exists', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            {'a', 'b', 'd'}.toTagFilterData(),
            'a ~b ~d',
          ),
          true,
        );
      });

      test(
        'should not match when required tag exists but no OR tags match',
        () {
          expect(
            checkIfTagsContainsRawTagExpression(simpleTestData, 'a ~d ~e'),
            false,
          );
        },
      );

      test(
        'should not match when OR tags exist but required tag is missing',
        () {
          expect(
            checkIfTagsContainsRawTagExpression(simpleTestData, 'd ~a ~b'),
            false,
          );
        },
      );

      test('should not match when both required and OR tags are missing', () {
        expect(
          checkIfTagsContainsRawTagExpression(simpleTestData, 'd ~e'),
          false,
        );
      });
    });

    group('AND + Metatags', () {
      test('should match tag with explicit rating', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
            ),
            'a rating:explicit',
          ),
          true,
        );
      });

      test('should match tag with score below threshold', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: -10,
            ),
            'a score:<-5',
          ),
          true,
        );
      });

      test('should match tag with sufficient downvotes', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: -10,
              downvotes: 10,
            ),
            'a downvotes:>5',
          ),
          true,
        );
      });

      test('should not match tag with general rating', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
            ),
            'a rating:general',
          ),
          false,
        );
      });

      test('should not match tag with score above threshold', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: -1,
            ),
            'a score:<-5',
          ),
          false,
        );
      });

      test('should not match tag with insufficient downvotes', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: -10,
              downvotes: 10,
            ),
            'a downvotes:>15',
          ),
          false,
        );
      });

      test('should not match tag with null downvotes', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: -10,
            ),
            'a downvotes:<5',
          ),
          false,
        );
      });

      test('should match tag with specific uploader id', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              uploaderId: 123,
            ),
            'a uploaderid:123',
          ),
          true,
        );
      });

      test('should not match tag with different uploader id', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              uploaderId: 123,
            ),
            'a uploaderid:321',
          ),
          false,
        );
      });

      test('should match tag with exact source match', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              source: 'https://example.com',
            ),
            'a source:https://example.com',
          ),
          true,
        );
      });

      test('should not match tag with different source', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              source: 'https://example.com',
            ),
            'd source:https://example.com',
          ),
          false,
        );
      });

      test('should match tag with source start match', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              source: 'https://example.com/abc',
            ),
            'a source:https://example.com*',
          ),
          true,
        );
      });

      test('should match tag with source end match', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              source: 'https://example.com/abc',
            ),
            'a source:*example.com/abc',
          ),
          true,
        );
      });

      test('should match tag with source middle match', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              source: 'https://example.com/abc',
            ),
            'a source:*example.com*',
          ),
          true,
        );
      });

      test('should match tag with specific uploader name', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              uploaderName: 'testUser',
            ),
            'a uploader:testUser',
          ),
          true,
        );
      });

      test('should not match tag with different uploader name', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              uploaderName: 'testUser',
            ),
            'a uploader:otherUser',
          ),
          false,
        );
      });

      test('should match uploader name case-insensitively', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              uploaderName: 'TestUser',
            ),
            'a uploader:testuser',
          ),
          true,
        );
      });

      test('should match tag with specific status', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              status: StringPostStatus.tryParse('pending'),
            ),
            'a status:pending',
          ),
          true,
        );
      });

      test('should not match tag with different status', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
              status: StringPostStatus.tryParse('pending'),
            ),
            'a status:approved',
          ),
          false,
        );
      });
    });

    group('NOT + Metatags', () {
      test('should match when rating is not general', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: 0,
            ),
            'a -rating:general',
          ),
          true,
        );
      });

      test('should match low score with non-explicit rating', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.general,
              score: -10,
            ),
            'a score:<-5 -rating:explicit',
          ),
          true,
        );
      });

      test('should not match general rating', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.general,
              score: 0,
            ),
            'a -rating:general',
          ),
          false,
        );
      });

      test('should not match explicit rating with low score', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.explicit,
              score: -100,
            ),
            'a score:<-5 -rating:explicit',
          ),
          false,
        );
      });

      test('should match when status is not deleted', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.general,
              score: 0,
              status: StringPostStatus.tryParse('active'),
            ),
            'a -status:deleted',
          ),
          true,
        );
      });

      test('should not match when status is deleted', () {
        expect(
          checkIfTagsContainsRawTagExpression(
            TagFilterData(
              tags: {'a', 'b', 'c'},
              rating: Rating.general,
              score: 0,
              status: StringPostStatus.tryParse('deleted'),
            ),
            'a -status:deleted',
          ),
          false,
        );
      });
    });
  });

  group('autocomplete filter', () {
    test('should filter out exact matched tag', () {
      final result = filterNsfw(
        [
          AutocompleteData.fromJson(const {'value': 'a', 'label': 'a'}),
          AutocompleteData.fromJson(const {'value': 'b', 'label': 'b'}),
        ],
        {'a'},
      );

      expect(result.length, 1);
      expect(result.first.value, 'b');
    });

    test('should filter out matched tag and its aliases', () {
      final result = filterNsfw(
        [
          AutocompleteData.fromJson(const {'value': 'a_b', 'label': 'a_b'}),
          AutocompleteData.fromJson(
            const {'value': 'xyz', 'label': 'xyz', 'antecedent': 'a_b'},
          ),
          AutocompleteData.fromJson(const {'value': 'b', 'label': 'b'}),
        ],
        {'a_b'},
      );

      expect(result.length, 1);
      expect(result.first.value, 'b');
    });

    test('should filter out tags containing filtered word', () {
      final result = filterNsfw(
        [
          AutocompleteData.fromJson(const {'value': 'ab', 'label': 'ab'}),
          AutocompleteData.fromJson(const {'value': 'a_b', 'label': 'a_b'}),
          AutocompleteData.fromJson(const {'value': 'xyz_a', 'label': 'xyz_a'}),
          AutocompleteData.fromJson(const {'value': 'b', 'label': 'b'}),
        ],
        {'a'},
      );

      expect(result.length, 1);
      expect(result.last.value, 'b');
    });

    test('should filter out tags with matching antecedents', () {
      final result = filterNsfw(
        [
          AutocompleteData.fromJson(
            const {'value': 'foo', 'label': 'foo', 'antecedent': 'a_b'},
          ),
          AutocompleteData.fromJson(
            const {'value': 'foo', 'label': 'foo', 'antecedent': 'b_(a)'},
          ),
          AutocompleteData.fromJson(const {'value': 'b', 'label': 'b'}),
        ],
        {'a'},
      );

      expect(result.length, 1);
      expect(result.first.value, 'b');
    });
  });

  group('regression tests', () {
    group('case-insensitive matching', () {
      final data = {'Foo', 'FOO', 'Foo_Bar', 'foobar'}.toTagFilterData();
      test('should match uppercase tag with lowercase query', () {
        expect(
          checkIfTagsContainsRawTagExpression(data, 'foo'),
          true,
        );
      });

      test('should match underscore-separated tag', () {
        expect(
          checkIfTagsContainsRawTagExpression(data, 'foo_bar'),
          true,
        );
      });

      test('should match sentence case tag', () {
        expect(
          checkIfTagsContainsRawTagExpression(data, 'foo'),
          true,
        );
      });

      test('should match lowercase tag with capitalized query', () {
        expect(
          checkIfTagsContainsRawTagExpression(data, 'Foobar'),
          true,
        );
      });
    });
  });

  group('Edge Cases', () {
    final simpleTestData = {'a', 'b', 'c'}.toTagFilterData();

    test('should return false for empty expression', () {
      // An empty expression yields a TagType with an empty string.
      expect(
        checkIfTagsContainsRawTagExpression(simpleTestData, ''),
        false,
      );
    });

    test('should return false for whitespace-only expression', () {
      // Whitespace expression is not trimmed so it becomes a non-existing tag.
      expect(
        checkIfTagsContainsRawTagExpression(simpleTestData, '   '),
        false,
      );
    });

    test('should match literal "rating:" tag when metatag has no value', () {
      // "rating:" yields a TagType since no value is provided.
      // It then checks for the tag "rating:" in filterData.tags.
      final data = TagFilterData(
        tags: {'rating:'},
        rating: Rating.general,
        score: 0,
      );
      expect(
        checkIfTagsContainsRawTagExpression(data, 'rating:'),
        true,
      );
    });

    test('should return false for uploaderid metatag without value', () {
      // "uploaderid:" yields a TagType (default behavior) and thus looks for "uploaderid:" tag.
      final data = simpleTestData;
      expect(
        checkIfTagsContainsRawTagExpression(data, 'uploaderid:'),
        false,
      );
    });

    test('should return false for uploaderid metatag with non-numeric value', () {
      // "uploaderid:abc" yields uploader id -1, so evaluation returns false unless "-1" is in tags.
      final data = TagFilterData(
        tags: {'uploaderid:abc'},
        rating: Rating.general,
        score: 0,
      );
      expect(
        checkIfTagsContainsRawTagExpression(data, 'uploaderid:abc'),
        false,
      );
    });

    test('should treat unknown metatag prefix as regular tag', () {
      // "unknown:value" is not registered, so it becomes a TagType.
      final data = TagFilterData.tags(tags: {'unknown:value'});
      expect(
        checkIfTagsContainsRawTagExpression(data, 'unknown:value'),
        true,
      );
    });

    test('should treat "-~a" as negation of literal "~a" tag', () {
      // When using a combined operator, the parser takes the first char only.
      // "-~a" is parsed as negative with value "~a"; it will check for tag "~a".
      final data = TagFilterData.tags(tags: {'~a'});
      expect(
        checkIfTagsContainsRawTagExpression(data, '-~a'),
        false, // negative operator inverts matching: since "~a" exists, it should return false.
      );
    });

    test('should treat "~-a" as OR operation for literal "-a" tag', () {
      // For "~-a", it is treated as OR with value "-a". It then checks for tag "-a".
      final data = TagFilterData.tags(tags: {'-a'});
      expect(
        checkIfTagsContainsRawTagExpression(data, '~-a'),
        true,
      );
    });
  });
}
