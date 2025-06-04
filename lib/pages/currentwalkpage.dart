import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;


class CurrentWalkPage extends StatefulWidget {
  const CurrentWalkPage({super.key});
  @override
  State<CurrentWalkPage> createState() => _GoogleMapsFlutterState();
}
class _GoogleMapsFlutterState extends State<CurrentWalkPage> {
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
      _getCurrentLocation();
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
    return //SafeArea(
    //   maintainBottomViewPadding: true,
    //   child: 
        Scaffold(

          appBar: AppBar(
            title: const Text('Your Current Walk', textAlign:TextAlign.center,),
            centerTitle: true,
            ),
          body: _isLoading ? 
              const Center(child: CircularProgressIndicator()) 
            : _currentPosition == null ? 
              const Center(
                child: Text(
                    'Location permission denied'
                  )
                )
              : SingleChildScrollView(        
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height * 0.6,
                        //width: 200,
                        //height: 200,
                        margin: EdgeInsets.all(15),
                        child: 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child:
                          GoogleMap(
                          initialCameraPosition: 
                          CameraPosition(
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
                          fortyFiveDegreeImageryEnabled: false,
                          buildingsEnabled: false,
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          // floatingActionButton: FloatingActionButton(
                          // onPressed: _getCurrentLocation,
                          // child: const Icon(Icons.my_location), 
                          ),
                          )
                          
                      ),
                      Text("Things and stuff"),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: null, 
                            label: Text("nuffin yet"), 
                          ),
                          Builder(
                            builder: (context) {
                              // if (){
                                
                              // }
                              // else {
                                
                              // }
                              return ElevatedButton.icon(
                                onPressed: null, 
                                label: Text("Begin Tracking"),
                              );
                            }
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
                  )
                )
          // ),
      // ],
    );
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
