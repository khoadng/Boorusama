// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';

class ProtectionOverlay extends StatefulWidget {
  const ProtectionOverlay({
    required this.url,
    required this.browser,
    required this.onCancel,
    required this.onSolved,
    this.browserReady,
    super.key,
  });
  final String url;
  final Widget browser;
  final VoidCallback onCancel;
  final VoidCallback onSolved;
  final ValueListenable<bool>? browserReady;

  @override
  State<ProtectionOverlay> createState() => _ProtectionOverlayState();
}

class _ProtectionOverlayState extends State<ProtectionOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.8),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.browser,
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.browserReady case final browserReady?)
                  ValueListenableBuilder<bool>(
                    valueListenable: browserReady,
                    builder: (_, ready, _) => _buildButtons(ready),
                  )
                else
                  _buildButtons(true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.security, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.t.captcha.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onCancel,
        ),
      ],
    );
  }

  Widget _buildButtons(bool browserReady) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: widget.onCancel,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            foregroundColor: Colors.white,
          ),
          child: Text(context.t.generic.action.cancel),
        ),
        FilledButton(
          onPressed: browserReady ? widget.onSolved : null,
          child: Text(context.t.captcha.i_have_solved_it),
        ),
      ],
    );
  }
}
