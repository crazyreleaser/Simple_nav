import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geodesy/geodesy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_nav/globals.dart';

// void main() => runApp(MyApp());

class Compass extends StatefulWidget {
   @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  bool _hasPermissions = false;
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;
  double? _heading;
  Geodesy _geodesy = Geodesy();

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }
  double _mathBering(data) {
    // LatLng _startCoords = LatLng(0, 0);
    // LatLng _endCoords = LatLng(-90, 0);
    LatLng _startCoords = LatLng(GlobalData.myLat, GlobalData.myLng);
    LatLng _endCoords = LatLng(GlobalData.lastLat, GlobalData.lastLng);
    num bearing = _geodesy.bearingBetweenTwoGeoPoints(_startCoords, _endCoords);
    print("[bearingBetweenTwoGeoPoints] Bearing: " + bearing.toString());
    double? direction = data.data!.heading;
    // double? direction = 90;
    print('direction to north: ' + direction.toString());
    double heading = direction! + bearing;
    if(heading >= 360) heading = heading - 360;
    print('Heading: ' + heading.toString());
    return heading;
  }
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
          if (_hasPermissions) {
            return Column(
              children: <Widget>[
                _buildManualReader(),
                SizedBox(
                    height: MediaQuery.of(context).size.height*0.5,
                    child: _buildCompass()
                ),
              ],
            );
          } else {
            return _buildPermissionSheet();
          }
        });
  }

  Widget _buildManualReader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          ElevatedButton(
            child: Text('Read Value'),
            onPressed: () async {
              final CompassEvent tmp = await FlutterCompass.events!.last;
              setState(() {
                _lastRead = tmp;
                _lastReadAt = DateTime.now();
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$_lastRead',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    '$_lastReadAt',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // @override
  Widget _buildCompass() {
  // Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('connection waiting');
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // LatLng _startCoords = LatLng(0, 0);
        // LatLng _endCoords = LatLng(-90, 0);
        LatLng _startCoords = LatLng(GlobalData.myLat, GlobalData.myLng);
        LatLng _endCoords = LatLng(GlobalData.lastLat, GlobalData.lastLng);
        num bearing = _geodesy.bearingBetweenTwoGeoPoints(_startCoords, _endCoords);
        print("[bearingBetweenTwoGeoPoints] Bearing: " + bearing.toString());
        double? direction = snapshot.data!.heading;
        // double? direction = 90;
        print('direction to north: ' + direction.toString());
        double heading = direction! + bearing;
        if(heading >= 360) heading = heading - 360;
        print('Heading: ' + heading.toString());
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1)-90, // because arrow icon look at 15.00PM
              // child: Image.asset('assets/compass.jpg'),
              child: Icon(
                Icons.trending_flat,
                color: Colors.red,
                size: 140,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Location Permission Required'),
          ElevatedButton(
            child: Text('Request Permissions'),
            onPressed: () {
              Permission.locationWhenInUse.request().then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Open App Settings'),
            onPressed: () {
              openAppSettings().then((opened) {
                //
              });
            },
          )
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          print('setState '+status.toString());
          _hasPermissions = status == PermissionStatus.granted;
        });
      }
    });
  }
}