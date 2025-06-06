// data structure class that describes an instance of a recorded walk

import 'dart:io';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:walkmapper/classes/latlng_adapter.dart';

// part directive for class to allow "flutter packages pub run build_runner build" to generate adapter
part 'walk.g.dart';

@HiveType(typeId: 1)
class Walk {
  @HiveField(1)
  String walkTitle = "";
  @HiveField(2)
  List<LatLngAdapter> waypoints = [];
  @HiveField(3)
  late DateTime walkStartTime = DateTime.now();
  @HiveField(4)
  late DateTime walkEndTime;
  @HiveField(5)
  double totalTravelDistanceMetres = 0.0;
  @HiveField(6)
  double totalTravelDistanceMiles = 0.0;
  @HiveField(7)
  double maxDistanceFromStartMetres = 0.0;
  @HiveField(8)
  double maxDistanceFromStartMiles = 0.0;
  @HiveField(9)
  double totalElevationChangeMetres = 0.0;
  @HiveField(10)
  List<File> walkPhotos = [];

  void changeWalkTitle(String title) {
    walkTitle = title;
  }



void addWaypoint(LatLng waypoint) {
  waypoints.add(LatLngAdapter(waypoint.latitude, waypoint.longitude)); // Convert before storing

  // record the timestamp of the most recently added waypoint as the walk end time in case no more waypoints are added
  walkEndTime = DateTime.now();

  totalTravelDistanceMetres = calculateTotalDistanceMetres();
  totalTravelDistanceMiles = totalTravelDistanceMetres / 0.000621371;
}
  // void addWaypoint(LatLng waypoint) {
  //   // add the new waypoint to the list
  //   waypoints.add(waypoint as LatLngAdapter);

  //   // update walk endtime to time of last waypoint addition
  //   walkEndTime = DateTime.now();

  //   // recalculate distances etc
  //   totalTravelDistanceMetres = calculateTotalDistanceMetres();
  //   totalTravelDistanceMiles = totalTravelDistanceMetres / 0.000621371;
  //   // need to add max distances and elevation calcs here!!
  // }

List<LatLng> readWaypoints() {
  return waypoints.map((adapter) => adapter.toLatLng()).toList(); // Convert back when retrieving
}

  double readTravelDistanceMetres() {
    return totalTravelDistanceMetres;
  }

  double readTravelDistanceMiles() {
    return totalTravelDistanceMiles;
  }

  double readMaxDistanceFromStartMetres() {
    return maxDistanceFromStartMetres;
  }

  double readMaxDistanceFromStartMiles() {
    return maxDistanceFromStartMiles;
  }

  List<File> readWalkPhotos() {
    return walkPhotos;
  }

  double calculateTotalDistanceMetres() {
    // if there is only one waypoint then no travel has happened
    if (waypoints.length < 2) return 0.0;

    // Earth's radius constant (metres)
    const double R = 6371000;
    double totalDistance = 0.0;

    for (int i = 0; i < waypoints.length - 1; i++) {
      LatLngAdapter start = waypoints[i];
      LatLngAdapter end = waypoints[i + 1];

      double dLat = (end.latitude - start.latitude) * pi / 180;
      double dLon = (end.longitude - start.longitude) * pi / 180;

      double a =
          sin(dLat / 2) * sin(dLat / 2) +
          cos(start.latitude * pi / 180) *
              cos(end.latitude * pi / 180) *
              sin(dLon / 2) *
              sin(dLon / 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));

      // Distance in meters
      totalDistance += R * c;
    }

    // return the distance rounded to one decimal place
    return double.parse(totalDistance.toStringAsFixed(1));
  }
}
