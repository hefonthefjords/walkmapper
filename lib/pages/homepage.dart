import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:walkmapper/classes/boxes.dart';
import 'package:walkmapper/classes/walk.dart';
import 'package:walkmapper/pages/currentwalkpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _GoogleMapsFlutterState();
}

class _GoogleMapsFlutterState extends State<HomePage> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  LatLng? _currentPosition;
  bool _isLoading = true;

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

  // Continuously track user's location
  void _trackUserLocation() {
    _location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition!, zoom: 18.0),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk Mapper'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentPosition == null
              ? const Center(child: Text('Location permission denied'))
              : SafeArea(
                minimum: EdgeInsets.fromLTRB(0, 50, 0, 75),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "You are here:",
                              style: TextStyle(fontSize: 28),
                            ),
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              height: MediaQuery.sizeOf(context).height * 0.3,
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
                                  onMapCreated: (
                                    GoogleMapController controller,
                                  ) {
                                    _mapController = controller;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CurrentWalkPage(),
                              ),
                            );
                          },
                          label: const Text(
                            "Begin A New Walk",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: ListView.builder(
                              itemCount: boxWalk.length,
                              itemBuilder: (context, index) {
                                Walk walk = boxWalk.getAt(index);
                                return ListTile(tileColor: Colors.blue[100],
                                  iconColor: Colors.red[700],
                                  dense: true,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  leading: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        boxWalk.deleteAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_forever, size: 32),
                                  ),

                                  //title: Text(walk.walkTitle),
                                  //subtitle: const Text("Title"),
                                  trailing: Text(
                                    "Date: ${walk.walkStartTime.toLocal()}",
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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
