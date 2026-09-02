import '../models/body_part.dart';
import '../models/exercise.dart';

/// UI geliştirme aşaması için örnek egzersiz kütüphanesi.
///
/// Gerçek uygulamada bu liste backend'den (`GET /exercises`) çekilip
/// yerelde önbelleğe alınacak. Bölge eşleştirme kuralı ve gerçek seçim
/// mantığı henüz burada değil — bkz. docs/plan.md, "Egzersiz Öneri Motoru".
const List<Exercise> fakeExerciseLibrary = [
  Exercise(
    id: 'neck-tilt',
    name: 'Boyun Yan Esnetme',
    bodyPart: BodyPart.boyun,
    instructions:
        'Dik otur. Başını yavaşça sağ omzuna doğru eğ, 10 saniye tut. '
        'Aynısını sol tarafa tekrarla.',
    durationSeconds: 30,
  ),
  Exercise(
    id: 'neck-rotation',
    name: 'Boyun Döndürme',
    bodyPart: BodyPart.boyun,
    instructions:
        'Başını yavaşça sağa çevir, 5 saniye bekle, sonra sola çevir. '
        '4 tekrar yap.',
    durationSeconds: 30,
  ),
  Exercise(
    id: 'shoulder-shrug',
    name: 'Omuz Silkme',
    bodyPart: BodyPart.omuz,
    instructions:
        'Omuzlarını kulaklarına doğru kaldır, 3 saniye tut, bırak. '
        '8 tekrar yap.',
    durationSeconds: 30,
  ),
  Exercise(
    id: 'shoulder-roll',
    name: 'Omuz Çevirme',
    bodyPart: BodyPart.omuz,
    instructions: 'Omuzlarını geriye doğru büyük dairesel hareketlerle çevir, 10 tekrar.',
    durationSeconds: 30,
  ),
  Exercise(
    id: 'arm-stretch',
    name: 'Kol Germe',
    bodyPart: BodyPart.kol,
    instructions:
        'Bir kolunu göğsünün önünden diğer omzuna doğru çek, diğer kolunla '
        'destekle, 15 saniye tut. Kolu değiştir.',
    durationSeconds: 40,
  ),
  Exercise(
    id: 'wrist-circles',
    name: 'Bilek Döndürme',
    bodyPart: BodyPart.bilek,
    instructions: 'Ellerini yumruk yap, bileklerini her iki yöne 10\'ar kez döndür.',
    durationSeconds: 30,
  ),
  Exercise(
    id: 'upper-back-stretch',
    name: 'Üst Sırt Germe',
    bodyPart: BodyPart.sirtUst,
    instructions:
        'Ellerini kenetle, kollarını öne uzat, sırtını yuvarlayarak 15 saniye tut.',
    durationSeconds: 30,
  ),
  Exercise(
    id: 'lower-back-extension',
    name: 'Bel Germe (Ayakta)',
    bodyPart: BodyPart.bel,
    instructions: 'Ayakta, ellerini beline koy, hafifçe geriye doğru eğil, 10 saniye tut.',
    durationSeconds: 30,
  ),
  Exercise(
    id: 'eye-2020',
    name: '20-20-20 Göz Molası',
    bodyPart: BodyPart.goz,
    instructions: '20 saniye boyunca 6 metre uzaktaki bir noktaya odaklan.',
    durationSeconds: 20,
  ),
  Exercise(
    id: 'ankle-circles',
    name: 'Ayak Bileği Döndürme',
    bodyPart: BodyPart.bacak,
    instructions: 'Oturarak bir ayağını kaldır, ayak bileğini her iki yöne 10\'ar kez döndür.',
    durationSeconds: 30,
  ),
];
