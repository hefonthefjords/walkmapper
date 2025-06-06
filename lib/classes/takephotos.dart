import 'dart:io';
import 'package:exif/exif.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

// class to handle capture and saving of photos
class TakePhotos {
  File? galleryFile;
  final picker = ImagePicker();

  Future takePhoto(ImageSource img) async {
    // pick image from gallary
    final pickedFile = await picker.pickImage(
      source: img,
      requestFullMetadata: true,
      preferredCameraDevice: CameraDevice.rear,
    );
    // store it in a valid variable
    XFile? xfilePick = pickedFile;
    if (xfilePick != null) {
      // store that in global variable galleryFile in the form of File
      galleryFile = File(pickedFile!.path);
      //imageLocation = await extractLocationMetadata(galleryFile!);
      //print("from getimg $location");

      // save the image to the gallery
      await savePhotoToGallery(pickedFile);
    } 
  }

  // save an image to the device gallery
  Future savePhotoToGallery(XFile image) async {
    //await FlutterImageGallerySaver.saveFile(image.path);
    await GallerySaver.saveImage(image.path, toDcim: true);
  }







}
