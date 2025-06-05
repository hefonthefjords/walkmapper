import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'latlng_adapter.g.dart';

@HiveType(typeId: 2)
class LatLngAdapter {
  @HiveField(0)
  double latitude;

  @HiveField(1)
  double longitude;

  LatLngAdapter(this.latitude, this.longitude);

  LatLng toLatLng() => LatLng(latitude, longitude);
}