/// Günlük hedefin üst üste kaç gün tamamlandığını hesaplar.
///
/// Gün anahtarları `yyyy-MM-dd` formatındadır (bkz. [dayKey]).
/// Bugün hedef henüz tamamlanmadıysa seri bozulmuş sayılmaz — dünden geriye
/// doğru sayılır; gün bitene kadar kullanıcının seriyi sürdürme şansı var.
int calculateStreak(Set<String> goalMetDays, DateTime today) {
  var day = DateTime(today.year, today.month, today.day);
  if (!goalMetDays.contains(dayKey(day))) {
    day = day.subtract(const Duration(days: 1));
  }

  var streak = 0;
  while (goalMetDays.contains(dayKey(day))) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}

String dayKey(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}
