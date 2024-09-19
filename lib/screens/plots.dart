import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'cigarette_counter.dart';
import 'package:progetto/charts/plot_creation.dart';


class Plots extends StatefulWidget {
  final String accountName;


  Plots({required this.accountName});


  @override
  _PlotsState createState() => _PlotsState();
}


class _PlotsState extends State<Plots> {
  DateTime? registrationDate;
  List<NicotineLevel> data = [];
  List<HourlyNicotineLevel> hourlyData = [];
  List<HourlyNicotineLevel> dailyData = [];
  int _cigarettesPerDay = 0;
  int threshold = 0;
  bool isLoading = true;
  double nicotineSmokedToday = 0.0;
  double _nicotine = 0.0;
  double nicotineSmokedThisHour = 0.0;
  double dailyNicotineTarget = 0.0;


  @override
  void initState() {
    super.initState();
    _loadRegistrationData();

    //updates counters when the screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen: false);
      cigaretteCounter.resetCountersIfNeeded();
    });
  }


  Future<void> _loadRegistrationData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usersData = prefs.getString('users');

      Map<String, dynamic> users = usersData != null ? json.decode(usersData) : {};


      if (users.containsKey(widget.accountName)) {
        var userProfile = users[widget.accountName];
        String? dateStr = userProfile['registrationDate'];
        _cigarettesPerDay = userProfile['CigarettesPerDay'] ?? 0;
        _nicotine = userProfile['Nicotine'] ?? 0.0;
        threshold = _cigarettesPerDay; //threshold initialization


        if (dateStr != null) {
          registrationDate = DateTime.parse(dateStr);
        } else {
          registrationDate = DateTime.now();
        }

        //calculates number of days from registration
        if (registrationDate != null) {
          int daysSinceRegistration = DateTime.now().difference(registrationDate!).inDays;

          //decreases threshold by one every 7 days from registration
          threshold -= (daysSinceRegistration ~/ 7);
          if (threshold < 0) threshold = 0; // threshold cannot be <0
        }

        await _generateChartData(users);
        await _generateHourlyData(users);
      } else {
        print("User not found: ${widget.accountName}");
      }
    } catch (e) {
      print("Error loading registration data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _generateChartData(Map<String, dynamic> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dailyCountsKey = "${widget.accountName}_dailyCounts";
    String? dailyCountsData = prefs.getString(dailyCountsKey);
    Map<String, int> dailyCounts = dailyCountsData != null ? Map<String, int>.from(json.decode(dailyCountsData)) : {};
    double dailyNicotineTarget = threshold * _nicotine; // Calcola la soglia giornaliera


    if (registrationDate != null) {
      DateTime now = DateTime.now();
      DateTime startDate = registrationDate!;
      DateTime endDate = DateTime(startDate.year, startDate.month, startDate.day + _cigarettesPerDay*7);

      data = [];

      int totalCigarettes = 0;

      int daysToGenerate = _cigarettesPerDay * 7;

      for (int i = 0; i < daysToGenerate; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String dateKey = "${widget.accountName}_cigarettes_${currentDate.year}${currentDate.month}${currentDate.day}";
        double cigarettes = dailyCounts[dateKey]?.toDouble() ?? 0.0;

        data.add(NicotineLevel(date: currentDate, level: cigarettes));
      }

      final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen: false);
      data.add(NicotineLevel(date: now, level: cigaretteCounter.cigarettesSmokedToday.toDouble()));
      totalCigarettes += cigaretteCounter.cigarettesSmokedToday;

      int futureDays = -(now.difference(endDate).inDays);

      for (int i = 1; i <= futureDays; i++) {
        DateTime futureDate = now.add(Duration(days: i));
        data.add(NicotineLevel(date: futureDate, level: 0.0));
      }
      setState(() {
        //will be used to show the counter in the widget
        this.dailyNicotineTarget = dailyNicotineTarget;
      });
    }
  }


  Future<void> _generateHourlyData(Map<String, dynamic> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hourlyCountsKey = "${widget.accountName}_hourlyCounts";
    String? hourlyCountsData = prefs.getString(hourlyCountsKey);
    Map<String, int> hourlyCounts = hourlyCountsData != null
        ? Map<String, int>.from(json.decode(hourlyCountsData))
        : {};
    String dailyHCountsKey = "${widget.accountName}_dailyHCounts";
    String? dailyHCountsData = prefs.getString(dailyHCountsKey);
    Map<String, int> dailyHCounts = dailyHCountsData != null
        ? Map<String, int>.from(json.decode(dailyHCountsData))
        : {};

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day); //hourly chart refers to today's date
    hourlyData = [];
    dailyData = [];

    int hoursToGenerate = 24;
    DateTime roundedHour= DateTime(now.year, now.month, now.day, now.hour);
    int cigarettesSmokedThisHour = 0;
    double nicotineSmokedThisHour = 0.0;
    double nicotineSmokedToday = 0.0;


    for (int i = 0; i <= hoursToGenerate; i++) {
      DateTime currentHour = startOfDay.add(Duration(hours: i));
      String hourlyKey = "${widget.accountName}_hourly_cigarettes_${currentHour.year}${currentHour.month}${currentHour.day}${currentHour.hour}";
      double cigarettes = hourlyCounts[hourlyKey]?.toDouble() ?? 0.0;
      hourlyData.add(HourlyNicotineLevel(time: currentHour, level: cigarettes));

      String dailyHKey = "${widget.accountName}_daily_cigarettes_${currentHour.year}${currentHour.month}${currentHour.day}";
      double nicotine = dailyHCounts[dailyHKey]?.toDouble() ?? 0.0;
      dailyData.add(HourlyNicotineLevel(time: currentHour, level: nicotine));
    }

    //adds data of current hour
    final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen: false);
    hourlyData.add(HourlyNicotineLevel(time: now, level: cigaretteCounter.hourlyNicotine));
    nicotineSmokedThisHour += cigaretteCounter.hourlyNicotine.toDouble();
    //print('nicotine smoked this hour: $nicotineSmokedThisHour');
    cigarettesSmokedThisHour += cigaretteCounter.hourlyCigarettesSmoked;
    nicotineSmokedToday += cigaretteCounter.dailyNicotine.toDouble();

    //adds future data (for future hours)
    DateTime tomorrow = DateTime(now.year, now.month, now.day +1);

    int futureHours = (tomorrow.difference(roundedHour)).inHours;
    for (int i = 1; i <= futureHours; i++) {
      DateTime futureHour = now.add(Duration(hours: i));
      futureHour = DateTime(futureHour.year, futureHour.month, futureHour.day, futureHour.hour);
      hourlyData.add(HourlyNicotineLevel(time: futureHour, level: 0.0));
    }

    //updates state w/ hourly data
    setState(() {
      this.nicotineSmokedThisHour = nicotineSmokedThisHour;
      this.nicotineSmokedToday = nicotineSmokedToday;
    });
  }

@override
Widget build(BuildContext context) {
  final cigaretteCounter = Provider.of<CigaretteCounter>(context);
  DateTime now = DateTime.now();

  return Scaffold(
    backgroundColor: Color.fromARGB(255, 79, 149, 240),
    appBar: AppBar(
      title: Text(
        'Plots',
        style: TextStyle(
          fontSize: 30,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color.fromARGB(255, 79, 149, 240),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Cigarettes smoked today: ${cigaretteCounter.cigarettesSmokedToday}/$threshold',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: (_cigarettesPerDay * 7 * 50.0),
                        child: NicotineChart(
                          NicotineChart.createSampleData(data),
                          animate: true,
                          registrationDate: registrationDate!,
                          cigarettesPerDay: _cigarettesPerDay,
                          //nicotineSmokedToday: nicotineSmokedToday,
                          dailyNicotineTarget: dailyNicotineTarget,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Slide horizontally to view more data',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3, //reduced hight
                    child: HourlyNicotineChart(
                      HourlyNicotineChart.createSampleData(hourlyData),
                      animate: true,
                      nicotineSmokedThisHour: nicotineSmokedThisHour,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Nicotine smoked today: ${nicotineSmokedToday.toStringAsFixed(1)} / ${dailyNicotineTarget.toStringAsFixed(1)} mg',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
  );
}
}
