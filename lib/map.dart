import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:simple_nav/flutter_map_location_marker_my/flutter_map_location_marker_my.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:simple_nav/globals.dart';
import 'package:simple_nav/input.dart';
import 'package:geodesy/geodesy.dart' as geodesy;


class CenterFabExample extends StatefulWidget {
  @override
  _CenterFabExampleState createState() => _CenterFabExampleState();
}

class _CenterFabExampleState extends State<CenterFabExample> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _centerCurrentLocationStreamController;
  late StreamController<double> _headingStreamController;
  late StreamController<latlong.LatLng> _myPositionStreamController;

  double _headingToNorth = 0;
  double _directionToEnd = 0;
  Geodesy _geodesy = geodesy.Geodesy();
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
    _headingStreamController = StreamController<double>();
    _headingStreamController.stream.listen(_onHeading);
    _myPositionStreamController = StreamController<latlong.LatLng>();
    _myPositionStreamController.stream.listen(_onMyPosition);
  }
  void _onMyPosition(latlong.LatLng data) => setState(() {
    // print('\n\n--- StreamController My Position: '+data.latitude.toString() +' '+data.longitude.toString());
    GlobalData.myLat = data.latitude;
    GlobalData.myLng = data.longitude;
  });
  void _onHeading(double data) => setState(() {
    // print('outside map heading: '+data.toString());
    _headingToNorth = -data;
    if (_headingToNorth < 0) _headingToNorth = _headingToNorth + 360;
    // LatLng _startCoords = LatLng(0, 0);
    // LatLng _endCoords = LatLng(90, 0);
    LatLng _startCoords = geodesy.LatLng(GlobalData.myLat, GlobalData.myLng);
    LatLng _endCoords = geodesy.LatLng(GlobalData.lastLat, GlobalData.lastLng);
    num bearing = _geodesy.bearingBetweenTwoGeoPoints(_startCoords, _endCoords);
    // print("[bearingBetweenTwoGeoPoints] Bearing: " + bearing.toString());
    // double? direction = snapshot.data!.heading;
    // double? direction = 90;
    // direction = _heading;
    // print('direction to north: ' + _headingToNorth.toString());
    _directionToEnd = _headingToNorth + bearing;
    if(_directionToEnd >= 360) _directionToEnd = _directionToEnd - 360;
    // print('Direction to end point: ' + _directionToEnd.toString()+'\n');
    GlobalData.directionToEnd = _directionToEnd;
  });

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
    _headingStreamController.close();
    _myPositionStreamController.close();
    super.dispose();
    print("dispose map");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
              center: latlong.LatLng(0, 0),
              zoom: _zoom,
              maxZoom: _maxZoom,
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              // Stop centering the location marker on the map if user interacted with the map.
              onPositionChanged: (MapPosition position, bool hasGesture) {
                // print("Center map position: " + position.center!.latitude.toString());
                // GlobalData.myLat = position.center!.latitude;
                // GlobalData.myLng = position.center!.longitude;
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
                  point: latlong.LatLng(GlobalData.lastLat!, GlobalData.lastLng!),
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
                headingStreamController: _headingStreamController,
                myPositionStreamController: _myPositionStreamController,
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
                // width: MediaQuery.of(context).size.width * 0.9,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                top: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Input(),
                ),
            ),
            Positioned(
              width: 250,
              left: 10,
              bottom: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Transform.rotate(
                  angle: (_directionToEnd-90) * (pi / 180), // because arrow icon look at 15.00PM
                  // child: Image.asset('assets/compass.jpg'),
                  child: Icon(
                    Icons.trending_flat,
                    color: Colors.red,
                    size: 140,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}