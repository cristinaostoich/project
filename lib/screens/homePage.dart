import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'registration.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background color of the home page
      backgroundColor: Colors.lightGreenAccent, // Light green background

      appBar: AppBar(
        title: Center(
          child: Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 42, // Bigger font size for the title
            ),
          ),
        ),
        backgroundColor:
            Colors.lightGreenAccent, // Same background color as the body
        elevation: 0, // Remove shadow for a cleaner look
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Login Button
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black, width: 2), // Dark edges
                  textStyle: TextStyle(fontSize: 28),
                  foregroundColor: Colors.green[900], // Dark green text color
                ),
                child: Text('Login'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ),
            SizedBox(height: 30), // Add space between the buttons
            // Register Button
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black, width: 2), // Dark edges
                  textStyle: TextStyle(fontSize: 28),
                  foregroundColor: Colors.green[900], // Dark green text color
                ),
                child: Text('Register'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
