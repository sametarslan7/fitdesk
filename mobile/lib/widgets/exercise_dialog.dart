import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/body_part.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import 'countdown_timer_circle.dart';

enum _Stage { intro, countdown, exercising }

/// Mola süresi dolduğunda (veya kullanıcı egzersizi elle başlattığında)
/// ekranın üzerinde açılan pencere. Üç aşamalı akış:
/// 1) Bilgi ekranı — "Başla" ile devam edilir (ya da "Atla" ile geçilir).
/// 2) 3-2-1 geri sayımı — otomatik ilerler.
/// 3) Egzersiz süresi kadar geri sayım — kullanıcı bu sırada egzersizi
///    yapar; "Tamamladım" günlük hedefi 1 artırır ve mola sayacını yeniden
///    başlatır, "Atla" sadece mola sayacını yeniden başlatır.
///
/// TODO: `instructions` şimdilik düz metin — ileride GIF/görsel eklenecek.
class ExerciseDialog extends ConsumerStatefulWidget {
  const ExerciseDialog({super.key});

  @override
  ConsumerState<ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends ConsumerState<ExerciseDialog> {
  _Stage _stage = _Stage.intro;
  int _countdownValue = 3;
  int _exerciseRemaining = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _stage = _Stage.countdown;
      _countdownValue = 3;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countdownValue <= 1) {
        _timer?.cancel();
        _startExercise();
      } else {
        setState(() => _countdownValue -= 1);
      }
    });
  }

  void _startExercise() {
    final exercise = ref.read(appStateProvider).currentExercise;
    _timer?.cancel();
    setState(() {
      _stage = _Stage.exercising;
      _exerciseRemaining = exercise?.durationSeconds ?? 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_exerciseRemaining <= 1) {
        _timer?.cancel();
        setState(() => _exerciseRemaining = 0);
      } else {
        setState(() => _exerciseRemaining -= 1);
      }
    });
  }

  void _skip() {
    ref.read(appStateProvider.notifier).skipCurrentExercise();
    Navigator.of(context).pop();
  }

  void _complete() {
    ref.read(appStateProvider.notifier).completeCurrentExercise();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = ref.watch(appStateProvider).currentExercise;

    if (exercise == null) {
      // Güvenlik ağı: pencere açıkken egzersiz her nasılsa temizlenirse kapat.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: switch (_stage) {
              _Stage.intro => _IntroStage(
                  exercise: exercise,
                  onSkip: _skip,
                  onStart: _startCountdown,
                ),
              _Stage.countdown => _CountdownStage(value: _countdownValue),
              _Stage.exercising => _ExercisingStage(
                  exercise: exercise,
                  remainingSeconds: _exerciseRemaining,
                  onSkip: _skip,
                  onComplete: _complete,
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _IntroStage extends StatelessWidget {
  const _IntroStage({
    required this.exercise,
    required this.onSkip,
    required this.onStart,
  });

  final Exercise exercise;
  final VoidCallback onSkip;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.teal),
            const SizedBox(width: 8),
            Text('Mola Zamanı!', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        Chip(label: Text(exercise.bodyPart.label)),
        const SizedBox(height: 12),
        Text(exercise.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '${exercise.durationSeconds} saniye',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Text(exercise.instructions, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Text(
          'Bu öneriler tıbbi tavsiye yerine geçmez.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade500),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSkip,
                child: const Text('Atla'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Başla'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountdownStage extends StatelessWidget {
  const _CountdownStage({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Hazır ol...', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ExercisingStage extends StatelessWidget {
  const _ExercisingStage({
    required this.exercise,
    required this.remainingSeconds,
    required this.onSkip,
    required this.onComplete,
  });

  final Exercise exercise;
  final int remainingSeconds;
  final VoidCallback onSkip;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          exercise.name,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        CountdownTimerCircle(
          remainingSeconds: remainingSeconds,
          totalSeconds: exercise.durationSeconds,
          size: 160,
          label: remainingSeconds == 0 ? 'süre doldu' : 'kalan süre',
        ),
        const SizedBox(height: 16),
        Text(
          exercise.instructions,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSkip,
                child: const Text('Atla'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              // Süre bitmeden "Tamamladım" tıklanamaz — kullanıcı egzersizi
              // gerçekten yapsın diye.
              child: FilledButton(
                onPressed: remainingSeconds == 0 ? onComplete : null,
                child: const Text('Tamamladım'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
