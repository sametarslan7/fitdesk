import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitdesk/main.dart';

void main() {
  testWidgets('Home screen shows title and progress', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FitDeskApp()));

    expect(find.text('FitDesk'), findsOneWidget);
    expect(find.text('Şimdi Egzersiz Yap'), findsOneWidget);
    expect(find.text('0 / 8 egzersiz tamamlandı'), findsOneWidget);
  });
}
