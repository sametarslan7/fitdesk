import 'body_part.dart';

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.instructions,
    required this.durationSeconds,
  });

  final String id;
  final String name;
  final BodyPart bodyPart;
  final String instructions;
  final int durationSeconds;
}
