import 'package:flutter/material.dart';

import '../data/fake_data.dart';
import '../models/body_part.dart';
import '../screens/body_part_exercises_screen.dart';

/// Ana sayfada, canı sıkılan kullanıcının kendi seçtiği bir bölgeye
/// gidebilmesi için vücut bölgelerini kartlar halinde listeler. Bir karta
/// dokunmak, o bölgenin egzersizlerinin listelendiği ekrana götürür.
class BodyPartGrid extends StatelessWidget {
  const BodyPartGrid({super.key});

  static const Map<BodyPart, IconData> _icons = {
    BodyPart.boyun: Icons.face_retouching_natural_outlined,
    BodyPart.omuz: Icons.accessibility_new_outlined,
    BodyPart.kol: Icons.fitness_center_outlined,
    BodyPart.bilek: Icons.back_hand_outlined,
    BodyPart.sirtUst: Icons.airline_seat_flat_outlined,
    BodyPart.bel: Icons.self_improvement_outlined,
    BodyPart.goz: Icons.visibility_outlined,
    BodyPart.bacak: Icons.directions_walk_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final bodyParts = BodyPart.values
        .where((bp) => fakeExerciseLibrary.any((e) => e.bodyPart == bp))
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bodyParts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        final bodyPart = bodyParts[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BodyPartExercisesScreen(bodyPart: bodyPart),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(_icons[bodyPart], color: Colors.teal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bodyPart.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
