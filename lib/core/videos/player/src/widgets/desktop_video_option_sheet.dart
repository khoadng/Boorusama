// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/providers.dart';
import '../../../../posts/post/types.dart';
import '../types/utils.dart';
import 'desktop_video_option_tile.dart';

class DesktopVideoOptionSheet extends ConsumerStatefulWidget {
  const DesktopVideoOptionSheet({
    required this.speed,
    required this.onSpeedChanged,
    required this.onLock,
    required this.onOpenSettings,
    required this.post,
    super.key,
  });

  final double speed;
  final void Function(double speed) onSpeedChanged;
  final void Function() onLock;
  final void Function() onOpenSettings;
  final Post post;

  @override
  ConsumerState<DesktopVideoOptionSheet> createState() =>
      _DesktopVideoOptionSheetState();
}

class _DesktopVideoOptionSheetState
    extends ConsumerState<DesktopVideoOptionSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _exitPageAnimation;
  late final Animation<Offset> _enterPageAnimation;
  Widget? _currentPage;
  Widget? _previousPage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _exitPageAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _enterPageAnimation =
        Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _pushPage(Widget page) {
    setState(() {
      _previousPage = _currentPage ?? _buildMainMenu();
      _currentPage = page;
    });
    _animationController.forward(from: 0);
  }

  void _popPage() {
    setState(() {
      _previousPage = _currentPage;
      _currentPage = null;
    });
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _previousPage = null;
        });
      }
    });
  }

  Widget _buildMainMenu() {
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (booruBuilder?.videoQualitySelectionBuilder case final builder?)
          ?builder(
            context,
            widget.post,
            onPushPage: _pushPage,
            onPopPage: _popPage,
          ),
        DesktopVideoOptionTile(
          icon: Symbols.speed,
          title: context.t.video_player.playback_speed,
          value: buildSpeedText(widget.speed, context),
          onTap: () => _pushPage(
            _DesktopPlaybackSpeedSelector(
              currentSpeed: widget.speed,
              onBack: _popPage,
              onSpeedChanged: (speed) {
                widget.onSpeedChanged(speed);
                _popPage();
              },
            ),
          ),
        ),
        DesktopVideoOptionTile(
          icon: Symbols.lock,
          title: context.t.video_player.lock_screen,
          onTap: widget.onLock,
        ),
        const SizedBox(height: 4),
        const Divider(height: 1),
        const SizedBox(height: 4),
        DesktopVideoOptionTile(
          icon: Symbols.settings,
          title: context.t.generic.action.more,
          onTap: widget.onOpenSettings,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final isAnimating = _animationController.isAnimating;
        final isReversing =
            _animationController.status == AnimationStatus.reverse;

        final enterAnimation = isReversing
            ? _exitPageAnimation
            : _enterPageAnimation;
        final exitAnimation = isReversing
            ? _enterPageAnimation
            : _exitPageAnimation;

        final content = Stack(
          children: [
            if (_currentPage == null)
              if (isAnimating)
                SlideTransition(
                  position: enterAnimation,
                  child: _buildMainMenu(),
                )
              else
                _buildMainMenu()
            else
              SlideTransition(
                position: enterAnimation,
                child: _currentPage,
              ),
            if (isAnimating && _previousPage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: SlideTransition(
                    position: exitAnimation,
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 1, end: 0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: IgnorePointer(
                        child: _previousPage,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: ClipRect(
            child: content,
          ),
        );
      },
    );
  }
}

class _DesktopPlaybackSpeedSelector extends StatelessWidget {
  const _DesktopPlaybackSpeedSelector({
    required this.currentSpeed,
    required this.onBack,
    required this.onSpeedChanged,
  });

  final double currentSpeed;
  final void Function() onBack;
  final void Function(double speed) onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopVideoOptionTile(
          icon: Symbols.arrow_back,
          title: context.t.video_player.playback_speed,
          onTap: onBack,
        ),
        const Divider(height: 1),
        ...kSpeedOptions.map(
          (speed) => DesktopVideoSelectionTile(
            speed: speed,
            isSelected: speed == currentSpeed,
            onTap: () => onSpeedChanged(speed),
          ),
        ),
      ],
    );
  }
}

class DesktopVideoSelectionTile extends StatefulWidget {
  const DesktopVideoSelectionTile({
    required this.speed,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final double speed;
  final bool isSelected;
  final void Function() onTap;
  final String? subtitle;

  @override
  State<DesktopVideoSelectionTile> createState() =>
      _DesktopVideoSelectionTileState();
}

class _DesktopVideoSelectionTileState extends State<DesktopVideoSelectionTile> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered
            ? colorScheme.onSurface.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: widget.isSelected
                      ? Icon(
                          Symbols.check,
                          size: 20,
                          color: colorScheme.onSurface,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buildSpeedText(widget.speed, context),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
