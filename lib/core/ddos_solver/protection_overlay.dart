// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProtectionOverlay extends StatefulWidget {
  const ProtectionOverlay({
    required this.url,
    required this.controller,
    required this.onCancel,
    required this.onSolved,
    super.key,
  });
  final String url;
  final WebViewController controller;
  final VoidCallback onCancel;
  final VoidCallback onSolved;

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
                    child: WebViewWidget(controller: widget.controller),
                  ),
                ),
                const SizedBox(height: 16),
                _buildButtons(),
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
        const Expanded(
          child: Text(
            'Solving protection challenge',
            style: TextStyle(
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

  Widget _buildButtons() {
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
          onPressed: widget.onSolved,
          child: Text("I've Solved the Challenge".hc),
        ),
      ],
    );
  }
}
