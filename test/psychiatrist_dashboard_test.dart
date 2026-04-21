import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nust_campus_health_app/main.dart' as app;

void main() {
  testWidgets('Dashboard shows appointments and can accept/decline', (WidgetTester tester) async {
    await tester.pumpWidget(const app.MyApp());

    // Open drawer and tap Login, then perform login (mock creds)
    final Finder menu = find.byTooltip('Open navigation menu');
    expect(menu, findsOneWidget);
    await tester.tap(menu);
    await tester.pumpAndSettle();

    // Tap Login drawer item
    final Finder loginTile = find.widgetWithText(ListTile, 'Login');
    expect(loginTile, findsOneWidget);
    await tester.tap(loginTile);
    await tester.pumpAndSettle();

    // Enter credentials and login
    await tester.enterText(find.byType(TextFormField).at(0), 'psy');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Now open drawer and go to dashboard
    await tester.tap(menu);
    await tester.pumpAndSettle();
    final Finder dashboardTile = find.text('Psychiatrist Dashboard');
    expect(dashboardTile, findsOneWidget);
    await tester.tap(dashboardTile);
    await tester.pumpAndSettle();

    // Should find at least one appointment list tile
    final Finder listTile = find.byType(ListTile);
    expect(listTile, findsWidgets);

    // If there is a pending appointment, tap Accept and verify status updates
    final Finder acceptButton = find.widgetWithText(TextButton, 'Accept');
    if (acceptButton.evaluate().isNotEmpty) {
      await tester.tap(acceptButton.first);
      await tester.pumpAndSettle();
      // After accepting, the Accept button should disappear (status changed)
      expect(find.widgetWithText(TextButton, 'Accept'), findsNothing);
    }
  });

  testWidgets('Patient summary allows adding notes', (WidgetTester tester) async {
    await tester.pumpWidget(const app.MyApp());

    // Login first (open drawer->Login)
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'psy');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Navigate to dashboard via drawer
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Psychiatrist Dashboard'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Tap first patient tile to open summary
    final Finder firstTile = find.byType(ListTile).first;
    expect(firstTile, findsOneWidget);
    await tester.tap(firstTile);
    await tester.pumpAndSettle();

    // Enter a note and save
    final Finder noteField = find.byType(TextField);
    expect(noteField, findsOneWidget);
    await tester.enterText(noteField, 'Test note from widget test');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The new note should appear in the notes list
    expect(find.text('Test note from widget test'), findsOneWidget);
  });
}
