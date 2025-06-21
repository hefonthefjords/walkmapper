// //import 'package:camera/camera.dart';

// import 'package:flutter/material.dart';
// import 'package:gallery_saver_plus/gallery_saver.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:exif/exif.dart';
// import 'package:location/location.dart';
// import 'package:permission_handler/permission_handler.dart' as perm;

// class TakePhotoPage extends StatefulWidget {
//   const TakePhotoPage({ super.key });

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<TakePhotoPage> {
//   File? galleryFile;
//   final picker = ImagePicker();
//   String imageLocation = "location has never been set yet";
//   // List<CameraDescription> cameras = [];
//   // CameraController? cameraController;

// @override
//   void initState() {
//     super.initState();
//     //_setupCameraContorller();
//    requestPermission();
//   }

//   requestPermission() async {
//     Location location = Location();
//   print("requesting location permission");
//     bool _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     PermissionStatus _permissionGranted;
//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _buildUI(),
//     );
//   }

// Widget _buildUI() {
//   return SafeArea(
//       child: 
//         SizedBox.expand(child:SingleChildScrollView(        
//           padding: EdgeInsets.all(20),

//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Builder(
//                 builder: (context) { 
//                   if (galleryFile != null){
//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [ ClipRRect(
//                       borderRadius: BorderRadius.all(Radius.circular(15)),
//                       child: Image.file(
//                         galleryFile!,
//                         fit: BoxFit.cover,
//                       )
//                     ),
//                     Text(imageLocation.toString().replaceFirst(r',', '\n'),
//                       textAlign: TextAlign.center,
//                     )
//                   ]
//                   );
//                   }
//                   else {
//                     return Text("No image to display yet. :(");
//                   }
//                 },
//               ),
//               SizedBox(height: 50),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => getImage(ImageSource.camera), 
//                         child: Icon(
//                           Icons.photo_camera,
//                           color: Colors.black,
//                           size: 50,
//                         )
//                       ),
//                       Text("Take Photo"),
//                     ],
//                   ),
//                 ],
//               )
//             ],
//           ),
//         )
//         )
//     );
//   }

//   Future getImage(ImageSource img) async {
//     // pick image from gallary
//     final pickedFile = await picker.pickImage(
//       source: img, 
//       requestFullMetadata: true, 
//       preferredCameraDevice: CameraDevice.rear);
//     // store it in a valid variable
//     XFile? xfilePick = pickedFile;
//       if (xfilePick != null) {
//         // store that in global variable galleryFile in the form of File
//         galleryFile = File(pickedFile!.path);
//         imageLocation = await extractLocationMetadata(galleryFile!);
//         //print("from getimg $location");

//         // save the image to the gallery
//         await saveImageToGallery(pickedFile);
      
//       } 
//       else {
//         ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
//         const SnackBar(content: Text('Nothing is selected')));
//       }
//     setState(
//       () {
//         // just update the display ploz
//       },
//     );
//   }


// // Future saveImageToGallery(XFile image) async {

// //   //await FlutterImageGallerySaver.saveFile(image.path);
// //   await GallerySaver.saveImage(image.path, toDcim: true);
// // }



// /// Converts an IfdRatios object—or an Iterable—to a List<double>.
// List<double> _ifdRatiosToList(dynamic value) {
//   if (value is IfdRatios) {
//     // Use map<double> to ensure the result is a List<double>
//     return value.ratios.map<double>((rational) => rational.toDouble()).toList();
//   } else if (value is Iterable) {
//     return value.map<double>((rational) => rational.toDouble()).toList();
//   } else {
//     throw Exception("Expected GPS ratios to be an IfdRatios or Iterable, but got: ${value.runtimeType}");
//   }
// }


// /// Converts [degrees, minutes, seconds] to decimal degrees.
// double _convertToDegree(List<double> components) {
//   return components[0] + (components[1] / 60) + (components[2] / 3600);
// }

// // /// Reads EXIF data from [imageFile] and returns a string with the GPS metadata.
// // Future<String> extractLocationMetadata(File imageFile) async {
// //   try {
// //     final bytes = await imageFile.readAsBytes();
// //     final data = await readExifFromBytes(bytes);

// //     // Check for the required GPS tags.
// //     if (data.containsKey('GPS GPSLatitude') &&
// //         data.containsKey('GPS GPSLatitudeRef') &&
// //         data.containsKey('GPS GPSLongitude') &&
// //         data.containsKey('GPS GPSLongitudeRef')) {
      
// //       final latTag = data['GPS GPSLatitude']!;
// //       final lonTag = data['GPS GPSLongitude']!;
      
// //       // Use the helper to extract a list of doubles.
// //       List<double> latComponents = _ifdRatiosToList(latTag.values);
// //       List<double> lonComponents = _ifdRatiosToList(lonTag.values);
      
// //       double latitude = _convertToDegree(latComponents);
// //       double longitude = _convertToDegree(lonComponents);
      
// //       final latRef = data['GPS GPSLatitudeRef']!.printable.trim();
// //       final lonRef = data['GPS GPSLongitudeRef']!.printable.trim();
      
// //       // Adjust for hemisphere: south and west become negative.
// //       if (latRef == 'S') latitude = -latitude;
// //       if (lonRef == 'W') longitude = -longitude;
// //       imageLocation = 'Location: Latitude = $latitude, Longitude = $longitude';
// //       //print("image loc form extract func $imageLocation");
// //       return imageLocation;
// //     } else {
// //       imageLocation = 'No location metadata available in this image.';
// //       //print('No location metadata available in this image.');
// //       return 'No location metadata available in this image.';
// //     }
// //   } catch (e) {
// //     //print("Error reading EXIF data: $e");
// //     return 'An error occurred while extracting location metadata.';
// //   }
// // }



// }

