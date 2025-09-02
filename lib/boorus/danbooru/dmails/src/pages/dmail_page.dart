// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../client_provider.dart';
import '../../../users/creator/providers.dart';
import '../../../users/user/providers.dart';
import '../data/providers.dart';
import 'dmail_details_page.dart';

class DanbooruDmailPage extends ConsumerStatefulWidget {
  const DanbooruDmailPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruDmailPageState();
}

class _DanbooruDmailPageState extends ConsumerState<DanbooruDmailPage> {
  var _selectedFolder = DmailFolderType.received;

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final dmailProvider = danbooruDmailsProvider((config, _selectedFolder));
    final client = ref.watch(danbooruClientProvider(config));
    final userColor = DanbooruUserColor.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.profile.messages.title),
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () => ref.invalidate(dmailProvider),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: _selectedFolder,
              onChanged: (value) => setState(
                () => _selectedFolder = value ?? DmailFolderType.all,
              ),
              items: DmailFolderType.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(switch (e) {
                        DmailFolderType.all =>
                          context.t.profile.messages.categories.all,
                        DmailFolderType.received =>
                          context.t.profile.messages.categories.received,
                        DmailFolderType.unread =>
                          context.t.profile.messages.categories.unread,
                        DmailFolderType.sent =>
                          context.t.profile.messages.categories.sent,
                        DmailFolderType.deleted =>
                          context.t.profile.messages.categories.deleted,
                      }),
                    ),
                  )
                  .toList(),
            ),
          ),
          ref
              .watch(dmailProvider)
              .when(
                data: (dmails) => dmails.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: dmails.length,
                          itemBuilder: (context, index) {
                            final dmail = dmails[index];

                            return ListTile(
                              minVerticalPadding: 0,
                              visualDensity: VisualDensity.compact,
                              trailing: DateTooltip(
                                date: dmail.createdAt,
                                child: Text(
                                  dmail.createdAt.fuzzify(
                                    locale: Localizations.localeOf(context),
                                  ),
                                ),
                              ),
                              title: Builder(
                                builder: (context) {
                                  final fromUser = ref.watch(
                                    danbooruCreatorProvider(dmail.fromId),
                                  );

                                  final color = userColor.fromLevel(
                                    fromUser?.level,
                                  );

                                  return Text(
                                    fromUser?.name ?? '...',
                                    style: dmail.isRead
                                        ? TextStyle(
                                            color: color.withValues(alpha: 0.7),
                                          )
                                        : TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w900,
                                          ),
                                  );
                                },
                              ),
                              subtitle: Text(
                                dmail.title,
                                overflow: TextOverflow.ellipsis,
                                style: dmail.isRead
                                    ? null
                                    : const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                              ),
                              onTap: () {
                                if (!dmail.isRead) {
                                  client
                                      .markDmailAsRead(id: dmail.id)
                                      .then(
                                        (value) =>
                                            ref.invalidate(dmailProvider),
                                      );
                                }

                                //FIXME: use router instead
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    settings: const RouteSettings(
                                      name: 'dmail_details',
                                    ),
                                    builder: (context) =>
                                        DanbooruDmailDetailsPage(
                                          dmail: dmail,
                                          onDmailUnread: (context, dmail) {
                                            client
                                                .markDmailAsUnread(id: dmail.id)
                                                .then(
                                                  (value) => ref.invalidate(
                                                    dmailProvider,
                                                  ),
                                                );
                                          },
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      )
                    : GenericNoDataBox(text: context.t.profile.messages.empty),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(error.toString()),
                ),
              ),
        ],
      ),
    );
  }
}
