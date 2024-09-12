import 'package:flutter/material.dart';

class DeleteAccountPage extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  DeleteAccountPage({required this.onDelete, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 79, 149, 240),
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          )),
        backgroundColor: Color.fromARGB(255, 79, 149, 240),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white,),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Do you want to delete this account?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: onDelete,
                  child: Text('Yes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 118, 174, 249),
                    side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1), // Dark edges
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                    textStyle: TextStyle(fontSize: 20),
                    foregroundColor: Color.fromARGB(255, 25, 73, 113),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: onCancel,
                  child: Text('No'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 118, 174, 249),
                    side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1), // Dark edges
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                    textStyle: TextStyle(fontSize: 20),
                    foregroundColor: Color.fromARGB(255, 25, 73, 113),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
