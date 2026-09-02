# FitDesk — Mola & Egzersiz Hatırlatıcı Mobil Uygulaması

## Context

Uzaktan/masa başı çalışanlar uzun süre hareketsiz kalıyor; bu boyun, omuz, sırt, bel, bilek gibi bölgelerde gerilme ve ağrıya yol açıyor. FitDesk, kullanıcının kendi belirlediği mola aralığında bildirim gönderip kısa bir egzersiz önerecek. Projenin farklılaştığı nokta: art arda gelen öneriler rastgele değil — bir önceki egzersizin hedeflediği bölgeye göre, fizyoterapik olarak mantıklı ve tamamlayıcı (agonist/antagonist dönüşümlü, aynı bölgeyi art arda yormayan) bir sıradaki bölge/egzersiz seçilecek. Bu döküman, henüz hiçbir kod yazılmadan, uygulamanın uçtan uca nasıl kurulacağını planlıyor.

Kullanıcı ile netleştirilen kararlar:
- **Platform:** Flutter (tek kod tabanı, iOS + Android)
- **Veri modeli:** Bulut destekli — hesap/login var, ayarlar ve geçmiş sunucuda tutulup cihazlar arasında senkronize olur
- **Günlük hedef birimi:** Egzersiz sayısı (örn. "günde 8 egzersiz")

## Genel Mimari

```
[Flutter Mobil App] <--REST/JSON--> [Next.js API (Vercel Functions)] <--> [Postgres (Neon, Vercel Marketplace)]
        |                                    |
   local SQLite cache                   Auth provider (Auth0 ör.)
   (egzersiz kütüphanesi +              JWT doğrulama
    öneri kuralları + offline log kuyruğu)
        |
  flutter_local_notifications
  (mola sayacı bildirimleri, cihazda,
   internet gerektirmez)
```

Kritik tasarım kararı: **mola bildirimi ve "bir sonraki egzersiz" hesaplaması tamamen cihaz üzerinde (offline-first)** yapılır. Backend; egzersiz kütüphanesini, bölge-eşleştirme kurallarını, kullanıcı ayarlarını ve geçmişi senkronize eden "source of truth" görevi görür ama bildirim anında ağ bağlantısına bağımlı olunmaz (Doze modu / uçak modu / zayıf bağlantıda bile mola bildirimi ve öneri çalışmalı).

## Repo Yapısı (monorepo)

```
fitdesk/
  mobile/     # Flutter app
  backend/    # Next.js API routes, Vercel'e deploy edilir
  docs/       # ERD, API sözleşmesi, egzersiz içerik listesi
```

## Backend (Vercel)

- **Framework:** Next.js (App Router) API routes, Node.js runtime, Vercel Functions üzerinde.
- **Veritabanı:** Postgres — Vercel Marketplace üzerinden Neon (implementasyon aşamasında `vercel:marketplace` skill'i ile provision edilecek). ORM: Prisma veya Drizzle.
- **Auth:** Mobil-uyumlu bir sağlayıcı (öneri: Auth0 — olgun Flutter SDK'sı `auth0_flutter` ile native login/refresh token akışı; alternatif Clerk). Backend her istekte gelen JWT'yi doğrular. Kesin sağlayıcı seçimi implementasyon başında `vercel:auth` / `vercel:marketplace` skill'i ile teyit edilecek.
- **API uç noktaları (REST, `/api/v1`):**
  - `GET/PUT /me/settings` → `breakDurationMinutes`, `dailyExerciseGoal`
  - `GET /exercises` → tüm egzersiz kütüphanesi + bölge-eşleştirme kuralları, bir `version`/`updatedAt` alanıyla (mobil bunu cache-invalidation için kullanır)
  - `POST /exercise-logs` → tamamlanan egzersiz kaydı (`exerciseId`, `bodyPart`, `completedAt`) — offline'da kuyruğa alınıp online olunca toplu gönderilir
  - `GET /exercise-logs/today` → çapraz cihaz günlük ilerleme
  - `GET /exercise-logs/history` → istatistik ekranı için (MVP+)

## Veri Modeli (özet)

- `users` (auth provider ile eşleşen id, email)
- `user_settings` (userId, breakDurationMinutes, dailyExerciseGoal)
- `exercises` (id, name, bodyPart, instructions, durationSeconds, intensity)
- `body_part_affinity` (fromBodyPart, toBodyPart, weight) — öneri motorunun kural tablosu, MVP'de statik JSON olarak `/exercises` yanıtına gömülebilir, ileride admin panelden düzenlenebilir DB tablosuna taşınır
- `exercise_logs` (id, userId, exerciseId, bodyPart, completedAt, synced)

Bölge seti (MVP): Boyun, Omuz, Kol, Bilek/El, Sırt (üst), Bel (alt sırt), Göz, Bacak/Ayak bileği.

## Egzersiz Öneri Motoru (asıl kritik parça)

Saf, test edilebilir bir fonksiyon olarak tasarlanacak: `lib/domain/recommendation_engine.dart`
`chooseNext(lastExercise, todaysLogs, exerciseLibrary, affinityMap) -> Exercise`

Algoritma:
1. **Sabit kural yok tekrar:** Bir sonraki egzersiz, bir önceki ile **aynı bölgeyi** hedefleyemez (kas dinlenme prensibi).
2. **Bölge eşleştirme grafiği (`body_part_affinity`):** Her bölge için fizyoterapi mantığıyla sıralanmış "sıradaki uygun bölgeler" listesi, örn:
   - Boyun → [Omuz, Göz]
   - Omuz → [Sırt, Kol]
   - Kol → [Bilek, Omuz]
   - Bilek → [Kol, Omuz]
   - Sırt → [Bel, Omuz]
   - Bel → [Bacak, Sırt]
   - Bacak → [Bel, Boyun]
   - Göz → [Boyun, Omuz]
   Bu bir dönüş grafiği oluşturur: agonist/antagonist bölgeler dönüşümlü çalışır, art arda aynı bölge yorulmaz.
3. **Gün içi çeşitlilik:** Aday bölgeler arasından, bugün **en az** çalışılmış olan tercih edilir — böylece günlük hedef (egzersiz sayısı) tek bir bölgeye yığılmadan dengeli dağılır.
4. **Bölge içi çeşitlilik:** Seçilen bölgede birden fazla egzersiz varsa, en son gösterilmeyen (veya rastgele) biri seçilir.
5. **Günün ilk egzersizi:** Geçmiş yoksa nötr bir başlangıç bölgesinden (örn. Boyun) başlanır.
6. Seçilen egzersiz hem bildirimde gösterilir hem de lokal + (senkronize olduğunda) sunucu loguna yazılır.

Not: Uygulama içinde "tıbbi tavsiye değildir" uyarısı gösterilecek; bölge-eşleştirme kuralları genel ergonomi/germe pratiklerine dayanır, tıbbi teşhis yerine geçmez.

## Bildirim / Mola Akışı

- Kullanıcı Ayarlar'dan `breakDurationMinutes` belirler, çalışma oturumunu başlatır.
- Uygulama `flutter_local_notifications` ile o an itibariyle `breakDurationMinutes` sonrasına **yerel** bildirim planlar (sunucuya bağımlı değil).
- Süre dolunca bildirim, öneri motorunun o an için cache'lenmiş kütüphane + geçmişle hesapladığı egzersizi gösterir; bildirime dokununca Egzersiz Detay ekranı açılır.
- Kullanıcı "Tamamladım" derse: log kaydedilir (local + sync kuyruğu), günlük ilerleme güncellenir, bir sonraki mola otomatik olarak yeniden planlanır.
- Günlük ilerleme yerel gece yarısında sıfırlanır.
- **Platform notları:** Android 12+ için exact alarm izni ve pil optimizasyonu istisnası gerekebilir (bildirim gecikmesini önlemek için); iOS'ta önceden planlanmış yerel bildirimler arka plan kısıtlamalarından etkilenmez.

## Ekranlar (Flutter)

1. Onboarding / Login (auth SDK akışı)
2. Ana Sayfa: bugünkü ilerleme (ör. "5/8"), aktif mola sayacı, manuel "Şimdi Egzersiz Yap"
3. Egzersiz Detay/Oynatıcı: açıklama, süre sayacı, Tamamladım/Atla/Ertele
4. Ayarlar: mola süresi, günlük hedef, bildirim izinleri, çıkış
5. Geçmiş/İstatistik (MVP+): hangi bölgeler ne sıklıkla çalışıldı

## Kapsam Dışı (sonraki iterasyon)

- Video/GIF gösterimli egzersiz anlatımı (MVP'de metin + basit görsel)
- Kurumsal/yönetici paneli, ekip istatistikleri
- Giyilebilir cihaz entegrasyonu
- Sunucu tetiklemeli (push) motivasyon bildirimleri — MVP tamamen yerel bildirim kullanır

## Geliştirme Ortamı (Android, kablolu)

iOS geliştirme Windows'ta mümkün olmadığından (Xcode gerektirir, macOS-only), geliştirme döngüsü **Android fiziksel cihaz üzerinden USB** ile yürütülecek; iOS derlemesi ileride bir bulut Mac/CI servisi (ör. Codemagic) ile ayrıca ele alınacak.

1. Telefonda **Geliştirici Seçenekleri**'ni aç (Ayarlar → Telefon Hakkında → Yapı Numarasına 7 kez dokun)
2. **USB Hata Ayıklama**'yı aç
3. Telefonu USB ile bağla, "Bu bilgisayara güvenilsin mi?" onayını kabul et
4. `flutter devices` ile cihazın (bu ortamda doğrulandı: `RMX3195`, Android 13/API 33) görünür ve yetkili olduğunu kontrol et
5. `flutter run` ile uygulamayı doğrudan cihaza yükle; geliştirme sırasında `r` ile hot reload kullan

## Doğrulama Planı

- **Öneri motoru:** `recommendation_engine.dart` için unit testler — art arda aynı bölge çıkmadığını, gün içi dağılımın dengeli olduğunu, ilk egzersiz senaryosunu doğrulayan test senaryoları.
- **Bildirim akışı:** Fiziksel cihaz/emülatörde mola süresini kısa tutup (ör. 1 dk) bildirimin doğru egzersizle geldiğini, arka planda/uçak modunda da tetiklendiğini manuel doğrulama.
- **Backend API:** `backend/` için entegrasyon testleri (ayar okuma/yazma, log gönderme, auth olmadan 401 dönmesi) + Vercel preview deploy üzerinde uçtan uca smoke test.
- **Senkronizasyon:** Uçak modunda birkaç egzersiz tamamlayıp online olunca `exercise_logs`'un sunucuya doğru senkronize olduğunu doğrulama.
