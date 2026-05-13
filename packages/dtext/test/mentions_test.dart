import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  group('mentions', () {
    test('accepts common names', () {
      expectDTextCases({
        '@user':
            '<p><a class="dtext-link dtext-user-mention-link" data-user-name="user" href="/users?name=user">@user</a></p>',
        'hi @user':
            '<p>hi <a class="dtext-link dtext-user-mention-link" data-user-name="user" href="/users?name=user">@user</a></p>',
        'multiple @bob @anna':
            '<p>multiple <a class="dtext-link dtext-user-mention-link" data-user-name="bob" href="/users?name=bob">@bob</a> <a class="dtext-link dtext-user-mention-link" data-user-name="anna" href="/users?name=anna">@anna</a></p>',
        '@_cf':
            '<p><a class="dtext-link dtext-user-mention-link" data-user-name="_cf" href="/users?name=_cf">@_cf</a></p>',
        '@.dank':
            '<p><a class="dtext-link dtext-user-mention-link" data-user-name=".dank" href="/users?name=.dank">@.dank</a></p>',
        "@kia'ra":
            '<p><a class="dtext-link dtext-user-mention-link" data-user-name="kia\'ra" href="/users?name=kia%27ra">@kia\'ra</a></p>',
        '@T34/38':
            '<p><a class="dtext-link dtext-user-mention-link" data-user-name="T34/38" href="/users?name=T34%2F38">@T34/38</a></p>',
        '@PostIt-Notes':
            '<p><a class="dtext-link dtext-user-mention-link" data-user-name="PostIt-Notes" href="/users?name=PostIt-Notes">@PostIt-Notes</a></p>',
      });
    });

    test('rejects nonmentions', () {
      for (final input in [
        '@@',
        '@+',
        '@_',
        '@?',
        '@N',
        '@.@',
        '@_@',
        'email@address.com',
        'idolm@ster',
        'Poi!@poi?',
      ]) {
        expect(parse(input), '<p>${escapeHtml(input)}</p>', reason: input);
      }
    });
  });
}
