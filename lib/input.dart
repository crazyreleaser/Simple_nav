import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_nav/globals.dart';
// import 'package:simple_nav/DB.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Define a custom Form widget.
class Input extends StatefulWidget {
  @override
  _InputState createState() => _InputState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _InputState extends State<Input> {
  final VoidCallback myVoidCallBack = () {};
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  late TextEditingController _myController;
  // final myController = TextEditingController(text: '55.754024, 37.620381');

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    // _myController = TextEditingController(text: '55.754024, 37.620381');
    _myController = TextEditingController(text: GlobalData.lastLat.toString()+', '+GlobalData.lastLng.toString());
    // _myController = TextEditingController();
    _myController.addListener(_validateInput);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _myController.dispose();
    super.dispose();
  }
  void _validateInput() {
    // print('text field: ${_myController.text}');
    var text = _myController.text.split(', ');
    if (text.length != 2) {
      print("input is not formatted");
      return;
    } else if (text[0].replaceAll(',', '.').split('.').length != 2) {
      print("first part is not formatted");
      return;
    } else if (text[1].replaceAll(',', '.').split('.').length != 2) {
      print("second part is not formatted");
      return;
    };
    double lat = double.parse(text[0]);
    double lng = double.parse(text[1]);
    // var inputCoords = new coords(lat: lat.toString(), lng: lng.toString());
    // GlobalData.db.saveCoords(inputCoords);
    GlobalData.lastLat = lat;
    GlobalData.lastLng = lng;
    print('Valid coords: ' + lat.toString() +' '+ lng.toString());
    _saveCoords(lat.toString(), lng.toString());
  }

  void _saveCoords(String lat, String lng) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('lastLat', lat);
      prefs.setString('lastLng', lng);
      print('save coords: '+lat+' '+lng);
      myVoidCallBack();
    });
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      // inputFormatters: [maskFormatter],
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.done,
      controller: _myController,
      onSubmitted: (text) => print(_myController.text),
      // autofocus: true,
      maxLines: 1,
      maxLength: 22,
      cursorWidth: 5.0,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9,. ]')),
      ],
      decoration: InputDecoration(
        hintText: "55.754024, 37.620381",
        fillColor: Colors.white60,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: Colors.amber,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}