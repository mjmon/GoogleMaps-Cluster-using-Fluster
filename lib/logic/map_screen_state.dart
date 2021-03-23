import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_location.dart';

// Germany's camera position
const defaultCameraPosition = CameraPosition(
  target: LatLng(51.1642292, 10.4541194),
  zoom: 6,
);

abstract class MapScreenState extends Equatable {
  final CameraPosition cameraPosition;
  final bool locationPermissionIsDenied;

  //const ImpactMapState({this.cameraPosition = defaultCameraPosition, this.locationPermissionIsDenied = false});
  const MapScreenState(this.cameraPosition, this.locationPermissionIsDenied);

  @override
  List<Object> get props => [cameraPosition, locationPermissionIsDenied];
}

@immutable
class MapScreenStateLoading extends MapScreenState {
  const MapScreenStateLoading(
      CameraPosition cameraPosition, bool locationPermissionIsDenied)
      : super(cameraPosition, locationPermissionIsDenied);
}

class GoToMyPositionState extends MapScreenState {
  const GoToMyPositionState(
      CameraPosition cameraPosition, bool locationPermissionIsDenied)
      : super(cameraPosition, locationPermissionIsDenied);
}

@immutable
class MapScreenStateLoaded extends MapScreenState {
  final List<MapLocation> locations;

  const MapScreenStateLoaded(CameraPosition cameraPosition,
      bool locationPermissionIsDenied, this.locations)
      : super(cameraPosition, locationPermissionIsDenied);
}

@immutable
class ImpactMapStateCompaniesNotLoaded extends MapScreenState {
  const ImpactMapStateCompaniesNotLoaded(
      CameraPosition cameraPosition, bool locationPermissionIsDenied)
      : super(cameraPosition, locationPermissionIsDenied);
}
