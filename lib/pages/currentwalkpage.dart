import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:walkmapper/classes/boxes.dart';
import 'package:walkmapper/classes/latlng_adapter.dart';
import 'package:walkmapper/classes/walk.dart'; // Import Walk class

// import hive.dart for storage - maybe not needed????
//import 'package:hive/hive.dart';

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
  Walk? _currentWalk; // Active walk instance
  bool _isTracking = false;
  Set<Polyline> _polylines = {}; // Stores active walk path
  List<Walk> _completedWalks = []; // List to store completed walks
  String addy = "";

  @override
  void initState() {
    super.initState();
    _requestPermission().then((_) => _trackUserLocation());
  }

  // Request location permission
  Future<void> _requestPermission() async {
    final foregroundPermission =
        await perm.Permission.locationWhenInUse.request();
    if (!foregroundPermission.isGranted) {
      return;
    }
  }

  // Continuously track user's location & record waypoints if tracking is enabled
  void _trackUserLocation() {
    _location.onLocationChanged.listen((LocationData locationData) async {
      setState(() {
        _currentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        _isLoading = false;
      });

      addy = await getAddressFromLatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // if (_mapController != null && _isTracking) {
      //   _mapController!.animateCamera(
      //     CameraUpdate.newCameraPosition(
      //       CameraPosition(target: _currentPosition!,
      //       //zoom: 18.0
      //       ),
      //     ),
      //   );
      // }

      // **Save waypoints only when tracking is active**
      if (_isTracking && _currentWalk != null) {
        _currentWalk!.addWaypoint(_currentPosition!);
        _updatePolyline();
      }
    });
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<loc.Placemark> placemarks = await loc.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        loc.Placemark place = placemarks.first;
        //print("${place.street}, ${place.locality}, ${place.country}");
        return "${place.street}, ${place.postalCode}";
      }
      return "";
    } catch (e) {
      print("Error: $e");
      return "";
    }
  }

  // Update polyline visualization
  void _updatePolyline() {
    setState(() {
      _polylines = {
        Polyline(
          polylineId: PolylineId('walk_route'),
          points: _currentWalk?.readWaypoints() ?? [],
          color: Colors.blue,
          width: 5,
        ),
      };
    });
    _zoomToFitPolyline();
  }

  // zoom the map to fit the polyline of the recorded waypoints by calculating a bounding box
  void _zoomToFitPolyline() {
    if (_currentWalk!.waypoints.isEmpty || _mapController == null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 18.0,
          ),
        ),
      );
    }
    double minLat = _currentWalk!.waypoints.first.latitude;
    double minLng = _currentWalk!.waypoints.first.longitude;
    double maxLat = _currentWalk!.waypoints.first.latitude;
    double maxLng = _currentWalk!.waypoints.first.longitude;

    for (LatLngAdapter point in _currentWalk!.waypoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 275));
  }

  // Toggle tracking & manage walk sessions
  void _toggleTracking() {
    setState(() {
      // if not currently tracking
      if (!_isTracking) {
        // create a new walk object
        _currentWalk = Walk();
        // assign the walk title to be the datetime string by default
        _currentWalk?.changeWalkTitle(
          _currentWalk!.walkStartTime.toIso8601String(),
        );
        // set the first waypoint as the current position manually so that waypoint[0] is always the starting location
        _currentWalk?.addWaypoint(_currentPosition!);
      } else {
        // if we are currently tracking then a walk has been recorded
        if (_currentWalk != null) {
          // set final waypoint of walk
          _currentWalk?.addWaypoint(_currentPosition!);

          // store the current walk as a completed walk in the completed walks list
          _completedWalks.add(_currentWalk!); // Save completed walk

          // store completed walk in hive
          boxWalk.put("key_${_currentWalk!.walkTitle}", _currentWalk);

          // set current walk to null
          // _currentWalk = null;

          // wipe out polyline
          _polylines = {};

          // review the completed walks that have been stored DEBUG
          // reviewCompletedWalks();
        }
      }
      _isTracking = !_isTracking;
    });
  }

  // DEBUG: print completed walks data to console
  // void reviewCompletedWalks() {
  //   for (Walk walk in _completedWalks) {
  //     print(
  //       "Walk startetd at ${walk.walkStartTime.toIso8601String()} titled \"${walk.walkTitle} has ${walk.waypoints.length} waypoints recorded.",
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Current Walk', textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentPosition == null
              ? const Center(child: Text('Location permission denied'))
              : SafeArea(
                minimum: EdgeInsets.fromLTRB(0, 0, 0, 75),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          zoomControlsEnabled: true,
                          myLocationEnabled: true,
                          scrollGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          myLocationButtonEnabled: true,
                          mapType: MapType.hybrid,
                          compassEnabled: true,
                          buildingsEnabled: false,
                          polylines: _polylines, // Show recorded path
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                        ),
                      ),
                    ),
                    _currentWalk?.totalTravelDistanceMetres == null ||
                            !_isTracking
                        ? Text("")
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Current Walk Stats",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Total Distance Walked: ${_currentWalk?.totalTravelDistanceMetres} metres",
                            ),
                            Text(
                              "# of Waypoints Recorded : ${_currentWalk?.waypoints.length}",
                            ),
                            Text("Current Address: $addy"),
                          ],
                        ),
                    ElevatedButton.icon(
                      onPressed: _toggleTracking,
                      label: Text(
                        _isTracking
                            ? "End Recording your Walk"
                            : "Begin Recording Your Walk",
                        style:
                            _isTracking
                                ? TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                )
                                : TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // @override
  // void dispose() {
  //   _mapController?.dispose();
  //   super.dispose();
  // }
}
