import 'dart:async';
import 'package:flutter/material.dart';

class TimerBar extends StatefulWidget {
  final int durationMs;
  final VoidCallback onTimeUp;
  final bool isPaused;

  const TimerBar({
    super.key,
    required this.durationMs,
    required this.onTimeUp,
    this.isPaused = false,
  });

  @override
  State<TimerBar> createState() => TimerBarState();
}

class TimerBarState extends State<TimerBar> {
  late int _remainingMs;
  late int _currentDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.durationMs;
    _remainingMs = widget.durationMs;
    _startTimer();
  }

  @override
  void didUpdateWidget(TimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused && !oldWidget.isPaused) {
      _timer?.cancel();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (widget.isPaused) return;
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingMs -= 100;
        if (_remainingMs <= 0) {
          _remainingMs = 0;
          timer.cancel();
          widget.onTimeUp();
        }
      });
    });
  }

  void reset() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _currentDuration = widget.durationMs;
      _remainingMs = widget.durationMs;
    });
    _startTimer();
  }

  void stop() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _remainingMs / _currentDuration;
    final seconds = (_remainingMs / 1000).ceil();

    // Use proportional thresholds (30% and 50% of duration)
    final amberThreshold = (_currentDuration * 0.5).round();
    final redThreshold = (_currentDuration * 0.3).round();

    Color barColor;
    if (_remainingMs <= redThreshold) {
      barColor = Colors.red;
    } else if (_remainingMs <= amberThreshold) {
      barColor = Colors.amber;
    } else {
      barColor = theme.colorScheme.primary;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${seconds}s',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
            Icon(
              Icons.timer,
              color: barColor,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
