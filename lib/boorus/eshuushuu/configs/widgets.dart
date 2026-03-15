// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/create/providers.dart';
import '../../../core/configs/create/widgets.dart';
import '../../../core/themes/theme/types.dart';
import '../../../core/widgets/info_container.dart';
import 'extra_data.dart';

final _eshuushuuLoginClientProvider = Provider.autoDispose
    .family<EShuushuuClient, String>(
      (ref, url) => EShuushuuClient.withBaseUrl(url),
    );

class CreateEshuushuuConfigPage extends ConsumerWidget {
  const CreateEshuushuuConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigScaffold(
      backgroundColor: backgroundColor,
      initialTab: initialTab,
      authTab: const EshuushuuAuthView(),
    );
  }
}

class EshuushuuAuthView extends ConsumerWidget {
  const EshuushuuAuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configId = ref.watch(editBooruConfigIdProvider);
    final configData = ref.watch(editBooruConfigProvider(configId));
    final isLoggedIn = configData.apiKey.isNotEmpty;
    final extraData = EshuushuuExtraData.fromPassHash(configData.passHash);
    final expiry = extraData.tokenExpiry;
    final isExpired = expiry != null && expiry.isBefore(DateTime.now());

    return Column(
      children: [
        if (isLoggedIn && isExpired) ...[
          const SizedBox(height: 16),
          WarningContainer(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            title: context.t.generic.warning,
            contentBuilder: (context) => Text(context.t.auth.session_expired),
          ),
          const SizedBox(height: 16),
        ] else
          const SizedBox(height: 32),
        Center(
          child: isLoggedIn
              ? _buildLoggedInStatus(context, ref, expiry)
              : FilledButton(
                  onPressed: () => _showLoginSheet(context, ref),
                  child: Text(context.t.auth.login),
                ),
        ),
      ],
    );
  }

  Widget _buildLoggedInStatus(
    BuildContext context,
    WidgetRef ref,
    DateTime? expiry,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t.auth.logged_in,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  RawChip(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    onPressed: () => _showLoginSheet(context, ref),
                    label: Text(context.t.auth.relogin),
                  ),
                  const SizedBox(width: 8),
                  RawChip(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    onPressed: () {
                      ref.editNotifier
                        ..updateApiKey('')
                        ..updatePassHash(null);
                    },
                    label: Text(context.t.auth.clear_credentials),
                  ),
                ],
              ),
            ],
          ),
          if (expiry != null) ...[
            const SizedBox(height: 8),
            Text(
              '${context.t.auth.login_expires} ${_formatDate(expiry, context.t.$meta.locale.languageTag)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: expiry.isBefore(DateTime.now())
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showLoginSheet(BuildContext context, WidgetRef ref) {
    final configId = ref.read(editBooruConfigIdProvider);
    final configData = ref.read(editBooruConfigProvider(configId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _EshuushuuLoginSheet(
          url: configData.url,
          initialLogin: configData.login,
          onLoginSuccess: (username, tokens) {
            final extraData = EshuushuuExtraData(
              userId: tokens.userId,
              tokenExpiry: tokens.refreshTokenExpiry,
            );
            ref.editNotifier
              ..updateLogin(username)
              ..updateApiKey(tokens.refreshToken)
              ..updatePassHash(extraData.toPassHash());
          },
        ),
      ),
    );
  }
}

class _EshuushuuLoginSheet extends ConsumerStatefulWidget {
  const _EshuushuuLoginSheet({
    required this.url,
    required this.initialLogin,
    required this.onLoginSuccess,
  });

  final String url;
  final String initialLogin;
  final void Function(String username, AuthTokens tokens) onLoginSuccess;

  @override
  ConsumerState<_EshuushuuLoginSheet> createState() =>
      _EshuushuuLoginSheetState();
}

class _EshuushuuLoginSheetState extends ConsumerState<_EshuushuuLoginSheet> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  var _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.initialLogin;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = context.t.auth.login_required);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(
        _eshuushuuLoginClientProvider(widget.url),
      );

      final tokens = await client.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (tokens == null) {
        setState(() {
          _errorMessage = context.t.auth.login_required;
          _loading = false;
        });
        return;
      }

      widget.onLoginSuccess(username, tokens);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_loading,
      child: AbsorbPointer(
        absorbing: _loading,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              CreateBooruLoginField(
                text: usernameController.text,
                labelText: context.t.booru.login_name_label,
                hintText: 'e.g: my_login',
                onChanged: (value) => usernameController.text = value,
              ),
              const SizedBox(height: 16),
              CreateBooruApiKeyField(
                controller: passwordController,
                labelText: context.t.booru.password_label,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.t.auth.login),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date, String locale) =>
    DateFormat.yMMMd(locale).format(date.toLocal());
