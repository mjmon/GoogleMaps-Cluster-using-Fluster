import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bloc/bloc.dart';
import 'map_location.dart';
import 'map_screen_state.dart';

class MapScreenCubit extends Cubit<MapScreenState> {
  MapScreenCubit() : super(MapScreenStateLoading(defaultCameraPosition, false));

  Future<void> getData() async {
    try {
      final content = await rootBundle.loadString('assets/json/locations.json');

      final locations = (json.decode(content) as List)
          .map((i) => MapLocation.fromJson(i))
          .take(200) //Limit the points that are shown for testing purposes
          .toList();

      emit(MapScreenStateLoaded(defaultCameraPosition, false, locations));
    } catch (e) {
      print(e.toString());
    }
  }
}
