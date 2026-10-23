import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/body_part.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/body_part_grid.dart';
import '../widgets/countdown_timer_circle.dart';
import '../widgets/exercise_dialog.dart';
import '../widgets/section_header.dart';
import '../widgets/streak_badge.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final done = state.completedToday.length;
    final goal = state.settings.dailyGoal;
    final progress = goal == 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);

    // Mola süresi dolup bir egzersiz önerildiğinde otomatik olarak pencereyi aç.
    ref.listen<Exercise?>(
      appStateProvider.select((s) => s.currentExercise),
      (previous, next) {
        if (previous == null && next != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const ExerciseDialog(),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitDesk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'Bugünkü İlerleme',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      StreakBadge(
                        streak: state.streak,
                        isActiveToday: state.isGoalMetToday,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.accentOrange),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$done / $goal egzersiz tamamlandı',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  CountdownTimerCircle(
                    remainingSeconds: state.remainingSeconds,
                    totalSeconds: state.settings.breakDurationSeconds,
                    label: state.isTimerRunning ? 'sıradaki mola' : 'başlamadı',
                  ),
                  const SizedBox(height: 16),
                  if (!state.isTimerRunning)
                    FilledButton.icon(
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Molayı Başlat'),
                      onPressed: () =>
                          ref.read(appStateProvider.notifier).startBreakTimer(),
                    )
                  else
                    TextButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Şimdi Egzersiz Yap'),
                      onPressed: () =>
                          ref.read(appStateProvider.notifier).triggerExerciseNow(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(icon: Icons.checklist_rounded, text: 'Bugün Tamamlananlar'),
            const SizedBox(height: 8),
            if (state.completedToday.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      'Henüz egzersiz yapmadın.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.completedToday.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final exercise =
                      state.completedToday[state.completedToday.length - 1 - index];
                  final color = exercise.bodyPart.accentColor;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.check_circle, color: color),
                    title: Text(exercise.name),
                    trailing: Chip(
                      label: Text(exercise.bodyPart.label),
                      backgroundColor: color.withValues(alpha: 0.15),
                      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            const SectionHeader(icon: Icons.grid_view_rounded, text: 'Tüm Egzersizler'),
            const SizedBox(height: 4),
            Text(
              'Canın sıkıldığında bir bölge seç, kendi egzersizini yap.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            const BodyPartGrid(),
          ],
        ),
      ),
    );
  }
}
