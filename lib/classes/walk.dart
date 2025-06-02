// data structure class that describes an instance of a recorded walk

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Walk {

  String walkTitle = "";
  List<LatLng> waypoints = [];
  double travelDistance = 0.0;
  double maxDistance = 0.0;
  double elevationChange = 0.0;
  var walkPhotos = [];

  void changeWalkTitle (String title){
  walkTitle = title;
  }

  void addWaypoint (LatLng waypoint){
    waypoints.add(waypoint);
  }

  List<LatLng> readWaypoints() {
    return waypoints;
  }
}

