import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_data.dart';
import '../models/body_part.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

/// Seçilen vücut bölgesine ait egzersizleri listeler. Bir egzersize
/// dokunmak öneri motorunu atlayıp o egzersizi doğrudan başlatır — ana
/// sayfaya dönülür ve egzersiz penceresi orada açılır.
class BodyPartExercisesScreen extends ConsumerWidget {
  const BodyPartExercisesScreen({super.key, required this.bodyPart});

  final BodyPart bodyPart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises =
        fakeExerciseLibrary.where((e) => e.bodyPart == bodyPart).toList();

    final color = bodyPart.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(bodyPart.label),
        backgroundColor: color,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                foregroundColor: color,
                child: const Icon(Icons.fitness_center),
              ),
              title: Text(exercise.name),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${exercise.durationSeconds} saniye'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Önce ana sayfaya dön, sonra egzersizi başlat: aksi halde
                // startSpecificExercise'ın açtığı pencere de bu ekranla aynı
                // navigator'ı kullandığından pop() az sonra o pencereyi
                // kapatır (pencere anlık açılıp hemen kapanmış gibi görünür).
                Navigator.of(context).pop();
                ref.read(appStateProvider.notifier).startSpecificExercise(exercise);
              },
            ),
          );
        },
      ),
    );
  }
}
