// data structure class that describes an instance of a recorded walk

import 'dart:io';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Walk {

  String walkTitle = "";
  List<LatLng> waypoints = [];
  late DateTime walkStartTime = DateTime.now();
  late DateTime walkEndTime;
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

    // recalculate distances etc
    totalTravelDistanceMetres = calculateTotalDistanceMetres();
    totalTravelDistanceMiles = totalTravelDistanceMetres / 0.000621371;
    // need to add max distances and elevation calcs here!!
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

  double calculateTotalDistanceMetres() {
    // if there is only one waypoint then no travel has happened
    if (waypoints.length < 2) return 0.0;

    // Earth's radius constant (metres)
    const double R = 6371000; 
    double totalDistance = 0.0;

    for (int i = 0; i < waypoints.length - 1; i++) {
      LatLng start = waypoints[i];
      LatLng end = waypoints[i + 1];

      double dLat = (end.latitude - start.latitude) * pi / 180;
      double dLon = (end.longitude - start.longitude) * pi / 180;

      double a = sin(dLat / 2) * sin(dLat / 2) +
                cos(start.latitude * pi / 180) * cos(end.latitude * pi / 180) *
                sin(dLon / 2) * sin(dLon / 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));

      // Distance in meters
      totalDistance += R * c; 
    }

    // return the distance rounded to one decimal place
    return double.parse(totalDistance.toStringAsFixed(1)); 
  }




}

