import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dnevnichok/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Проверка перехода по страницам и изменения темы', (tester) async {
          app.main();
          await tester.pumpAndSettle();

          // Verify the default theme is dark.
          expect(Theme.of(tester.element(find.text('Записи'))).brightness, equals(Brightness.dark));


          await tester.tap(find.text('Статистика'));
          await tester.pumpAndSettle();

          expect(find.text('Статистика'), findsOneWidget);


          await tester.tap(find.text('Больше'));
          await tester.pumpAndSettle();

          expect(find.text('Больше'), findsOneWidget);


          await tester.tap(find.text('Темная тема'));
          await tester.pumpAndSettle();

          expect(Theme.of(tester.element(find.text('Записи'))).brightness, equals(Brightness.light));


          await tester.tap(find.text('Календарь'));
          await tester.pumpAndSettle();

          expect(find.text('Календарь'), findsOneWidget);
        });
    testWidgets('Тестирование изменения месяца', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Проверка смены месяца на странице Записи
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(find.text('Записи'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_forward_ios));
      await tester.pumpAndSettle();

      expect(find.text('Записи'), findsOneWidget);

      // Проверка смены месяца на странице Статистики
      await tester.tap(find.text('Статистика'));
      await tester.pumpAndSettle();

      expect(find.text('Статистика'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(find.text('Статистика'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_forward_ios));
      await tester.pumpAndSettle();

      expect(find.text('Статистика'), findsOneWidget);
    });
    testWidgets('Тестирование создания записи', (tester) async{
      app.main();
      await tester.pumpAndSettle();

      // Проверка перехода на страницу добавления записи
      await tester.tap(find.byIcon(CupertinoIcons.add));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);


      // Проверка ввода текста записи
      await tester.enterText(find.byKey(Key('titleField')), 'Title test');
      await tester.pumpAndSettle();

      expect(find.text('Title test'), findsOneWidget);


      await tester.enterText(find.byKey(Key('contentField')), 'Content test');
      await tester.pumpAndSettle();
      expect(find.text('Content test'), findsOneWidget);

      //Проверка выбора настроения
      await tester.tap(find.byIcon(FontAwesomeIcons.faceSmileBeam));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);

      //Проверка выбора даты
      await tester.tap(find.byKey(Key('dateEditButton')));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);


      //Проверка выбора времени
      await tester.tap(find.byKey(Key('timeEditButton')));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);


      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Записи'), findsOneWidget);
    });
  });
}