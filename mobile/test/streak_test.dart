import 'package:fitdesk/domain/streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 3, 2);

  test('hiç gün yoksa seri 0', () {
    expect(calculateStreak({}, today), 0);
  });

  test('bugün dahil üst üste günler sayılır (ay sınırını geçer)', () {
    expect(calculateStreak({'2026-03-02', '2026-03-01', '2026-02-28'}, today), 3);
  });

  test('bugün henüz tamamlanmadıysa seri dünden devam eder', () {
    expect(calculateStreak({'2026-03-01', '2026-02-28'}, today), 2);
  });

  test('arada boş gün varsa seri orada biter', () {
    expect(calculateStreak({'2026-03-02', '2026-02-28'}, today), 1);
  });

  test('dün de bugün de yoksa seri 0', () {
    expect(calculateStreak({'2026-02-28'}, today), 0);
  });
}
