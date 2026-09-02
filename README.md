# FitDesk

Uzaktan/masa başı çalışanlar için mola hatırlatıcılı egzersiz uygulaması. Kullanıcı kendi mola süresini ve günlük egzersiz hedefini belirler; her mola sonunda bir önceki egzersizin hedeflediği bölgeye göre sağlık açısından uygun, tamamlayıcı bir sonraki egzersiz önerilir (aynı bölge art arda tekrar etmez).

Detaylı mimari ve tasarım kararları için: `docs/plan.md`
Nerede kalındığını / ilerleme durumunu görmek için: `docs/PROGRESS.md`

## Yapı

```
fitdesk/
  mobile/     # Flutter uygulaması (iOS + Android)
  backend/    # Next.js API (Vercel'e deploy edilir)
  docs/       # ERD, API sözleşmesi, egzersiz içerik listesi
```

## Geliştirme

**Mobile (Android, USB ile):**
```
cd mobile
flutter devices   # cihazın yetkili göründüğünü doğrula
flutter run
```

**Backend:**
```
cd backend
npm run dev
```
