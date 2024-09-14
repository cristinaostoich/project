import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cigarette_counter.dart';
import 'modify.dart';
import 'plots.dart';
import 'homePage.dart';
import 'delete_account_page.dart';

class ProfilePage extends StatefulWidget {
  final String accountName;

  ProfilePage({required this.accountName});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _cigaretteType;
  double? _nicotine;
  String? _registrationDate;
  String? _firstName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCigarettesSmokedToday();
    _loadHourlyNicotineData();
    _checkAndResetHourlyCounter();
    _checkAndResetDailyCounter();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountName = prefs.getString('loggedInAccount');

    if (accountName != null) {
      String? usersData = prefs.getString('users');
      Map<String, dynamic> users = usersData != null ? json.decode(usersData) : {};

      if (users.containsKey(accountName)) {
        setState(() {
          _cigaretteType = users[accountName]['CigaretteType'];
          _nicotine = users[accountName]['Nicotine'];
          _registrationDate = users[accountName]['registrationDate'];
          _firstName = users[accountName]['FirstName'];
        });
        _loadHourlyNicotineData();
      }
      //print('cigarette type: $_cigaretteType');
    }
  }

  Future<void> _loadHourlyNicotineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hourlyNicotineKey = _getHourlyNicotineKey();
    double hourlyNicotine = prefs.getDouble(hourlyNicotineKey) ?? 0.0;
    
    String dailyNicotineKey = _getDailyNicotineKey();
    double dailyNicotine = prefs.getDouble(dailyNicotineKey) ?? 0.0;
     String dailyCountKey = "${widget.accountName}_dailyHCounts";
    String? dailyCountData = prefs.getString(dailyCountKey);
    Map<String, int> dailyCount = dailyCountData != null ? Map<String, int>.from(json.decode(dailyCountData)) : {};
    int count = prefs.getInt(dailyCountKey) ?? 0;


    setState(() {
      Provider.of<CigaretteCounter>(context, listen: false).setHourlyNicotine(hourlyNicotine);
      Provider.of<CigaretteCounter>(context, listen: false).setDailyNicotine(dailyNicotine);
      Provider.of<CigaretteCounter>(context, listen: false).setDailyCigarettes(count);

    });
  }

  Future<void> _loadCigarettesSmokedToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey = _getTodayKey();
    String dailyCountsKey = "${widget.accountName}_dailyCounts";
    String? dailyCountsData = prefs.getString(dailyCountsKey);
    Map<String, int> dailyCounts = dailyCountsData != null ? Map<String, int>.from(json.decode(dailyCountsData)) : {};
    
    int cigarettes = prefs.getInt(todayKey) ?? 0;
    Provider.of<CigaretteCounter>(context, listen: false).setCigarettes(cigarettes);
  }


  Future<void> _incrementCigaretteCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey = _getTodayKey();
    String hourlyKey = _getHourlyKey();
    String hourlyNicotineKey = _getHourlyNicotineKey();
    String dailyKey = _getDailyKey();
    String dailyNicotineKey = _getDailyNicotineKey();

    int newCount = Provider.of<CigaretteCounter>(context, listen: false).cigarettesSmokedToday +1;
    int newCountH = Provider.of<CigaretteCounter>(context, listen: false).hourlyCigarettesSmoked +1;
    int dailyCount = Provider.of<CigaretteCounter>(context, listen: false).dailyCigarettesCount +1;
    //print('newCount: $newCount');
    //print('current daily count: $dailyCount'); //------> è 0
    //print('current count H: $newCountH');


    double hourlyNicotine = prefs.getDouble(hourlyNicotineKey) ?? 0.0;
    double dailyNicotine = prefs.getDouble(dailyNicotineKey) ?? 0.0;

    //await _recordCigaretteTime();

    _saveDailyCount(newCount);
    _checkAndResetDailyCounter();

    hourlyNicotine += _nicotine ?? 0.0;
    dailyNicotine += _nicotine ?? 0.0;
    //print('daily nicotine: $dailyNicotine');

    setState(() {
      prefs.setInt(todayKey, newCount);
      prefs.setInt(hourlyKey, newCountH);
      prefs.setInt(dailyKey, dailyCount);
      prefs.setDouble(hourlyNicotineKey, hourlyNicotine);
      prefs.setDouble(dailyNicotineKey, dailyNicotine);

      Provider.of<CigaretteCounter>(context, listen: false).incrementCigarettes();
      Provider.of<CigaretteCounter>(context, listen: false).updateHourlyCount(newCountH, hourlyNicotine);
      Provider.of<CigaretteCounter>(context, listen: false).updateDailyCount(dailyCount, dailyNicotine);
    });

    _saveHourlyCount(newCountH);
    _checkAndResetHourlyCounter();
    _checkAndResetDailyCounter();
  }

  Future<void> _decrementCigaretteCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey = _getTodayKey();
    String hourlyKey = _getHourlyKey();
    String hourlyNicotineKey = _getHourlyNicotineKey();
    String dailyKey = _getDailyKey();
    String dailyNicotineKey = _getDailyNicotineKey();

    int currentCount = Provider.of<CigaretteCounter>(context, listen: false).cigarettesSmokedToday;
    int currentCountH = Provider.of<CigaretteCounter>(context, listen: false).hourlyCigarettesSmoked;
    int currentDailyCount = Provider.of<CigaretteCounter>(context, listen: false).dailyCigarettesCount;
    print('current daily count: $currentDailyCount'); //------> è 0
    print('current count H: $currentCountH');

    double hourlyNicotine = prefs.getDouble(hourlyNicotineKey) ?? 0.0;
    double dailyNicotine = prefs.getDouble(dailyNicotineKey) ?? 0.0;
    //print('daily nicotine: $dailyNicotine');

    if (currentCount > 0) {
      int newCount = currentCount - 1;
      //print('daily nicotine: $dailyNicotine');
      //setState(() {
      //  prefs.setInt(todayKey, newCount);
      //  Provider.of<CigaretteCounter>(context, listen: false).setCigarettes(newCount);
      //});
      _saveDailyCount(newCount);
      //_checkAndResetDailyCounter();
      //print('daily nicotine: $dailyNicotine');
      
      
      /////////VEDI SE QUESTO IF VA QUA O ALTROVE
      if (currentDailyCount > 0) {
        int dailyCount = currentDailyCount - 1;
        if (dailyNicotine >= (_nicotine ?? 0.0)) {
          dailyNicotine -= (_nicotine ?? 0.0);
        } else {
          dailyNicotine = 0.0;
        }
        print('daily nicotine: $dailyNicotine');
        setState(() {
          prefs.setInt(dailyKey, dailyCount);
          prefs.setDouble(dailyNicotineKey, dailyNicotine);
          Provider.of<CigaretteCounter>(context, listen: false).setDailyCigarettes(dailyCount);
          Provider.of<CigaretteCounter>(context, listen: false).setDailyNicotine(dailyNicotine);
          Provider.of<CigaretteCounter>(context, listen: false).updateDailyCount(dailyCount, dailyNicotine);

        });
        _checkAndResetDailyCounter();
        //print('daily nicotine: $dailyNicotine');
      }

      if (currentCountH > 0) {
        int newCountH = currentCountH - 1;
        if (hourlyNicotine >= (_nicotine ?? 0.0)) {
          hourlyNicotine -= (_nicotine ?? 0.0);
        } else {
          hourlyNicotine = 0.0;
        }
        //print('hourlyNicotine: $hourlyNicotine');

        setState(() {
          prefs.setInt(hourlyKey, newCountH);
          prefs.setDouble(hourlyNicotineKey, hourlyNicotine);
          Provider.of<CigaretteCounter>(context, listen: false).setHourlyCigarettes(newCountH);
          Provider.of<CigaretteCounter>(context, listen: false).setHourlyNicotine(hourlyNicotine);
          Provider.of<CigaretteCounter>(context, listen: false).updateHourlyCount(newCountH, hourlyNicotine);

          
        });

        _saveHourlyCount(newCountH);
        _checkAndResetHourlyCounter();
      }

      

      setState(() {
        prefs.setInt(todayKey, newCount);
        Provider.of<CigaretteCounter>(context, listen: false).setCigarettes(newCount);
      

      });
    }
  }

  String _getTodayKey() {
    DateTime now = DateTime.now();
    String accountName = widget.accountName;
    return "${accountName}_cigarettes_${now.year}${now.month}${now.day}";
  }

  String _getHourlyKey() {
    DateTime now = DateTime.now();
    String accountName = widget.accountName;
    return "${accountName}_hourly_cigarettes_${now.year}${now.month}${now.day}${now.hour}";
  }

  String _getDailyKey() {
    DateTime now = DateTime.now();
    String accountName = widget.accountName;
    return "${accountName}_daily_cigarettes_${now.year}${now.month}${now.day}";
  }

  String _getHourlyNicotineKey() {
    DateTime now = DateTime.now();
    String accountName = widget.accountName;
    return "${accountName}_hourly_nicotine_${now.year}${now.month}${now.day}${now.hour}";
  }

    String _getDailyNicotineKey() {
      DateTime now = DateTime.now();
      String accountName = widget.accountName;
      return "${accountName}_daily_nicotine_${now.year}${now.month}${now.day}";
    }

  //Future<void> _recordCigaretteTime() async {
  //  SharedPreferences prefs = await SharedPreferences.getInstance();
  //  String currentKey = "${widget.accountName}_${DateTime.now().toIso8601String()}";
  //  prefs.setInt(currentKey, 1);
  //}

  //questi metodi qua sotto magari li teniamo, ma ci sono anche in cigaretteCOunter e forse da là li posso togliere
  Future<void> _checkAndResetHourlyCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hourlyKey = _getHourlyKey();
    String hourlyNicotineKey = _getHourlyNicotineKey();
    //String dailyKey = _getDailyKey();
    //String dailyNicotineKey = _getDailyNicotineKey();
    String lastUpdateKey = "${widget.accountName}_lastHourlyUpdate";
    DateTime now = DateTime.now();

    DateTime lastUpdate = DateTime.parse(prefs.getString(lastUpdateKey) ?? now.toIso8601String());

    if (now.difference(lastUpdate).inHours != 0) {
      prefs.setInt(hourlyKey, 0);
      prefs.setDouble(hourlyNicotineKey, 0.0);
      Provider.of<CigaretteCounter>(context, listen: false).updateHourlyCount(0, 0.0);
      prefs.setString(lastUpdateKey, now.toIso8601String());
    }
  }

  Future<void> _checkAndResetDailyCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dailyKey = _getDailyKey();
    String dailyNicotineKey = _getDailyNicotineKey();
    String lastUpdateKeyDays = "${widget.accountName}_lastHourlyUpdateDays";
    DateTime now = DateTime.now();

    DateTime lastUpdateDays = DateTime.parse(prefs.getString(lastUpdateKeyDays) ?? now.toIso8601String());
    //DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (now.difference(lastUpdateDays).inDays != 0) {
      prefs.setInt(dailyKey, 0);
      prefs.setDouble(dailyNicotineKey, 0.0);
      Provider.of<CigaretteCounter>(context, listen: false).updateDailyCount(0, 0.0);
      prefs.setString(lastUpdateKeyDays, now.toIso8601String());
    }
  }

  Future<void> _saveDailyCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey = _getTodayKey();
    String dailyCountsKey = "${widget.accountName}_dailyHCounts";
    String? dailyCountsData = prefs.getString(dailyCountsKey);
    Map<String, int> dailyCounts = dailyCountsData != null ? Map<String, int>.from(json.decode(dailyCountsData)) : {};
    dailyCounts[todayKey] = count;
    await prefs.setString(dailyCountsKey, json.encode(dailyCounts));
  }

  Future<void> _saveHourlyCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hourlyKey = _getHourlyKey();
    String hourlyCountsKey = "${widget.accountName}_hourlyCounts";
    String? hourlyCountsData = prefs.getString(hourlyCountsKey);
    Map<String, int> hourlyCounts = hourlyCountsData != null ? Map<String, int>.from(json.decode(hourlyCountsData)) : {};
    hourlyCounts[hourlyKey] = count;
    await prefs.setString(hourlyCountsKey, json.encode(hourlyCounts));
  }
  

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInAccount'); //removes the login state
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), // Replaces HomePage() with your actual homepage widget
      (Route<dynamic> route) => false, // Removes all previous routes
    );
  }


  void _showDeleteConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteAccountPage(
          onDelete: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? accountName = prefs.getString('loggedInAccount');


            if (accountName != null) {
              // Recupera i dati degli utenti
              String? usersData = prefs.getString('users');
              Map<String, dynamic> users = usersData != null ? json.decode(usersData) : {};


              // Rimuovi solo i dati dell'utente specifico
              if (users.containsKey(accountName)) {
                users.remove(accountName); // Rimuovi solo i dati dell'utente corrente
                await prefs.setString('users', json.encode(users));
              }

              // Rimuovi il login
              await prefs.remove('loggedInAccount');
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            );
          },
          onCancel: () {
            Navigator.pop(context); //back to profilePage
          },
        ),
      ),
    );
  } //_showDeleteConfirmation


  @override
  Widget build(BuildContext context) {
    final cigaretteProvider = Provider.of<CigaretteCounter>(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 79, 149, 240),
      appBar: AppBar(
        title: Text(
          'Profile',
          //textAlign:TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 79, 149, 240),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white,),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hi $_firstName!',
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 28),
            Text(
              'Cigarette Type: $_cigaretteType',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'What do you want to do?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifyPage(
                      accountName: widget.accountName,
                      cigaretteType: _cigaretteType!,
                      nicotine: 0.0,
                    ),
                  ),
                ).then((_) {
                  _loadUserData();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 118, 174, 249),
                side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1), // Dark edges
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                textStyle: TextStyle(fontSize: 20),
                foregroundColor: Color.fromARGB(255, 25, 73, 113),
              ),
              child: Text('Modify Profile'),
            ),
            

            SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              _incrementCigaretteCount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 118, 174, 249),
              side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1), // Dark edges
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
              textStyle: TextStyle(fontSize: 20),
              foregroundColor: Color.fromARGB(255, 25, 73, 113),

            ),
            child: Text('Add a Cigarette'),
          ),
          SizedBox(height: 10), 
          GestureDetector(
            onTap: () {
              _decrementCigaretteCount();
            },
            child: Container(
              padding: EdgeInsets.all(0), 
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color.fromARGB(255, 35, 99, 150), width: 2),
              ),
              child: Icon(
                Icons.remove,
                color: Color.fromARGB(255, 35, 99, 150),
                size: 30, 
              ),
            ),
          ),

          SizedBox(height: 28),
          Text(
            'Cigarettes Smoked Today: ${cigaretteProvider.cigarettesSmokedToday}',              
              style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(                    builder: (context) => Plots(accountName: widget.accountName),
                 ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 118, 174, 249),
              side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1), // Dark edges
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
              textStyle: TextStyle(fontSize: 20),
              foregroundColor: Color.fromARGB(255, 25, 73, 113),
            ),
             child: Text('Your Progress'),
          ),
          Text(
            'Hourly Nicotine: ${cigaretteProvider.hourlyNicotine.toStringAsFixed(2)} mg',
            style: TextStyle(fontSize: 18),
          ),
          Text('DailyNicotine: ${cigaretteProvider.dailyNicotine.toStringAsFixed(2)} mg'),
        ],
      ),
    ),
    
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ElevatedButton(
              onPressed: _showDeleteConfirmation,
              child: Icon(Icons.delete, size: 30), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 118, 174, 249),
                side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1),
                shadowColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                foregroundColor: Color.fromARGB(255, 25, 73, 113), 
              ),
            ),
            ElevatedButton(
              onPressed: _logout,
              child: Icon(Icons.logout, size: 30), 
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 118, 174, 249),
                side: BorderSide(color: Color.fromARGB(255, 35, 99, 150), width: 1),
                shadowColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                foregroundColor: Color.fromARGB(255, 25, 73, 113),
              ),
            ),            
          ],
        ),
      ),
    );
  }
}
