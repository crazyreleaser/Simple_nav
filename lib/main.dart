import 'package:flutter/material.dart';
import 'package:simple_nav/globals.dart';
import 'package:simple_nav/map.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    _loadLastCoords();
  }

  void _loadLastCoords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      GlobalData.lastLat = double.parse(prefs.getString('lastLat') ?? '55.754024');
      GlobalData.lastLng = double.parse(prefs.getString('lastLng') ?? '37.620381');
      if (GlobalData.myLat != null) {
        GlobalData.isDataLoaded = true;
      };
    });
  }


  @override
  Widget build(BuildContext context) {
    if (GlobalData.isDataLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Simple Navigator'),
        ),
        body: Center(
          child: CenterFabExample(),
        ),

      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
