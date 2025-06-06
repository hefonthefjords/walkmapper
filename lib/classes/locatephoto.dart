







import 'dart:io';
import 'package:exif/exif.dart';

/// Reads EXIF data from imageFile and returns a string with the GPS metadata.
  Future<String> extractLocationMetadata(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final data = await readExifFromBytes(bytes);

      // Check for the required GPS tags.
      if (data.containsKey('GPS GPSLatitude') &&
          data.containsKey('GPS GPSLatitudeRef') &&
          data.containsKey('GPS GPSLongitude') &&
          data.containsKey('GPS GPSLongitudeRef')) {
        final latTag = data['GPS GPSLatitude']!;
        final lonTag = data['GPS GPSLongitude']!;

        // Use the helper to extract a list of doubles.
        List<double> latComponents = _ifdRatiosToList(latTag.values);
        List<double> lonComponents = _ifdRatiosToList(lonTag.values);

        double latitude = _convertToDegree(latComponents);
        double longitude = _convertToDegree(lonComponents);

        final latRef = data['GPS GPSLatitudeRef']!.printable.trim();
        final lonRef = data['GPS GPSLongitudeRef']!.printable.trim();

        // Adjust for hemisphere: south and west become negative.
        if (latRef == 'S') latitude = -latitude;
        if (lonRef == 'W') longitude = -longitude;
        imageLocation =
            'Location: Latitude = $latitude, Longitude = $longitude';
        //print("image loc form extract func $imageLocation");
        return imageLocation;
      } else {
        imageLocation = 'No location metadata available in this image.';
        //print('No location metadata available in this image.');
        return 'No location metadata available in this image.';
      }
    } catch (e) {
      //print("Error reading EXIF data: $e");
      return 'An error occurred while extracting location metadata.';
    }
  