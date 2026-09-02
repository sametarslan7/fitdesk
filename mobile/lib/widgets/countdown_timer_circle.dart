import 'package:flutter/material.dart';

/// Ana sayfanın ortasında gösterilen, mola süresini geri sayan yuvarlak
/// zamanlayıcı. `remainingSeconds` sıfıra ulaştığında dış katman (HomeScreen)
/// egzersiz penceresini açar.
class CountdownTimerCircle extends StatelessWidget {
  const CountdownTimerCircle({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.size = 220,
    this.label = 'sıradaki mola',
    this.color,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final double size;
  final String label;

  /// Halkanın rengi. Verilmezse temanın primary rengi kullanılır — egzersiz
  /// penceresinde bölgeye özel vurgu rengi geçirilerek daha canlı gösterilir.
  final Color? color;

  String get _formatted {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;
    final ringColor = color ?? colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              color: colorScheme.surfaceContainerHighest,
            ),
          ),
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              color: ringColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatted,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
