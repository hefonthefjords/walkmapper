import 'dart:io';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

// class to handle capture and saving of photos
class TakePhotos {
  File? galleryFile;
  final picker = ImagePicker();

  Future takePhoto(ImageSource img) async {
    // take a photo
    XFile? photo = await picker.pickImage(
      source: img,
      requestFullMetadata: true,
      preferredCameraDevice: CameraDevice.rear,
    );
    
    // if the photo file is not null
    if (photo != null) {

      // save the image to the gallery
      await saveImageToGallery(photo);
    } 
  }

  // save an image to the device gallery
  Future saveImageToGallery(XFile image) async {
    //await FlutterImageGallerySaver.saveFile(image.path);
    await GallerySaver.saveImage(image.path, toDcim: true);
  }

}
