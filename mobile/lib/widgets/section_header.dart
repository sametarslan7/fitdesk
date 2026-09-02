import 'package:flutter/material.dart';

/// Ekranlardaki bölüm başlıklarının hepsinde aynı görünümü (küçük ikon +
/// başlık) tutarlı kullanmak için ortak widget.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: resolvedColor),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
