import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_sample/logic/data_converter.dart';

class MapLocation {
  int id;
  LatLng coordinates;

  MapLocation.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        coordinates = DataConverter.stringToLatLng(json['coordinates']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'coordinates': coordinates != null
            ? '${coordinates.latitude},${coordinates.longitude}'
            : null,
      };
}
