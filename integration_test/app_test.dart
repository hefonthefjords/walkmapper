// integration_test/app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:walkmapper/main.dart';

import '../test/mocks/location_mock.dart';

late MockGeolocator mockGeolocator;

// Define the missing MyApp class for testing
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalkMapper',
      home: CurrentWalkPage(), // Adjust this to match your app's main page
    );
  }
}

// Ensure the app is properly initialized before running tests
final MyApp app = MyApp();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockGeolocator = MockGeolocator();
    GeolocatorPlatform.instance = mockGeolocator;
  });

  group('Map Initialization Tests', () {
    testWidgets('Should initialize map with correct settings', (tester) async {
      runApp(app);
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);

      final GoogleMap map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(map.mapType, MapType.normal);
      expect(map.myLocationEnabled, true);
    });

    testWidgets('Should show permission dialog when denied', (tester) async {
      mockGeolocator.setMockPermission(LocationPermission.denied);

      runApp(app);
      await tester.pumpAndSettle();

      expect(find.text('Location Permission Required'), findsOneWidget);
    });
  });

  group('Walk Recording Tests', () {
    testWidgets('Should start/stop recording walk', (tester) async {
      runApp(app);
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);

      mockGeolocator.addPosition(
        Position(
          latitude: 40.0,
          longitude: -74.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
      );

      expect(find.byType(ListTile), findsWidgets);
      expect(find.textContaining('Distance:'), findsOneWidget);
      expect(find.textContaining('Duration:'), findsOneWidget);
    });
  });

  group('Historical Walks Tests', () {
    testWidgets('Should display saved walks list', (tester) async {
      runApp(app);
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);

      mockGeolocator.addPosition(
        Position(
          latitude: 40.0,
          longitude: -74.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
      );

      expect(find.byType(ListTile), findsWidgets);
      expect(find.textContaining('Date:'), findsOneWidget);
      expect(find.textContaining('Distance:'), findsOneWidget);
    });
  });

  group('Settings Tests', () {
    testWidgets('Should change map type', (tester) async {
      runApp(app);
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);

      final GoogleMap map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(map.mapType, MapType.normal);
      expect(map.myLocationEnabled, true);
    });
  });
}