import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CigaretteCounter with ChangeNotifier {
  int _cigarettesSmokedToday = 0;
  double _nicotineSmokedToday = 0.0;
  int _hourlyCigarettesSmoked = 0;
  double _hourlyNicotine = 0.0;
  int _dailyCigarettesCount = 0;
  double _dailyNicotine = 0.0;
  DateTime _lastHourlyUpdate = DateTime.now();

  int get cigarettesSmokedToday => _cigarettesSmokedToday;
  double get nicotineSmokedToday => _nicotineSmokedToday;
  int get hourlyCigarettesSmoked => _hourlyCigarettesSmoked;
  int get dailyCigarettesCount => _dailyCigarettesCount;
  double get dailyNicotine => _dailyNicotine;
  double get hourlyNicotine => _hourlyNicotine;

  void incrementCigarettes() {
    _cigarettesSmokedToday++;
    _dailyCigarettesCount++;
    _hourlyCigarettesSmoked++;
    notifyListeners();
  }

  void setCigarettes(int count) {
    _cigarettesSmokedToday = count;
    notifyListeners();
  }

  void setHourlyCigarettes(int count) {
    _hourlyCigarettesSmoked = count;
    notifyListeners();
  }

  void setDailyCigarettes(int count) {
    _dailyCigarettesCount = count;
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
    if (now.difference(_lastHourlyUpdate).inHours == 0) {
      _hourlyCigarettesSmoked = count;
      _hourlyNicotine = nicotine;
      _lastHourlyUpdate = now;
    } else {
      _hourlyCigarettesSmoked = 0;
      _hourlyNicotine = 0.0;
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


  //////  posso togliere o questo o quello du profilePage mi sembra che sia, si chiama checkAndReset...
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
