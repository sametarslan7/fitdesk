import 'package:flutter/material.dart';

/// Günlük hedefin üst üste kaç gün tamamlandığını gösteren alevli rozet.
/// Bugün hedef henüz tamamlanmadıysa alev soluk görünür (seri risk altında).
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak, required this.isActiveToday});

  final int streak;
  final bool isActiveToday;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isActiveToday
          ? 'Hedefini $streak gün üst üste tamamladın!'
          : 'Seriyi sürdürmek için bugünkü hedefini tamamla',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isActiveToday ? 0.25 : 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: isActiveToday ? 1 : 0.45,
              child: const Text('🔥', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 4),
            Text(
              '$streak gün',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
