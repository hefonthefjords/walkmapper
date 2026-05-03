import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:walkmapper/classes/boxes.dart';
import 'package:walkmapper/classes/latlng_adapter.dart';
import 'package:walkmapper/classes/takephotos.dart';
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
  //double? _currentHeading;
  bool _isLoading = true;
  Walk? _currentWalk; // Active walk instance
  bool _isTracking = false;
  Set<Polyline> _polylines = {}; // Stores active walk path
  String addy = "";

  @override
  void initState() {
    super.initState();
    _requestPermission().then((_) async =>   
    _trackUserLocation() );
    //);
  }

  // Request location permission
  Future<void> _requestPermission() async {
    final foregroundPermission =
        await perm.Permission.locationAlways.request();
    if (!foregroundPermission.isGranted) {
      return;
    }
  }

  // Continuously track user's location & record waypoints if tracking is enabled
  void _trackUserLocation() {
    _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 0, // Update every second
      distanceFilter: 1,
      pausesLocationUpdatesAutomatically: false, // Update on every movement
    );
    _location.onLocationChanged.listen((LocationData locationData) async {
      setState(() {
        // record current position as a LatLng object
        _currentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        // record current heading
        //_currentHeading = locationData.heading;
        _isLoading = false;
      });

      addy = await getAddressFromLatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // **Save waypoints only when tracking is active**
      if (_isTracking && _currentWalk != null) {
        _currentWalk!.addWaypoint(_currentPosition!);
        // add saving to the box here to prevent lost tracks on app crashes
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
        return "${place.street}, ${place.postalCode}";
      }
      return "";

    } catch (e) {
      // need to do this in a more graceful way
      //print("Error: $e");
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
    // if (_currentWalk!.waypoints.isEmpty || _mapController == null) {
    //   _mapController!.animateCamera(
    //     CameraUpdate.newCameraPosition(
    //       CameraPosition(
    //         target: LatLng(
    //           _currentPosition!.latitude,
    //           _currentPosition!.longitude,
    //         ),
    //         bearing: _currentHeading ?? 270.0,
    //         // manual zoom level not needed
    //         //zoom: 18.0,
    //       ),
    //     ),
    //   );
    // }

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

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // Toggle tracking & manage walk sessions
  void _toggleTracking() {

    setState(() {
      // if not currently tracking
      if (!_isTracking) {
        // create a new walk object
        _currentWalk = Walk();
        // assign the walk title as the datetime string by default
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

          // store completed walk in hive
          boxWalk.put("key_${_currentWalk!.walkTitle}", _currentWalk);

          // wipe out polyline
          _polylines = {};
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
                minimum: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height * 0.5,
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

                            ElevatedButton.icon(
                              icon: Icon(Icons.camera_alt),
                              label: const Text(
                                "Take A Photo",
                                style: TextStyle(fontSize: 20),
                              ),
                              onPressed: () async {
                                await takePhoto(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                        
                    ElevatedButton.icon(
                      onPressed: () {
                        _toggleTracking(); 
                      },
                      label: Text(
                        _isTracking
                            ? "End Recording Route"
                            : "Begin Recording Route",
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

  @override
  void dispose() async {
    _mapController?.dispose();
    super.dispose();
  }
}
