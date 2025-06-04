// data structure class that describes an instance of a recorded walk

import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Walk {

  String walkTitle = "";
  List<LatLng> waypoints = [];
  double totalTravelDistanceMetres = 0.0;
  double totalTravelDistanceMiles = 0.0;
  double maxDistanceFromStartMetres = 0.0;
  double maxDistanceFromStartMiles = 0.0;
  double totalElevationChangeMetres = 0.0;
  List<File> walkPhotos = [];

  void changeWalkTitle (String title){
    walkTitle = title;
  }

  void addWaypoint (LatLng waypoint){

    // add the new waypoint to the list
    waypoints.add(waypoint);

    // if there's more than one waypoint in the list
    if (waypoints.length > 1){
      // recalculate distances and elevation here
      for (int i = 0; i < waypoints.length - 1; i++){
        // insert calcs here
      }
    }

  }

  List<LatLng> readWaypoints() {
    return waypoints;
  }

  double readTravelDistanceMetres(){
    return totalTravelDistanceMetres;
  }

  double readTravelDistanceMiles(){
    return totalTravelDistanceMiles;
  }

  double readMaxDistanceFromStartMetres(){
    return maxDistanceFromStartMetres;
  }

  double readMaxDistanceFromStartMiles(){
    return maxDistanceFromStartMiles;
  }

  List<File> readWalkPhotos(){
    return walkPhotos;
  }
}

