import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:walkmapper/classes/latlng_adapter.dart';
import 'package:walkmapper/classes/walk.dart'; // Import Walk class

// import hive.dart for storage - maybe not needed????
//import 'package:hive/hive.dart';

class WalkeReviewPage extends StatefulWidget {
  const WalkeReviewPage({super.key, required this.walk});

  final Walk walk;

  @override
  State<WalkeReviewPage> createState() => _GoogleMapsFlutterState();
}

class _GoogleMapsFlutterState extends State<WalkeReviewPage> {
  
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {}; // Stores active walk path
  String address = "";

  @override
  void initState() {
    super.initState();
  }


  // might not need this


  // Future<String> getAddressFromLatLng(double latitude, double longitude) async {
  //   try {
  //     List<loc.Placemark> placemarks = await loc.placemarkFromCoordinates(
  //       latitude,
  //       longitude,
  //     );

  //     if (placemarks.isNotEmpty) {
  //       loc.Placemark place = placemarks.first;
  //       //print("${place.street}, ${place.locality}, ${place.country}");
  //       return "${place.street}, ${place.postalCode}";
  //     }
  //     return "";
  //   } catch (e) {
  //     print("Error: $e");
  //     return "";
  //   }
  // }

  //Update polyline visualization
  void _updatePolyline() {
    setState(() {
      _polylines = {
        Polyline(
          polylineId: PolylineId('walk_route'),
          points: widget.walk.readWaypoints(),
          color: Colors.blue,
          width: 5,
        ),
      };
    });
    _zoomToFitPolyline();
  }

  // zoom the map to fit the polyline of the recorded waypoints by calculating a bounding box
  void _zoomToFitPolyline() {

    // THIS SHOULDN'T BE NEEDED TO REVIEW THE WALK
    // if (widget.walk.waypoints.isEmpty || _mapController == null) {
    //   _mapController!.animateCamera(
    //     CameraUpdate.newCameraPosition(
    //       CameraPosition(
    //         target: LatLng(
    //           _currentPosition!.latitude,
    //           _currentPosition!.longitude,
    //         ),
    //         zoom: 18.0,
    //       ),
    //     ),
    //   );
    // }
    
    double minLat = widget.walk.waypoints.first.latitude;
    double minLng = widget.walk.waypoints.first.longitude;
    double maxLat = widget.walk.waypoints.first.latitude;
    double maxLng = widget.walk.waypoints.first.longitude;

    for (LatLngAdapter point in widget.walk.waypoints) {
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
  // void _toggleTracking() {
  //   setState(() {
  //     // if not currently tracking
  //     if (!_isTracking) {
  //       // create a new walk object
  //       widget.walk= Walk();
  //       // assign the walk title to be the datetime string by default
  //       widget.walk.changeWalkTitle(
  //         widget.walk.walkStartTime.toIso8601String(),
  //       );
  //       // set the first waypoint as the current position manually so that waypoint[0] is always the starting location
  //       widget.walk.addWaypoint(_currentPosition!);
  //     } else {
  //       // if we are currently tracking then a walk has been recorded
  //       if (widget.walk!= null) {
  //         // set final waypoint of walk
  //         widget.walk.addWaypoint(_currentPosition!);

  //         // store the current walk as a completed walk in the completed walks list
  //         _completedWalks.add(widget.walk); // Save completed walk

  //         // store completed walk in hive
  //         boxWalk.put("key_${widget.walk.walkTitle}", widget.walk;

  //         // set current walk to null
  //         // widget.walk= null;

  //         // wipe out polyline
  //         _polylines = {};

  //         // review the completed walks that have been stored DEBUG
  //         // reviewCompletedWalks();
  //       }
  //     }
  //     _isTracking = !_isTracking;
  //   });
  //}

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
        title: Text("Walk: ${widget.walk.walkStartTime.toLocal()}", 
                          textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body:
          
               SafeArea(
                minimum: EdgeInsets.fromLTRB(0, 0, 0, 75),
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
                            target: widget.walk.waypoints[0].toLatLng(),
                            zoom: 18.0,
                          ),
                          zoomControlsEnabled: true,
                          myLocationEnabled: false,
                          scrollGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          myLocationButtonEnabled: false,
                          mapType: MapType.hybrid,
                          compassEnabled: true,
                          buildingsEnabled: false,
                          polylines: _polylines, // Show recorded path
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                            _updatePolyline();
                          },
                        ),
                      ),
                    ),
                  ]
                ),
               ),
    );





                    // widget.walk.totalTravelDistanceMetres == null ||
                    //         !_isTracking
                    //     ? Text("")
                    //     : Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Text(
                    //           "Current Walk Stats",
                    //           style: TextStyle(fontWeight: FontWeight.bold),
                    //         ),
                    //         Text(
                    //           "Total Distance Walked: ${widget.walk.totalTravelDistanceMetres} metres",
                    //         ),
                    //         Text(
                    //           "# of Waypoints Recorded : ${widget.walk.waypoints.length}",
                    //         ),
                    //         Text("Current Address: $address"),

                            // ElevatedButton.icon(
                            //   icon: Icon(Icons.camera_alt),
                            //   label: const Text(
                            //     "Take A Photo",
                            //     style: TextStyle(fontSize: 20),
                            //   ),
                            //   onPressed: () async {
                            //     await takePhoto(ImageSource.camera);
                            //   },
                            // ),
                        //   ],
                        // ),
                        
                    // ElevatedButton.icon(
                    //   onPressed: _toggleTracking,
                    //   label: Text(
                    //     _isTracking
                    //         ? "End Recording your Walk"
                    //         : "Begin Recording Your Walk",
                    //     style:
                    //         _isTracking
                    //             ? TextStyle(
                    //               color: Colors.redAccent,
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 20,
                    //             )
                    //             : TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 20,
                    //             ),
                    //   ),
                    // ),
    //               ],
    //             ),
    //           ),
    // );
  

  // @override
  // void dispose() {
  //   _mapController?.dispose();
  //   super.dispose();
  // }
}
}