import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // imports package for JSON management
import 'profilePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _accountName;
  String? _password;

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usersData = prefs.getString('users');
    Map<String, dynamic> users =
        usersData != null ? json.decode(usersData) : {};

    if (users.containsKey(_accountName) &&
        users[_accountName]['Password'] == _password) {
      // saves accountName in the shared preferences
      await prefs.setString('loggedInAccount', _accountName!);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(accountName: _accountName!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Wrong Account name or password'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // set background color
      backgroundColor: Color.fromARGB(255, 79, 149, 240),
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            fontSize: 30, // Bigger font size for the title
            color: Colors.white,
            //fontWeight: FontWeight.bold,
          ),
        ),
        //centerTitle: true,
        backgroundColor:
            Color.fromARGB(255, 79, 149, 240), // Set the same background color for AppBar
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white,),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Account name',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), //color of the line below the text
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), //color of the line when the field is in focus
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your account name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _accountName = value;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                obscureText: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value;
                },
              ),
              SizedBox(height: 50),
              SizedBox(
                width: 150, // Increase button width
                height: 50, // Increase button height
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 118, 174, 249),
                    side: BorderSide(
                      color: Color.fromARGB(255, 35, 99, 150), width: 1),
                      textStyle: TextStyle(fontSize: 22),
                      foregroundColor: Color.fromARGB(255, 25, 73, 113),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _login();
                    }
                  },
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
