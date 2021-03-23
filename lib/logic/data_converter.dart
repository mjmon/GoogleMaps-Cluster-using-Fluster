import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataConverter {
  static LatLng stringToLatLng(String source) {
    if (source == null) {
      return null;
    }

    final splitString = source.split(',');
    if (splitString.length != 2) {
      return null;
    }

    final latitude = double.tryParse(splitString[0]);
    final longitude = double.tryParse(splitString[1]);

    if (latitude == null || longitude == null) return null;

    return LatLng(latitude, longitude);
  }
}
