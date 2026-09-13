import 'package:material_ui/material_ui.dart';
import 'package:window_manager/window_manager.dart';

class KurumiDesktopWindowFrame extends StatelessWidget {
  const KurumiDesktopWindowFrame({
    required this.child,
    required this.isMacOS,
    required this.logo,
    required this.title,
    super.key,
    this.trailing,
    this.backgroundColor,
    this.brightness,
  });

  final Widget child;
  final bool isMacOS;
  final Widget logo;
  final Widget title;
  final Widget? trailing;
  final Color? backgroundColor;
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    return VirtualWindowFrame(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kWindowCaptionHeight),
          child: isMacOS
              ? KurumiMacosCaption(
                  backgroundColor: backgroundColor,
                  brightness: brightness,
                  trailing: trailing,
                )
              : WindowCaption(
                  backgroundColor: backgroundColor,
                  brightness: brightness,
                  title: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: logo,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: title,
                      ),
                      if (trailing != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: trailing,
                        ),
                    ],
                  ),
                ),
        ),
        body: child,
      ),
    );
  }
}

class KurumiMacosCaption extends StatefulWidget {
  const KurumiMacosCaption({
    super.key,
    this.backgroundColor,
    this.brightness,
    this.trailing,
  });

  final Color? backgroundColor;
  final Brightness? brightness;
  final Widget? trailing;

  @override
  State<KurumiMacosCaption> createState() => _KurumiMacosCaptionState();
}

class _KurumiMacosCaptionState extends State<KurumiMacosCaption>
    with WindowListener {
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
                    const Spacer(),
                    if (widget.trailing != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: widget.trailing,
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
  void onWindowMaximize() => setState(() {});

  @override
  void onWindowUnmaximize() => setState(() {});
}
