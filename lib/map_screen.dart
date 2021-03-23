import 'dart:async';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_sample/logic/helper/map_helper.dart';
import 'package:google_maps_sample/logic/helper/map_marker.dart';

import 'logic/map_location.dart';
import 'logic/map_screen_cubit.dart';
import 'logic/map_screen_state.dart';

final Completer<GoogleMapController> _mapController = Completer();

class MapScreen extends StatefulWidget {
  MapScreen({Key key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<MapScreenCubit, MapScreenState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is MapScreenStateLoading) {
                return GoogleMap(
                  mapType: MapType.normal,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  mapToolbarEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  initialCameraPosition: state.cameraPosition,
                  onMapCreated: (GoogleMapController currentController) {
                    _mapController.complete(currentController);
                  },
                );
              } else if (state is MapScreenStateLoaded) {
                return MapView(state: state);
              }
              return Center(
                child: Text('State not valid'),
              );
            }));
  }
}

class MapView extends StatefulWidget {
  const MapView({Key key, @required this.state}) : super(key: key);

  final MapScreenStateLoaded state;

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  /// Set of displayed markers and cluster markers on the map
  final Set<Marker> _markers = Set();

  //for debouncing onCameraMove
  Timer _debounce;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker> _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 6;

  /// Url image used on normal markers
  final String _markerImageUrl =
      'https://img.icons8.com/office/80/000000/marker.png';

  /// Color of the cluster circle
  final Color _clusterColor = Colors.blue;

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;

  /// Cluster width
  final int _clusterWidth = 100;

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// configure cluster [radius] and [extent]
  /// [radius] is the pixel radius of each cluster around it.
  /// [extent] is the distance between markers where they start to cluster.
  /// [extent] values `512`, `1024`, `2048`, `4096`, `8192` as maximum
  final int _radius = 150;
  final int _extent = 2048;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Called when the Google Map widget is created. Updates the map loading state
  /// and inits the markers.
  void _onMapCreated(GoogleMapController controller) {
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }

    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _initMarkers() async {
    final List<MapMarker> markers = [];

    final BitmapDescriptor markerImage =
        await MapHelper.getMarkerImageFromUrl(_markerImageUrl);

    for (MapLocation location in widget.state.locations) {
      markers.add(
        MapMarker(
          id: location.id.toString(),
          position: location.coordinates,
          icon: markerImage,
        ),
      );
    }

    _clusterManager = await MapHelper.initClusterManager(
        markers, _minClusterZoom, _maxClusterZoom, _radius, _extent);

    await _updateMarkers();
  }

  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers([double updatedZoom]) async {
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await MapHelper.getClusterMarkers(
      _clusterManager,
      _currentZoom,
      _clusterColor,
      _clusterTextColor,
      80,
    );

    _markers
      ..clear()
      ..addAll(updatedMarkers);

    setState(() {
      _areMarkersLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Google Map widget
        Opacity(
          opacity: _isMapLoading ? 0 : 1,
          child: GoogleMap(
            mapType: MapType.normal,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            mapToolbarEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            initialCameraPosition: CameraPosition(
              target: widget.state.cameraPosition.target,
              zoom: _currentZoom,
            ),
            markers: _markers,
            onMapCreated: (controller) => _onMapCreated(controller),
            onCameraMove: (position) {
              // debounce onCameraMove, only perform update once the user done, moving the camera
              if (_debounce?.isActive ?? false) _debounce.cancel();
              _debounce = Timer(const Duration(milliseconds: 200), () {
                _updateMarkers(position.zoom);
              });
            },
          ),
        ),

        // Map loading indicator
        Opacity(
          opacity: _isMapLoading ? 1 : 0,
          child: Center(child: CircularProgressIndicator()),
        ),

        // Map markers loading indicator
        if (_areMarkersLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Card(
                elevation: 2,
                color: Colors.grey.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    'Loading',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
