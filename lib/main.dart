/// Flutter code sample for BottomNavigationBar

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets, which means it defaults to [BottomNavigationBarType.fixed], and
// the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].

import 'package:flutter/material.dart';
import 'package:simple_nav/globals.dart';
import 'package:simple_nav/maps.dart';
import 'package:simple_nav/map.dart';
import 'package:simple_nav/input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_nav/compass.dart';

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
  int _selectedIndex = 0;

  void _loadLastCoords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      GlobalData.lastLat = double.parse(prefs.getString('lastLat') ?? '55.754024');
      GlobalData.lastLng = double.parse(prefs.getString('lastLng') ?? '37.620381');
      if (GlobalData.myLat != null) {
        GlobalData.isDataLoaded = true;
        print("data loaded");
      };
      print('Load last Coords: ' + GlobalData.lastLat.toString()+' '+ GlobalData.lastLng.toString());
    });
  }
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Input(),
        ),
        Compass(),
      ],
    ),
    CenterFabExample(),
    // TapboxA(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
          child: IndexedStack(
              index:_selectedIndex,
              children:_widgetOptions
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Business',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
