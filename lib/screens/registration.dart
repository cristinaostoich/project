import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}


class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _accountName;
  String? _password;
  int? _cigPerDay;
  String? _cigType;
  double? _nicotine;

  // Function to validate if the password has at least one number
  bool _hasNumber(String value) {
    return value
        .contains(RegExp(r'[0-9]')); // Check if password contains a digit
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();


      // Recupera i dati degli utenti esistenti
      String? usersData = prefs.getString('users');
      Map<String, dynamic> users =
          usersData != null ? json.decode(usersData) : {};


      // Controlla se l'account name già esiste
      if (users.containsKey(_accountName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This account name already exists.'),
          ),
        );
      } else {
        final DateTime registrationDate = DateTime.now().toUtc();
        String formattedDate = registrationDate.toIso8601String();


        // Aggiungi i dati del nuovo utente
        users[_accountName!] = {
          'FirstName': _firstName,
          'LastName': _lastName,
          'Password': _password,
          'CigarettesPerDay': _cigPerDay,
          'CigaretteType': _cigType,
          'Nicotine': _nicotine,
          'registrationDate': formattedDate,
        };


        // Salva i dati aggiornati
        await prefs.setString('users', json.encode(users));
        print('User data saved: ${users[_accountName!]}');
        Navigator.pop(context);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 79, 149, 240),
      appBar: AppBar(
        title: Text(
          'Registration',
          style: TextStyle(fontSize: 30,
          color: Colors.white,)),
        iconTheme: IconThemeData(color: Colors.white,),
        backgroundColor: Color.fromARGB(255, 79, 149, 240),
        elevation: 0,
      ),
      body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'First name',
                  labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when not focused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when focused
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 // Set the input text color to white
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Last name',
                  labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when not focused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when focused
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 // Set the input text color to white
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Account name',
                  labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when not focused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when focused
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 // Set the input text color to white
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
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  //hintText: 'Enter your password',
                  errorStyle: TextStyle(color: Colors.yellow,),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow), // Set the underline color to yellow on error
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow), // Set the underline color to yellow when the field is focused and in error
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when not focused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when focused
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 // Set the input text color to white
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password';
                  } else if (value.length < 8) {
                    return 'Password must have at least 8 characters';
                  } else if (!_hasNumber(value)) {
                    return 'Password must have at least one number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value;
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(
                      labelText: 'Number of cigarettes per day',
                      labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when not focused
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Color of the underline when focused
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20 // Set the input text color to white
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the number of cigarettes per day';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cigPerDay = int.parse(value!);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 79, 149, 240),
                  borderRadius: BorderRadius.circular(8), // Optional: Round the corners of the container
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Cigarette type',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Color of the underline when not focused
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Color of the underline when focused
                    ),
                    filled: true,
                    fillColor: Color.fromARGB(255, 79, 149, 240), // Set the background color of the input field to blue
                  ),
                  dropdownColor: Color.fromARGB(255, 79, 149, 240), // Set the dropdown menu background color to blue
                  icon: Icon(
                      Icons.arrow_drop_down, 
                      color: Colors.white, // Imposta il colore della freccetta su bianco
                    ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Set the input text color to white
                  ),
                  items: <String>['Light', 'Regular', 'Heavy'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                 onChanged: (newValue) {
                  setState(() {
                    _cigType = newValue;
                    if (newValue == 'Light') {
                      _nicotine = 0.5;
                    } else if (newValue == 'Regular') {
                      _nicotine = 1.0;
                    } else if (newValue == 'Heavy') {
                      _nicotine = 1.5;
                    }
                  });
                },
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 118, 174, 249),
                  side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1), // Dark edges
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                  textStyle: TextStyle(fontSize: 20),
                  //foregroundColor: Color.fromARGB(255, 25, 73, 113),
                  foregroundColor: Color.fromARGB(255, 25, 73, 113),
                ),
                child: Text('Sign up'),
                
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}


