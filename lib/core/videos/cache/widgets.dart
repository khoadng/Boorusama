// Flutter imports:
import 'package:flutter/material.dart';

import '../../../foundation/caching/types.dart';
import '../../widgets/widgets.dart';
import 'types.dart';

Future<CacheSize?> showVideoCacheLimitDialog(
  BuildContext context, {
  required CacheSize currentValue,
}) {
  return showDialog<CacheSize>(
    context: context,
    builder: (context) => VideoCacheLimitDialog(currentValue: currentValue),
  );
}

class VideoCacheLimitDialog extends StatefulWidget {
  const VideoCacheLimitDialog({
    required this.currentValue,
    super.key,
  });

  final CacheSize currentValue;

  @override
  State<VideoCacheLimitDialog> createState() => _VideoCacheLimitDialogState();
}

class _VideoCacheLimitDialogState extends State<VideoCacheLimitDialog> {
  late var _sliderGigabytes = VideoCacheLimitOptions.initialCustomGigabytes(
    widget.currentValue,
  ).toDouble();

  int get _selectedGigabytes {
    return VideoCacheLimitOptions.snapGigabytes(_sliderGigabytes.round());
  }

  CacheSize get _selectedSize {
    return VideoCacheLimitOptions.fromGigabytes(_selectedGigabytes);
  }

  @override
  Widget build(BuildContext context) {
    final selectedSize = _selectedSize;

    return BooruDialog(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              selectedSize.displayString(withSpace: true),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed:
                    VideoCacheLimitOptions.canDecrease(_selectedGigabytes)
                    ? _decrement
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Slider(
                  min: VideoCacheLimitOptions.minCustomGigabytes.toDouble(),
                  max: VideoCacheLimitOptions.maxCustomGigabytes.toDouble(),
                  value: _sliderGigabytes,
                  onChanged: _updateFromSlider,
                ),
              ),
              IconButton(
                onPressed:
                    VideoCacheLimitOptions.canIncrease(_selectedGigabytes)
                    ? _increment
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(selectedSize),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _decrement() {
    setState(() {
      _sliderGigabytes = VideoCacheLimitOptions.decrease(
        _selectedGigabytes,
      ).toDouble();
    });
  }

  void _increment() {
    setState(() {
      _sliderGigabytes = VideoCacheLimitOptions.increase(
        _selectedGigabytes,
      ).toDouble();
    });
  }

  void _updateFromSlider(double value) {
    setState(() {
      _sliderGigabytes = value;
    });
  }
}
