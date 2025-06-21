import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
// class to handle capture and saving of photos
class TakePhotos {
  // File? galleryFile;
  // final picker = ImagePicker();
}

Future takePhoto(ImageSource img) async {
  Location location = Location();
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  PermissionStatus permissionGranted;
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }




  // take a photo using the ImagePicker plugin
  final picker = ImagePicker();
  XFile? capture = await picker.pickImage(
    source: img,
    requestFullMetadata: true,
    preferredCameraDevice: CameraDevice.rear,
    imageQuality: 100,
  );

  // if the captured file is not null
  if (capture != null) {
    // rename the photo with timestamp
    XFile photo = XFile(capture.path, name: DateTime.now().toIso8601String());

    // save the photo to the gallery
    await saveImageToGallery(photo);
  }
}

// save an image to the device gallery
Future saveImageToGallery(XFile image) async {
  //await FlutterImageGallerySaver.saveFile(image.path);
  await GallerySaver.saveImage(image.path, toDcim: true);
}




class NativeCamera {
  static const MethodChannel _channel = MethodChannel('com.example.myapp/camera');

  static Future<String?> takePicture() async {
    final String? imagePath = await _channel.invokeMethod('takePicture');
    return imagePath;
  }
}