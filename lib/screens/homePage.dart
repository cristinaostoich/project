import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'registration.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background color of the home page
      backgroundColor: Color.fromARGB(255, 79, 149, 240), // Light green background

      appBar: AppBar(
        title: Center(
          child: Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 42, // Bigger font size for the title
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor:
          Color.fromARGB(255, 79, 149, 240), // Same background color as the body
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
                  backgroundColor: Color.fromARGB(255, 118, 174, 249),
                  side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1), // Dark edges
                  textStyle: TextStyle(fontSize: 28),
                  foregroundColor: Color.fromARGB(255, 25, 73, 113),
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
                  backgroundColor: Color.fromARGB(255, 118, 174, 249),
                  side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1), // Dark edges
                  textStyle: TextStyle(fontSize: 28),
                  foregroundColor: Color.fromARGB(255, 25, 73, 113), // Dark green text color
                ),
                child: Text('Sign up'),
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
