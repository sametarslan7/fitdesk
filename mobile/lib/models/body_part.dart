/// Egzersizlerin hedeflediği vücut bölgeleri.
///
/// Bölge-eşleştirme (öneri motoru) mantığı bu listeye göre kurulacak;
/// bkz. docs/plan.md → "Egzersiz Öneri Motoru".
enum BodyPart {
  boyun,
  omuz,
  kol,
  bilek,
  sirtUst,
  bel,
  goz,
  bacak,
}

extension BodyPartLabel on BodyPart {
  String get label {
    switch (this) {
      case BodyPart.boyun:
        return 'Boyun';
      case BodyPart.omuz:
        return 'Omuz';
      case BodyPart.kol:
        return 'Kol';
      case BodyPart.bilek:
        return 'Bilek / El';
      case BodyPart.sirtUst:
        return 'Sırt (Üst)';
      case BodyPart.bel:
        return 'Bel (Alt Sırt)';
      case BodyPart.goz:
        return 'Göz';
      case BodyPart.bacak:
        return 'Bacak / Ayak Bileği';
    }
  }
}
