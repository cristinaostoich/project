import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CigaretteCounter with ChangeNotifier {
  int _cigarettesSmokedToday = 0;
  double _nicotineSmokedToday = 0.0;
  int _hourlyCigarettesSmoked = 0;
  double _hourlyNicotine = 0.0;
  int _dailyCigarettesCount = 0;
  double _dailyNicotine = 0.0;
  DateTime _lastHourlyUpdate = DateTime.now();
  //DateTime _lastHourlyUpdateDays = DateTime.now();

  int get cigarettesSmokedToday => _cigarettesSmokedToday;
  double get nicotineSmokedToday => _nicotineSmokedToday;
  int get hourlyCigarettesSmoked => _hourlyCigarettesSmoked;
  double get hourlyNicotine => _hourlyNicotine;
  int get dailyCigarettesCount => _dailyCigarettesCount;
  double get dailyNicotine => _dailyNicotine;

  void incrementCigarettes() {
    _cigarettesSmokedToday++;
    notifyListeners();
  }

  void setCigarettes(int count) {
    _cigarettesSmokedToday = count;
    notifyListeners();
  }

  void setDailyCigarettes(int count) {
    _dailyCigarettesCount = count;
    notifyListeners();
  }

  void setHourlyCigarettes(int count) {
    _hourlyCigarettesSmoked = count;
    notifyListeners();
  }

  void setHourlyNicotine(double nicotine) {
    _hourlyNicotine = nicotine;
    notifyListeners();
  }

   void setDailyNicotine(double nicotine) {
      _dailyNicotine = nicotine;
    notifyListeners();
  }


  void updateHourlyCount(int count, double nicotine) async {
    DateTime now = DateTime.now();
    if (now.difference(_lastHourlyUpdate).inHours == 0) { /////////QUI ERA != 0 MA NON HA SENSO
      _hourlyCigarettesSmoked = count;
      _hourlyNicotine = nicotine;
      _lastHourlyUpdate = now;
      await _saveHourlyData(count, nicotine, now); // Save the updated hourly data
    } else {
      _hourlyCigarettesSmoked = 0;
      _hourlyNicotine = 0.0;
      await _saveHourlyData(0, 0.0, now); // Save the updated hourly data, qui erano (count, nicotine, now)
    }
    notifyListeners();
  }

  void updateDailyCount(int count, double nicotine) async {
    DateTime now = DateTime.now();
    if (now.difference(_lastHourlyUpdate).inDays == 0) {
      _dailyCigarettesCount = count;
      _dailyNicotine = nicotine;
      _lastHourlyUpdate = now;
    } else {
      _dailyCigarettesCount = 0;
      _dailyNicotine = 0.0;
    }
    notifyListeners();
  }

  Future<void> _saveHourlyData(int count, double nicotine, DateTime now) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = "${now.year}${now.month}${now.day}${now.hour}";
    Map<String, double> hourlyData = {};
    // Load existing data if available
    String? existingData = prefs.getString('hourlyData');
    if (existingData != null) {
    try {
      Map<String, dynamic> jsonData = json.decode(existingData);
      
      // Each value has to be of type double
      jsonData.forEach((k, v) {
        if (v is num) {
          hourlyData[k] = v.toDouble();
        }
      });
    } catch (e) {
      print("Errore durante il parsing dei dati: $e");
    }
  }
    hourlyData[key] = nicotine; // Save nicotine level
    await prefs.setString('hourlyData', json.encode(hourlyData));
  }

  Future<void> resetCountersIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    DateTime lastUpdate = DateTime.parse(prefs.getString('lastHourlyUpdate') ?? now.toIso8601String());

    if (now.difference(lastUpdate).inHours != 0) {
      // Reset hourly counters
      _hourlyCigarettesSmoked = 0;
      _hourlyNicotine = 0.0;
      _lastHourlyUpdate = now;

      await prefs.setString('lastHourlyUpdate', now.toIso8601String());
      notifyListeners();
    }
  }

}
