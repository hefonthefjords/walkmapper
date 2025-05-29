import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
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
    _getCurrentLocation();
  }
  
  Future<void> _getCurrentLocation() async {
    // Request permission
    final foregroundPermission = await perm.Permission.locationWhenInUse.request();
    if (!foregroundPermission.isGranted) {
      //final locationAlwaysPermission = await perm.Permission.locationAlways.request();
      //if (!locationAlwaysPermission.isGranted) {
         _getCurrentLocation();
     // }
    }

    _location.enableBackgroundMode(enable: true);
    if (await _location.hasPermission() == PermissionStatus.granted){

    // Check if location service is enabled
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      final serviceRequest = await _location.requestService();
      if (!serviceRequest) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }
      
      // Get location
      final locationData = await _location.getLocation();
      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
        _isLoading = false;
      });
      
      // Move camera to current location
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          duration: Duration(milliseconds: 300),
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentPosition!,
              zoom: 15.0,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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
          body: _isLoading ? 
              const Center(child: CircularProgressIndicator()) 
            : _currentPosition == null ? 
              const Center(
                child: Text(
                    'Location permission denied'
                  )
                )
              //: SingleChildScrollView( child:
                : SafeArea(
                  //left: false,
                  //right: false,
                  minimum: EdgeInsets.fromLTRB(0,50,0,75),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text("You are here:", style: TextStyle(fontSize: 28)),
                                Container(
                                  width: 200,
                                  height: 200,
                                  margin: EdgeInsets.all(15),
                                  child: 
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(300),
                                      child:
                                      GoogleMap(
                                      initialCameraPosition: 
                                      CameraPosition(
                                        target: _currentPosition!,
                                        zoom: 25.0,
                                      ),
                                      zoomControlsEnabled: false,
                                      myLocationEnabled: true,
                                      scrollGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
                                      zoomGesturesEnabled: false,
                                      myLocationButtonEnabled: false,
                                      mapType: MapType.hybrid,
                                      compassEnabled: false,
                                      fortyFiveDegreeImageryEnabled: false,
                                      buildingsEnabled: false,
                                      // onMapCreated: (GoogleMapController controller) {
                                      //   _mapController = controller;
                                      // },
                                      // floatingActionButton: FloatingActionButton(
                                      // onPressed: _getCurrentLocation,
                                      // child: const Icon(Icons.my_location), 
                                      ),
                                      )
                                    
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: null, 
                              label: Text("Previous Walks", style: TextStyle(fontSize: 20)),
                               
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentWalkPage()));
                              }, 
                              label: Text("Begin A Walk", style: TextStyle(fontSize: 20)), 
                            ),
                          ],
                        ),
                      // Image.asset(
                      //   'assets/images/kirby.jpg',
                      //   fit: BoxFit.cover,
                      // ),
                      // Image.asset(
                      //   'assets/images/walking_stickman.gif',
                      //   fit: BoxFit.cover,
                      // ),
                    
                    ]
                    ),
                )
                );
          // ),
      // ],
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
