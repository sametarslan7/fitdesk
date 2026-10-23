# FitDesk — İlerleme Durumu

> Bu dosya, projeye geri dönüldüğünde "nerede kalmıştık"ı hızlıca hatırlamak için tutulur.
> Mimari/tasarım kararlarının detayı için: `docs/plan.md`

## Şu Ana Kadar Yapılanlar

1. Plan onaylandı → `docs/plan.md` (mimari, veri modeli, öneri motoru algoritması, ekranlar)
2. Monorepo iskeleti oluşturuldu: `mobile/` (Flutter), `backend/` (Next.js), `docs/`
3. **Mobil uygulama** — sahte (fake) veriyle temel akış çalışıyor:
   - `HomeScreen`: günlük ilerleme (X/hedef), **ortada yuvarlak mola geri sayım timer'ı** — **otomatik başlamaz**, kullanıcı "Molayı Başlat" butonuna basmadan saymaz (ne uygulama ilk açıldığında ne de bir egzersiz tamamlanınca/atlanınca); çalışırken sıfıra inince otomatik egzersiz penceresi açar; timer çalışırken buton yerini "Şimdi Egzersiz Yap"a bırakır (beklemeden manuel tetikler). Altında "Bugün Tamamlananlar" listesi, en altta **"Tüm Egzersizler"** — vücut bölgesi kartları (Boyun, Omuz, Kol, Bilek, Sırt, Bel, Göz, Bacak); bir bölgeye dokunmak `BodyPartExercisesScreen`'e götürür, oradan bir egzersiz seçilince ana sayfaya dönüp o egzersizi doğrudan başlatır (öneri motorunu atlar)
   - `ExerciseDialog` (`lib/widgets/exercise_dialog.dart`): kapatılamaz bir **pencere (Dialog)**, 3 aşamalı — 1) bilgi ekranı ("Atla"/"Başla"), 2) otomatik 3-2-1 geri sayımı, 3) egzersizin kendi süresi kadar geri sayım (yuvarlak timer + talimat metni) → "Tamamladım" (günlük hedefi +1 artırır) / "Atla". **"Tamamladım" süre sıfıra inmeden tıklanamaz** (buton pasif), kullanıcı egzersizi gerçekten yapsın diye. İkisi de tamamlanınca ana mola sayacını sıfırlar ama **başlatmaz** — kullanıcı tekrar "Molayı Başlat" demeli.
   - `SettingsScreen`: mola süresi seçimi — **şimdilik test/geliştirme kolaylığı için saniye bazlı (15/30/45 sn)**, dakika değil (`TODO: üretime geçmeden dakikaya dön`); değiştirilince, sayaç zaten çalışıyorsa yeni süreyle sıfırdan başlar. Günlük hedef seçimi (henüz kaydetme/backend yok, sadece in-memory state)
   - State yönetimi: `flutter_riverpod` (`lib/state/app_state.dart`) — `Timer.periodic` ile gerçek geri sayım, `isTimerRunning` flag'i ile manuel start/stop, `pickNextExercise()` / `startSpecificExercise()` / `triggerExerciseNow()` / `startBreakTimer()`
   - Egzersiz kütüphanesi: `lib/data/fake_data.dart` (10 örnek egzersiz, 8 vücut bölgesi)
4. Android fiziksel cihazda (USB, `RMX3195` / Android 13) çalıştığı doğrulandı — **not:** bu makinede Windows ilk bağlantıda "ADB Interface" sürücüsünü otomatik tanımayabiliyor (Device Manager'da "Unknown" görünür); telefonda USB hata ayıklama izin penceresini onaylayınca `adb devices` görmeye başlıyor. En son özellikler (manuel start, 3 aşamalı pencere, saniye bazlı test süresi) şu ana kadar sadece **Chrome'da** doğrulandı
5. `backend/` sadece `create-next-app` ile oluşturuldu — henüz API/DB/auth kodu **yazılmadı**

## Şu An Neredeyiz

Mola timer'ı artık tamamen kullanıcı kontrolünde (otomatik başlamıyor), egzersiz penceresi 3 aşamalı (Başla → 3-2-1 → egzersiz süresi → Tamamladım), test kolaylığı için mola süresi saniye bazlı (2026-09-02). Aynı gün: renk paleti canlandırıldı — `lib/theme/app_theme.dart` doygun zümrüt yeşili seed + turuncu ikincil renk + özel component temaları (AppBar, Card, buton, chip) kullanıyor; `lib/theme/app_colors.dart` her vücut bölgesine sabit, birbirinden ayrışan bir vurgu rengi atıyor (bölge kartları, "Tamamlananlar" chip'leri, egzersiz penceresindeki geri sayım halkası ve 3-2-1 rakamı artık o bölgenin rengini kullanıyor). Ardından `lib/widgets/section_header.dart` (ortak ikon+başlık widget'ı) eklenerek ana sayfa/ayarlar bölüm başlıklarına ve egzersiz penceresindeki süre/talimat/uyarı satırlarına küçük ikonlar eklendi (2026-09-02). Kullanıcı Chrome'da test edip iki UI hatası bildirdi, ikisi de düzeltildi: (1) `AppTheme`'deki FilledButton/OutlinedButton padding'i sadece dikeydi (`vertical: 14`, yatay padding 0), bu yüzden "Molayı Başlat" gibi metinler kutuya yapışıyordu — `horizontal: 24` eklendi; (2) Ayarlar sayfasındaki `Wrap` seçenekleri (`_breakOptions`, `_goalOptions`) `runSpacing` tanımlamadığından alt satıra taştıklarında birbirine yapışık görünüyordu — `runSpacing: 10` eklendi, chip iç padding'i de büyütüldü. Kullanıcı sonucu Chrome'da onayladı ("çok daha düzgün duruyor"). 2026-10-23: ana sayfadaki ilerleme kartının sağ üstüne **🔥 seri rozeti** (`lib/widgets/streak_badge.dart`) eklendi — günlük hedefin kaç gün üst üste tamamlandığını gösterir; bugün henüz tamamlanmadıysa alev soluk görünür ve seri dünden sayılır. Hesap `lib/domain/streak.dart` içinde (unit test: `test/streak_test.dart`); hedefin tamamlandığı günler `shared_preferences` ile cihazda saklanıyor (uygulamadaki ilk kalıcı veri). Not: `completedToday` hâlâ kalıcı değil ve gece yarısı sıfırlanmıyor. Aynı gün: Ayarlar ekranı taslak+kaydet mantığına geçti — chip seçimleri sadece ekranda tutulur, değişiklik varsa aktifleşen **"Kaydet"** butonuyla uygulanır (sadece değişen alanlar `updateSettings`'e gider, böylece mola süresi değişmediyse sayaç sıfırlanmaz); kaydedilmemiş değişiklikle geri çıkınca `PopScope` onay penceresi açar. Windows masaüstü derlemesi bu makinede çalışmıyor (Visual Studio C++ araçları yok) — Chrome kullan. Sırada: kullanıcıdan yeni geri bildirim gelirse onu uygulamak, sonra gerçek telefonda da doğrulamak.

## Önemli Not — Şu Anki Öneri Mantığı Gerçek Değil

`lib/state/app_state.dart` içindeki `pickNextExercise()` sadece **"aynı bölge art arda gelmesin"** kuralını uyguluyor, rastgele seçiyor. Plandaki asıl öneri motoru (bölge-eşleştirme grafiği + gün içi denge + bölge içi çeşitlilik) **henüz yazılmadı**. Kodda `// TODO: recommendation_engine.dart ile değiştir` notu var.

## Sırada Ne Var (plan.md'deki adımlar)

- [ ] Kullanıcının UI/UX geri bildirimlerini uygulamak
- [ ] Gerçek öneri motoru: `lib/domain/recommendation_engine.dart` (bölge-eşleştirme grafiği, unit testli)
- [ ] Backend: auth provider seçimi + kurulumu, Postgres (Neon/Vercel Marketplace), `/me/settings`, `/exercises`, `/exercise-logs` uçları
- [ ] Mobilde `flutter_local_notifications` ile gerçek mola sayacı/bildirimi
- [ ] Offline-first senkronizasyon (local SQLite cache + backend'e log gönderme kuyruğu)
- [ ] Geçmiş/istatistik ekranı, gerçek egzersiz görselleri/videoları

## Geliştirme Ortamı — Hızlı Hatırlatma

- Cihaz: Android telefon USB ile bağlı, `flutter devices` ile `RMX3195`'in **yetkili** göründüğünü doğrula (yetkisizse telefon ekranındaki onay penceresini kabul et)
- Çalıştırmak: `cd mobile && flutter run`
- Uygulamayı durdurmak (adb ile, flutter run oturumu koptuysa): Android SDK'nın `platform-tools/adb.exe` yolunu bulup `adb shell am force-stop com.fitdesk.fitdesk`
- Package name: `com.fitdesk.fitdesk`
- iOS derlemesi Windows'ta yapılamaz (Xcode/macOS gerekir) — ileride Codemagic gibi bulut CI değerlendirilecek

## Dosya Haritası (mobile/lib)

```
lib/
  main.dart
  theme/
    app_theme.dart   # ThemeData: canlı seed renk + AppBar/Card/buton/chip temaları
    app_colors.dart  # BodyPart -> vurgu rengi eşlemesi (BodyPartColor extension)
  models/
    body_part.dart       # BodyPart enum + Türkçe etiketler
    exercise.dart
  data/fake_data.dart     # örnek egzersiz kütüphanesi
  domain/streak.dart      # calculateStreak(): üst üste hedef tamamlanan günler
  state/app_state.dart    # Riverpod StateNotifier: settings, timer (Timer.periodic), günlük log, pickNextExercise()
  screens/
    home_screen.dart              # timer + Tamamlananlar + Tüm Egzersizler (bölge kartları)
    settings_screen.dart
    body_part_exercises_screen.dart  # seçilen bölgenin egzersiz listesi
  widgets/
    countdown_timer_circle.dart  # ortadaki yuvarlak geri sayım
    exercise_dialog.dart         # süre bitince/manuel açılan egzersiz penceresi
    body_part_grid.dart          # ana sayfadaki vücut bölgesi kartları
    section_header.dart          # ikon+başlık bölüm başlığı (ortak widget)
    streak_badge.dart            # ilerleme kartındaki 🔥 seri rozeti
```
