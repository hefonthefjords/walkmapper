import 'dart:async';
import 'package:async/async.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class MockGeolocator extends GeolocatorPlatform {
  final _positionController = StreamController<Position>.broadcast();
  bool _isTracking = false;

  @override
  Future<LocationPermission> checkPermission() async => LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async => LocationPermission.always;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return Position(
      latitude: 37.42796133580664,
      longitude: -122.085749655962,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 1.0,
    );
  }

  @override
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    _isTracking = true;
    return _positionController.stream;
  }

  void addPosition(Position position) {
    if (_isTracking) {
      _positionController.add(position);
    }
  }

  void close() {
    _isTracking = false;
    _positionController.close();
  }
}