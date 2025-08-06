// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:walkmapper/main.dart' as app;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../test/mocks/location_mock.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockGeolocator mockGeolocator;

  setUp(() {
    mockGeolocator = MockGeolocator();
    GeolocatorPlatform.instance = mockGeolocator;
  });

  group('Map and Location Tests', () {
    testWidgets('Should initialize map with correct initial settings', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);
      
      final GoogleMap map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(map.mapType, MapType.normal);
      expect(map.myLocationEnabled, true);
    });

    testWidgets('Should show location permission dialog if not granted', (tester) async {
      mockGeolocator.setMockPermission(LocationPermission.denied);
      
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Location Permission Required'), findsOneWidget);
    });
  });

  group('Walk Recording Tests', () {
    testWidgets('Should start and stop recording walk correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.stop), findsOneWidget);
      
      // Simulate location updates
      mockGeolocator.simulatePositionUpdate(
        Position(
          latitude: 40.0,
          longitude: -74.0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0
        )
      );

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      // Verify walk was saved
      expect(find.text('Walk Saved'), findsOneWidget);
    });

    testWidgets('Should display walking statistics during recording', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsWidgets);
      expect(find.textContaining('Distance:'), findsOneWidget);
      expect(find.textContaining('Duration:'), findsOneWidget);
    });
  });

  group('Historical Walks Tests', () {
    testWidgets('Should display list of saved walks', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Should show walk details when selecting saved walk', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Assuming there's at least one walk
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.textContaining('Date:'), findsOneWidget);
      expect(find.textContaining('Distance:'), findsOneWidget);
    });
  });

  group('Settings Tests', () {
    testWidgets('Should allow changing map type', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Map Type'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Satellite'));
      await tester.pumpAndSettle();

      final GoogleMap map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(map.mapType, MapType.satellite);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Should show error dialog when location service is disabled', (tester) async {
      mockGeolocator.setMockServiceEnabled(false);
      
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Location Services Disabled'), findsOneWidget);
    });

    testWidgets('Should handle network errors gracefully', (tester) async {
      // Simulate network error
      mockGeolocator.simulateError(Exception('Network error'));
      
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
    });
  });
}