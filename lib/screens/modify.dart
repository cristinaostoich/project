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

        //formats date to visualize day and month only
        if (_registrationDate != null) {
          DateTime registrationDateTime = DateTime.parse(_registrationDate!);
          _registrationDate = DateFormat('d MMM').format(registrationDateTime);
        }

        //sets nicotine if it has not been changed
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
      backgroundColor: Color.fromARGB(255, 79, 149, 240),
      appBar: AppBar(
        title: Text(
          'Your Profile',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            //fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            Color.fromARGB(255, 79, 149, 240),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white,),
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
                    Text(
                      '$_fullName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                    Text('your journey has started on $_registrationDate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        )),
                    SizedBox(height: 38),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Modify cigarette type:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    )),
                  SizedBox(width: 18), // Spacer between text and dropdown
                  DropdownButton<String>(
                    value: _selectedCigaretteType,
                    dropdownColor: Color.fromARGB(255, 118, 174, 249),
                    icon: Icon(
                      Icons.arrow_drop_down, 
                      color: Colors.white, //arrow color
                    ),
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
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          )),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Selected Nicotine: $_nicotine mg',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 118, 174, 249),
                  side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                  textStyle: TextStyle(fontSize: 20),
                  foregroundColor: Color.fromARGB(255, 25, 73, 113),
                ),
                child: Text('Save Changes', style: smallTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
