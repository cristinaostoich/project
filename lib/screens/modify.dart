import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ModifyPage extends StatefulWidget {
  final String accountName;
  final String cigaretteType;
  final double nicotine;

  ModifyPage({
    required this.accountName,
    required this.cigaretteType,
    required this.nicotine,
  });

  @override
  _ModifyPageState createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  String? _selectedCigaretteType;
  double? _nicotine;
  String? _registrationDate;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _selectedCigaretteType = widget.cigaretteType;
    _nicotine = widget.nicotine;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersData = prefs.getString('users');
    Map<String, dynamic> users =
        usersData != null ? json.decode(usersData) : {};

    if (users.containsKey(widget.accountName)) {
      setState(() {
        _registrationDate = users[widget.accountName]['registrationDate'];
        _fullName =
            '${users[widget.accountName]['FirstName']} ${users[widget.accountName]['LastName']}';

        // Formatta la data per visualizzare solo giorno e mese
        if (_registrationDate != null) {
          DateTime registrationDateTime = DateTime.parse(_registrationDate!);
          _registrationDate = DateFormat('d MMM').format(registrationDateTime);
        }

        // Imposta la nicotina se non è stata cambiata
        if (_selectedCigaretteType == widget.cigaretteType) {
          _nicotine = users[widget.accountName]['Nicotine'];
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersData = prefs.getString('users');
    Map<String, dynamic> users =
        usersData != null ? json.decode(usersData) : {};

    if (users.containsKey(widget.accountName)) {
      users[widget.accountName]['CigaretteType'] = _selectedCigaretteType;
      users[widget.accountName]['Nicotine'] = _nicotine;
      await prefs.setString('users', json.encode(users));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle largeTextStyle = TextStyle(fontSize: 24);
    final TextStyle smallTextStyle = TextStyle(fontSize: 16);

    return Scaffold(
      backgroundColor: Colors.lightGreenAccent,
      appBar: AppBar(
        title: Text('Your Profile', style: largeTextStyle),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_fullName != null && _registrationDate != null)
                Column(
                  children: [
                    Text('Full name: $_fullName', style: largeTextStyle),
                    Text('Start of your journey: $_registrationDate',
                        style: largeTextStyle),
                    SizedBox(height: 24),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Modify the cigarette type:', style: smallTextStyle),
                  SizedBox(width: 16), // Spacer between text and dropdown
                  DropdownButton<String>(
                    value: _selectedCigaretteType,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCigaretteType = newValue;
                        if (newValue == 'Light') {
                          _nicotine = 0.5;
                        } else if (newValue == 'Regular') {
                          _nicotine = 1.0;
                        } else if (newValue == 'Heavy') {
                          _nicotine = 1.5;
                        }
                      });
                    },
                    items: <String>['Light', 'Regular', 'Heavy']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: smallTextStyle),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Selected Nicotine: $_nicotine mg', style: smallTextStyle),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes', style: smallTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
