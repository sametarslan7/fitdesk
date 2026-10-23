import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../widgets/section_header.dart';

// NOT: Test/geliştirme kolaylığı için saniye bazlı — bkz. app_state.dart TODO.
const List<int> _breakOptions = [15, 30, 45];
const List<int> _goalOptions = [4, 6, 8, 10, 12];

/// Seçimler önce ekranda taslak olarak tutulur, "Kaydet"e basılınca
/// uygulanır. Kaydedilmemiş değişiklikle çıkarken onay istenir.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _breakSeconds;
  late int _dailyGoal;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appStateProvider).settings;
    _breakSeconds = settings.breakDurationSeconds;
    _dailyGoal = settings.dailyGoal;
  }

  bool _hasChanges(UserSettings saved) =>
      _breakSeconds != saved.breakDurationSeconds || _dailyGoal != saved.dailyGoal;

  void _save(UserSettings saved) {
    // Sadece değişen alanları gönder: mola süresi değişirse sayaç sıfırlanır,
    // değişmediyse çalışan sayaca dokunulmamalı.
    ref.read(appStateProvider.notifier).updateSettings(
          breakDurationSeconds:
              _breakSeconds != saved.breakDurationSeconds ? _breakSeconds : null,
          dailyGoal: _dailyGoal != saved.dailyGoal ? _dailyGoal : null,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ayarlar kaydedildi')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydedilmemiş değişiklikler'),
        content: const Text('Yaptığın değişiklikler kaydedilmedi. Çıkmak istiyor musun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kaydetmeden Çık'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(appStateProvider).settings;
    final hasChanges = _hasChanges(saved);

    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ayarlar')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              icon: Icons.timer_outlined,
              text: 'Mola Süresi (test için saniye)',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _breakOptions.map((seconds) {
                return ChoiceChip(
                  label: Text('$seconds sn'),
                  selected: _breakSeconds == seconds,
                  onSelected: (_) => setState(() => _breakSeconds = seconds),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const SectionHeader(icon: Icons.flag_outlined, text: 'Günlük Egzersiz Hedefi'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _goalOptions.map((count) {
                return ChoiceChip(
                  label: Text('$count egzersiz'),
                  selected: _dailyGoal == count,
                  onSelected: (_) => setState(() => _dailyGoal = count),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: const Text('Kaydet'),
                onPressed: hasChanges ? () => _save(saved) : null,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Bildirim İzinleri'),
              subtitle: const Text('Yakında (mola hatırlatıcıları için gerekli)'),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              subtitle: const Text('Hesap sistemi henüz eklenmedi'),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}
