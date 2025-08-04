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

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

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
                          ),
                          zoomControlsEnabled: false,
                          myLocationEnabled: false,
                          scrollGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          myLocationButtonEnabled: false,
                          mapType: MapType.hybrid,
                          compassEnabled: false,
                          buildingsEnabled: false,
                          fortyFiveDegreeImageryEnabled: false,
                          indoorViewEnabled: false,
                          tiltGesturesEnabled: false,
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
  }
}