// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walkmapper/main.dart';
import 'package:walkmapper/widgets/walk_stats.dart';
import 'package:walkmapper/widgets/map_controls.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('WalkStats widget displays correct information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WalkStats(
            distance: 1000,
            duration: const Duration(minutes: 15),
            speed: 4.0,
          ),
        ),
      );

      expect(find.text('Distance: 1.0 km'), findsOneWidget);
      expect(find.text('Duration: 15:00'), findsOneWidget);
      expect(find.text('Speed: 4.0 km/h'), findsOneWidget);
    });

    testWidgets('MapControls widget responds to interactions', (WidgetTester tester) async {
      bool zoomInCalled = false;
      bool zoomOutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MapControls(
            onZoomIn: () => zoomInCalled = true,
            onZoomOut: () => zoomOutCalled = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(zoomInCalled, true);

      await tester.tap(find.byIcon(Icons.remove));
      expect(zoomOutCalled, true);
    });

    testWidgets('Navigation drawer shows all menu items', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Current Walk'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
