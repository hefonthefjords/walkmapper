import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:walkmapper/classes/walk.dart'; // Import Walk class

class CurrentWalkPage extends StatefulWidget {
  const CurrentWalkPage({super.key});
  @override
  State<CurrentWalkPage> createState() => _GoogleMapsFlutterState();
}

class _GoogleMapsFlutterState extends State<CurrentWalkPage> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  LatLng? _currentPosition;
  bool _isLoading = true;
  Walk _walk = Walk(); // Create Walk instance
  bool _isTracking = false;
  Set<Polyline> _polylines = {}; // Set to store waypoints as a polyline

  @override
  void initState() {
    super.initState();
    _requestPermission().then((_) => _trackUserLocation());
  }

  // Request location permission
  Future<void> _requestPermission() async {
    final foregroundPermission = await perm.Permission.locationWhenInUse.request();
    if (!foregroundPermission.isGranted) {
      return;
    }
  }

  // Continuously track user's location & record waypoints if tracking is enabled
  void _trackUserLocation() {
    _location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 18.0,
            ),
          ),
        );
      }

      // **Save waypoint if tracking is active & update polyline**
      if (_isTracking) {
        _walk.addWaypoint(_currentPosition!);
        _updatePolyline();
      }
    });
  }

  // Update polyline when waypoints change
  void _updatePolyline() {
    setState(() {
      _polylines = {
        Polyline(
          polylineId: PolylineId('walk_route'),
          points: _walk.waypoints,
          color: Colors.blue,
          width: 5,
        ),
      };
      _zoomToFitPolyline();
    });
  }

  // Toggle tracking on button press
  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (!_isTracking) {
        _updatePolyline(); // Ensure final path is displayed when stopping
      }
    });
  }

  void _zoomToFitPolyline() {
  if (_walk.waypoints.isEmpty || _mapController == null) return;

  double minLat = _walk.waypoints.first.latitude;
  double minLng = _walk.waypoints.first.longitude;
  double maxLat = _walk.waypoints.first.latitude;
  double maxLng = _walk.waypoints.first.longitude;

  for (LatLng point in _walk.waypoints) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }

  LatLngBounds bounds = LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );

  _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Current Walk', textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(child: Text('Location permission denied'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        margin: EdgeInsets.all(15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentPosition!,
                              zoom: 18.0,
                            ),
                            zoomControlsEnabled: false,
                            myLocationEnabled: true,
                            scrollGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                            mapType: MapType.hybrid,
                            compassEnabled: false,
                            buildingsEnabled: false,
                            polylines: _polylines, // Show recorded waypoints as polyline
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                          ),
                        ),
                      ),
                      const Text("Things and stuff"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: null,
                            label: const Text("nuffin yet"),
                          ),
                          ElevatedButton.icon(
                            onPressed: _toggleTracking,
                            label: Text(_isTracking ? "Stop Tracking" : "Begin Tracking"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}