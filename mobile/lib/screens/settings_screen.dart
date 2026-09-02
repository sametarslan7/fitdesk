import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';

// NOT: Test/geliştirme kolaylığı için saniye bazlı — bkz. app_state.dart TODO.
const List<int> _breakOptions = [15, 30, 45];
const List<int> _goalOptions = [4, 6, 8, 10, 12];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appStateProvider).settings;
    final notifier = ref.read(appStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Mola Süresi (test için saniye)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _breakOptions.map((seconds) {
              return ChoiceChip(
                label: Text('$seconds sn'),
                selected: settings.breakDurationSeconds == seconds,
                onSelected: (_) =>
                    notifier.updateSettings(breakDurationSeconds: seconds),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Günlük Egzersiz Hedefi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _goalOptions.map((count) {
              return ChoiceChip(
                label: Text('$count egzersiz'),
                selected: settings.dailyGoal == count,
                onSelected: (_) => notifier.updateSettings(dailyGoal: count),
              );
            }).toList(),
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
    );
  }
}
