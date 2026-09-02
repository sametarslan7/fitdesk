import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/body_part.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import '../widgets/body_part_grid.dart';
import '../widgets/countdown_timer_circle.dart';
import '../widgets/exercise_dialog.dart';
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bugünkü İlerleme', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('$done / $goal egzersiz tamamlandı'),
                  ],
                ),
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
            Text('Bugün Tamamlananlar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (state.completedToday.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Henüz egzersiz yapmadın.',
                  style: TextStyle(color: Colors.grey.shade500),
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
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle, color: Colors.teal),
                    title: Text(exercise.name),
                    trailing: Chip(label: Text(exercise.bodyPart.label)),
                  );
                },
              ),
            const SizedBox(height: 24),
            Text('Tüm Egzersizler', style: Theme.of(context).textTheme.titleMedium),
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
