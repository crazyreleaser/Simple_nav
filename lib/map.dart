import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:simple_nav/globals.dart';
import 'package:simple_nav/input.dart';

class CenterFabExample extends StatefulWidget {
  @override
  _CenterFabExampleState createState() => _CenterFabExampleState();
}

class _CenterFabExampleState extends State<CenterFabExample> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _centerCurrentLocationStreamController;
  double _zoom = 10;
  static double _minZoom = 0;
  static double _maxZoom = 19;
  void _incrementZoom() {
    if (_zoom < _maxZoom) {
      _zoom++;
    }
  }
  void _decrementZoom() {
    if (_zoom > _minZoom) {
      _zoom--;
    }
  }
  @override
  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double>();
  }

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
    super.dispose();
    print("dispose map");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
              center: LatLng(0, 0),
              zoom: _zoom,
              maxZoom: _maxZoom,
              // Stop centering the location marker on the map if user interacted with the map.
              onPositionChanged: (MapPosition position, bool hasGesture) {
                // print("Current position: " + position.center!.latitude.toString());
                GlobalData.myLat = position.center!.latitude;
                GlobalData.myLng = position.center!.longitude;
                if (hasGesture) {
                  setState(() => _centerOnLocationUpdate = CenterOnLocationUpdate.never);
                }
              }),
          children: [
            TileLayerWidget(
              options: TileLayerOptions(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                maxZoom: 19,
              ),
            ),
            MarkerLayerWidget(options: MarkerLayerOptions(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(GlobalData.lastLat!, GlobalData.lastLng!),
                  builder: (ctx) =>
                      Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                ),
              ],
            )),
            LocationMarkerLayerWidget(
              plugin: LocationMarkerPlugin(
                centerCurrentLocationStream: _centerCurrentLocationStreamController.stream,
                centerOnLocationUpdate: _centerOnLocationUpdate,
              ),
              options: LocationMarkerLayerOptions(
                marker: DefaultLocationMarker(
                  color: Colors.green,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                markerSize: const Size(40, 40),
                accuracyCircleColor: Colors.green.withOpacity(0.1),
                headingSectorColor: Colors.green.withOpacity(0.5),
                headingSectorRadius: 120,
                // markerAnimationDuration: Duration(milliseconds: 100), // disable animation
              ),
            ),
            Positioned(
              right: 20,
              bottom: 180,
              child: FloatingActionButton(
                onPressed: () {
                  _incrementZoom();
                  _centerCurrentLocationStreamController.add(_zoom);
                },
                child: Icon(
                  Icons.add,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 110,
              child: FloatingActionButton(
                onPressed: () {
                  _decrementZoom();
                  _centerCurrentLocationStreamController.add(_zoom);
                },
                child: Icon(
                  Icons.remove,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: () {
                  // Automatically center the location marker on the map when location updated until user interact with the map.
                  setState(() => _centerOnLocationUpdate = CenterOnLocationUpdate.always);
                  // Center the location marker on the map and zoom the map to level 18.
                  _centerCurrentLocationStreamController.add(_zoom);
                },
                child: Icon(
                  Icons.my_location,
                  color: Colors.red,
                ),
              ),
            ),
            Positioned(
                width: 250,
                left: 10,
                top: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Input(),
                ),
            ),
          ],
        ),
      ],
    );
  }
}