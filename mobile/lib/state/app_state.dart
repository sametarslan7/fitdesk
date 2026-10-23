import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/fake_data.dart';
import '../domain/streak.dart';
import '../models/exercise.dart';

const _goalMetDaysKey = 'goal_met_days';

class UserSettings {
  const UserSettings({
    required this.breakDurationSeconds,
    required this.dailyGoal,
  });

  // NOT: Test/geliştirme kolaylığı için şimdilik saniye cinsinden tutuluyor
  // (15/30/45 sn seçenekleri) — gerçek üründe dakika bazlı olacak.
  // TODO: Üretime geçmeden önce dakika bazlı seçeneklere dön.
  final int breakDurationSeconds;
  final int dailyGoal;

  UserSettings copyWith({int? breakDurationSeconds, int? dailyGoal}) {
    return UserSettings(
      breakDurationSeconds: breakDurationSeconds ?? this.breakDurationSeconds,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}

class AppState {
  const AppState({
    required this.settings,
    required this.completedToday,
    required this.remainingSeconds,
    required this.isTimerRunning,
    this.goalMetDays = const {},
    this.currentExercise,
  });

  final UserSettings settings;
  final List<Exercise> completedToday;
  final int remainingSeconds;
  final bool isTimerRunning;

  /// Günlük hedefin tamamlandığı günler (`yyyy-MM-dd`), cihazda saklanır.
  final Set<String> goalMetDays;
  final Exercise? currentExercise;

  int get streak => calculateStreak(goalMetDays, DateTime.now());

  bool get isGoalMetToday => goalMetDays.contains(dayKey(DateTime.now()));

  AppState copyWith({
    UserSettings? settings,
    List<Exercise>? completedToday,
    int? remainingSeconds,
    bool? isTimerRunning,
    Set<String>? goalMetDays,
    Exercise? currentExercise,
    bool clearCurrentExercise = false,
  }) {
    return AppState(
      settings: settings ?? this.settings,
      completedToday: completedToday ?? this.completedToday,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      goalMetDays: goalMetDays ?? this.goalMetDays,
      currentExercise:
          clearCurrentExercise ? null : (currentExercise ?? this.currentExercise),
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier()
      : super(
          const AppState(
            settings: UserSettings(breakDurationSeconds: 30, dailyGoal: 8),
            completedToday: [],
            remainingSeconds: 30,
            // Uygulama açılışında mola sayacı otomatik başlamaz — kullanıcı
            // "Molayı Başlat" ile kendisi başlatır.
            isTimerRunning: false,
          ),
        ) {
    _loadGoalMetDays();
  }

  Timer? _ticker;

  Future<void> _loadGoalMetDays() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_goalMetDaysKey) ?? const [];
    if (!mounted) return;
    state = state.copyWith(goalMetDays: {...state.goalMetDays, ...saved});
  }

  /// Bugünkü tamamlanan sayısı hedefe ulaştıysa bugünü seriye ekler ve kaydeder.
  Future<void> _recordGoalIfMet() async {
    final today = dayKey(DateTime.now());
    if (state.completedToday.length < state.settings.dailyGoal ||
        state.goalMetDays.contains(today)) {
      return;
    }
    state = state.copyWith(goalMetDays: {...state.goalMetDays, today});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_goalMetDaysKey, state.goalMetDays.toList());
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _ticker?.cancel();
        state = state.copyWith(remainingSeconds: 0, isTimerRunning: false);
        _onBreakTimerComplete();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  /// Kullanıcı "Molayı Başlat" butonuna bastığında mola geri sayımını
  /// başlatır. Zaten çalışıyorsa hiçbir şey yapmaz.
  void startBreakTimer() {
    if (state.isTimerRunning) return;
    state = state.copyWith(isTimerRunning: true);
    _startTimer();
  }

  void _onBreakTimerComplete() {
    pickNextExercise();
  }

  void updateSettings({int? breakDurationSeconds, int? dailyGoal}) {
    state = state.copyWith(
      settings: state.settings.copyWith(
        breakDurationSeconds: breakDurationSeconds,
        dailyGoal: dailyGoal,
      ),
    );
    if (dailyGoal != null) _recordGoalIfMet();

    // Mola süresi değiştiyse ve şu an bekleyen bir egzersiz penceresi yoksa
    // geri sayımı yeni süreyle baştan başlat (sadece sayaç zaten çalışıyorsa).
    if (breakDurationSeconds != null && state.currentExercise == null) {
      state = state.copyWith(remainingSeconds: state.settings.breakDurationSeconds);
      if (state.isTimerRunning) {
        _startTimer();
      }
    }
  }

  /// Geri sayımı beklemeden hemen bir egzersiz öner (manuel tetikleme).
  void triggerExerciseNow() {
    _ticker?.cancel();
    state = state.copyWith(isTimerRunning: false);
    pickNextExercise();
  }

  /// Kullanıcının "Tüm Egzersizler" listesinden kendi seçtiği egzersizi
  /// hemen başlatır (öneri motorunu atlar).
  void startSpecificExercise(Exercise exercise) {
    _ticker?.cancel();
    state = state.copyWith(currentExercise: exercise, isTimerRunning: false);
  }

  /// Geçici/basitleştirilmiş seçim: "aynı bölge art arda tekrar etmesin"
  /// kuralını uygular ama tam bölge-eşleştirme + gün içi denge mantığı
  /// henüz burada değil.
  ///
  /// TODO: Bu fonksiyonu `recommendation_engine.dart` ile değiştir
  /// (bkz. docs/plan.md → "Egzersiz Öneri Motoru").
  void pickNextExercise() {
    final lastBodyPart = state.completedToday.isNotEmpty
        ? state.completedToday.last.bodyPart
        : null;

    final candidates = fakeExerciseLibrary
        .where((e) => e.bodyPart != lastBodyPart)
        .toList();

    candidates.shuffle();
    final next = candidates.isNotEmpty ? candidates.first : fakeExerciseLibrary.first;

    state = state.copyWith(currentExercise: next);
  }

  void completeCurrentExercise() {
    final exercise = state.currentExercise;
    if (exercise == null) return;
    _ticker?.cancel();
    state = state.copyWith(
      completedToday: [...state.completedToday, exercise],
      clearCurrentExercise: true,
      remainingSeconds: state.settings.breakDurationSeconds,
      // Egzersiz bitti diye mola sayacı otomatik başlamaz — kullanıcı
      // tekrar "Molayı Başlat" demeli.
      isTimerRunning: false,
    );
    _recordGoalIfMet();
  }

  void skipCurrentExercise() {
    if (state.currentExercise == null) return;
    _ticker?.cancel();
    state = state.copyWith(
      clearCurrentExercise: true,
      remainingSeconds: state.settings.breakDurationSeconds,
      isTimerRunning: false,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);
