import 'dart:math';
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
  int _cigarettesPerDay = 0;
  int threshold = 0;
  bool isLoading = true;




  @override
  void initState() {
    super.initState();
    _loadRegistrationData();
  }




  Future<void> _loadRegistrationData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usersData = prefs.getString('users');


      Map<String, dynamic> users = usersData != null ? json.decode(usersData) : {};
      final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen:false);




      if (users.containsKey(widget.accountName)) {
        var userProfile = users[widget.accountName];
        String? dateStr = userProfile['registrationDate'];
        _cigarettesPerDay = userProfile['CigarettesPerDay'] ?? 0;
        threshold = _cigarettesPerDay; //threshold initialization




        if (dateStr != null) {
          registrationDate = DateTime.parse(dateStr);
        } else {
          registrationDate = DateTime.now();
        }




        // Calcola quanti giorni sono passati dalla registrazione
        if (registrationDate != null) {
          int daysSinceRegistration = DateTime.now().difference(registrationDate!).inDays;




          // Decrementa la soglia di 1 per ogni 7 giorni passati
          threshold -= (daysSinceRegistration ~/ 7);
          if (threshold < 0) threshold = 0; // La soglia non può andare sotto 0
        }


        await _generateChartData(users);
        await _generateHourlyData();
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




    if (registrationDate != null) {
      DateTime startDate = registrationDate!;
      data = [];
      DateTime now = DateTime.now();




      int totalCigarettes = 0;
      //int daysToGenerate = _cigarettesPerDay*7;




      int daysToGenerate = now.difference(startDate).inDays + 1;




      for (int i = 0; i < daysToGenerate; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String dateKey = "${widget.accountName}_cigarettes_${currentDate.year}${currentDate.month}${currentDate.day}";
        double cigarettes = dailyCounts[dateKey]?.toDouble() ?? 0.0;
        totalCigarettes += cigarettes.toInt();




        data.add(NicotineLevel(date: currentDate, level: cigarettes));
      }


      final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen: false);
      data.add(NicotineLevel(date: now, level: cigaretteCounter.cigarettesSmokedToday.toDouble()));
      totalCigarettes += cigaretteCounter.cigarettesSmokedToday;


      int futureDays = totalCigarettes * 7;




      for (int i = 1; i <= futureDays; i++) {
        DateTime futureDate = now.add(Duration(days: i));
        data.add(NicotineLevel(date: futureDate, level: 0.0));
      }




      setState(() {});
    }
  }




  Future<void> _generateHourlyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    hourlyData = [];
    // Ottieni il provider del contatore delle sigarette
    final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen: false);


    // Recupera i dati orari delle sigarette e della nicotina
    //CONSIDERA L'IDEA DI METTERE List<int> e List<double>, ma devi modificare tutto il resto in pratica
    int hourlyCigarettesSmoked = cigaretteCounter.hourlyCigarettesSmoked;
    double hourlyNicotine = cigaretteCounter.hourlyNicotine;


    // Mantieni un registro cumulativo delle curve
    Map<DateTime, double> cumulativeNicotineLevels = {};




    // Ottieni il tipo di sigaretta e il livello di nicotina salvati per l'utente corrente
    //String? usersData = prefs.getString('users');
    //Map<String, dynamic> users = usersData != null ? json.decode(usersData) : {};




    //double nicotinePerCigarette = 1.0; // Valore predefinito nel caso non ci siano dati
    //if (users.containsKey(widget.accountName)) {
    //  var userProfile = users[widget.accountName];
    //  nicotinePerCigarette = userProfile['Nicotine'] ?? 1.0;
    //}




    Set<String> keys = prefs.getKeys();




    // Raccogli tutte le sigarette fumate dal salvataggio
    for (String key in keys) {
      if (key.startsWith("${widget.accountName}_cigarette_")) {
        DateTime timestamp = DateTime.parse(key.split('_')[2]);
        DateTime hour = DateTime(timestamp.year, timestamp.month, timestamp.day, timestamp.hour);




        // Aggiungi la curva di nicotina per questa sigaretta al registro cumulativo
        for (int i = 0; i < 24; i++) {
          DateTime currentHour = hour.add(Duration(hours: i));
          double nicotineLevel = hourlyNicotine / pow(2, i * 60 / 90); // Effetto nel tempo


          if (cumulativeNicotineLevels.containsKey(currentHour)) {
            cumulativeNicotineLevels[currentHour] = cumulativeNicotineLevels[currentHour]! + nicotineLevel;
          } else {
            cumulativeNicotineLevels[currentHour] = nicotineLevel;
          }
        }
      }
    }




    // Aggiungi l'ultima sigaretta appena fumata
    //final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen: false);
    if (cigaretteCounter.hourlyCigarettesSmoked > 0) {
      DateTime lastCigaretteTime = now;
      DateTime hour = DateTime(lastCigaretteTime.year, lastCigaretteTime.month, lastCigaretteTime.day, lastCigaretteTime.hour);




      // Aggiorna solo le ore successive alla nuova sigaretta
      for (int i = 0; i < 24; i++) {
        DateTime currentHour = hour.add(Duration(hours: i));
        double nicotineLevel = hourlyNicotine / pow(2, i * 60 / 90);
        nicotineLevel *= cigaretteCounter.hourlyCigarettesSmoked;




        if (cumulativeNicotineLevels.containsKey(currentHour)) {
          cumulativeNicotineLevels[currentHour] = cumulativeNicotineLevels[currentHour]! + nicotineLevel;
        } else {
          cumulativeNicotineLevels[currentHour] = nicotineLevel;
        }
      }
    }




    // Ora converte cumulativeNicotineLevels in hourlyData
    for (int i = 0; i < 24; i++) {
      DateTime hour = startOfDay.add(Duration(hours: i));
      double nicotineLevel = cumulativeNicotineLevels[hour] ?? 0.0;




      hourlyData.add(HourlyNicotineLevel(time: hour, level: nicotineLevel));
    }




    setState(() {});




    //PROVA PER VALIDAZIONE- IN CASO TOGLIERE
    for (var hourly in hourlyData) {
      print('Ora: ${hourly.time}, Livello di nicotina: ${hourly.level}');
    }




  }


  @override
  Widget build(BuildContext context) {
    final cigaretteCounter = Provider.of<CigaretteCounter>(context);
    DateTime now = DateTime.now();


    return Scaffold(
      appBar: AppBar(title: Text('Plots')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                          style: TextStyle(fontSize: 20),
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
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Spazio tra i grafici
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3, // Altezza ridotta
                    child: HourlyNicotineChart(
                      HourlyNicotineChart.createSampleData(hourlyData),
                      animate: true,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
