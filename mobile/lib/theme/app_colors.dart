import 'package:flutter/material.dart';

import '../models/body_part.dart';

/// Vücut bölgesi kartlarını/etiketlerini birbirinden ayırmak için kullanılan
/// canlı renk paleti. Tema seed rengiyle karışmasın diye sabit tutulur —
/// amaç her bölgeyi göz açıp kapayana kadar tanınabilir kılmak.
extension BodyPartColor on BodyPart {
  Color get accentColor {
    switch (this) {
      case BodyPart.boyun:
        return const Color(0xFFFF6B6B); // mercan kırmızısı
      case BodyPart.omuz:
        return const Color(0xFFFF9F43); // turuncu
      case BodyPart.kol:
        return const Color(0xFFF0B429); // altın sarısı
      case BodyPart.bilek:
        return const Color(0xFF51CF66); // yeşil
      case BodyPart.sirtUst:
        return const Color(0xFF20C997); // deniz yeşili
      case BodyPart.bel:
        return const Color(0xFF339AF0); // mavi
      case BodyPart.goz:
        return const Color(0xFF845EF7); // mor
      case BodyPart.bacak:
        return const Color(0xFFF06FA5); // pembe
    }
  }
}
