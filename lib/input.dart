import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_nav/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Define a custom Form widget.
class Input extends StatefulWidget {
  @override
  _InputState createState() => _InputState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _InputState extends State<Input> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  late TextEditingController _myController;

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    _myController = TextEditingController(text: GlobalData.lastLat.toString()+', '+GlobalData.lastLng.toString());
    _myController.addListener(_validateInput);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _myController.dispose();
    super.dispose();
  }
  void _showSnackBar(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(milliseconds: 500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _validateInput() {
    var text = _myController.text.replaceAll(' ', '').split(',');
    if (text.length != 2) {                                                                         // check that we have 2 numbers separated by ','
      return;
    } else if (text[0].replaceAll(',', '.').split('.').length != 2) {                               // check that in first number we have only 1 '.'
      _showSnackBar('first part is not formated');
      return;
    } else if (text[1].replaceAll(',', '.').split('.').length != 2) {                               // check that in second number we have only 1 '.'
      _showSnackBar('second part is not formated');
      return;
    };
    if (text[0].indexOf('-') != -1) {                                                               // check that first number contains '-'
      var lattmp = text[0].split('-');
      if (lattmp.length > 2) {                                                                        // check that first number contains only one '-'
        _showSnackBar('first part is not formated');
        return;
      } else if (lattmp[0].length > 0) {                                                              //check that '-' is the first character
        _showSnackBar('first part is not formated');
        return;
      };
    }
    if (text[1].indexOf('-') != -1) {                                                               // check that second number contains '-'
      var lngtmp = text[1].split('-');
      if (lngtmp.length > 2) {                                                                        // check that second number contains only one '-'
        _showSnackBar('second part is not formated');
        return;
      } else if (lngtmp[0].length > 0) {                                                              //check that '-' is the first character
        _showSnackBar('second part is not formated');
        return;
      };
    }

    double lat = double.parse(text[0]);
    double lng = double.parse(text[1]);
    if (lng > 180 || lng < -180 || lat > 180 || lat < -180){
      _showSnackBar('invalid coords: allow 0-180');
      return;
    }
    GlobalData.lastLat = lat;
    GlobalData.lastLng = lng;
    _saveCoords(lat.toString(), lng.toString());
  }

  void _saveCoords(String lat, String lng) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('lastLat', lat);
      prefs.setString('lastLng', lng);
    });
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      controller: _myController,
      onSubmitted: (text) => print(_myController.text),
      autofocus: false,
      maxLines: 1,
      maxLength: 22,
      cursorWidth: 5.0,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9,. -]')),
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