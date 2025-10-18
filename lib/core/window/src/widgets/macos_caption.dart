// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:window_manager/window_manager.dart';

class MacosCaption extends StatefulWidget {
  const MacosCaption({
    super.key,
    this.backgroundColor,
    this.brightness,
  });

  final Color? backgroundColor;
  final Brightness? brightness;

  @override
  State<MacosCaption> createState() => _MacosCaptionState();
}

class _MacosCaptionState extends State<MacosCaption> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            (widget.brightness == Brightness.dark
                ? const Color(0xff1C1C1C)
                : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: SizedBox(
                height: double.infinity,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: widget.brightness == Brightness.light
                              ? Colors.black.withValues(alpha: 0.8956)
                              : Colors.white,
                          fontSize: 14,
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }
}
