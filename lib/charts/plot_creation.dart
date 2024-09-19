import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;


class NicotineLevel {
  final DateTime date;
  final double level;

  NicotineLevel({required this.date, required this.level});
}

class NicotineChart extends StatelessWidget {
  final List<charts.Series<NicotineLevel, DateTime>> seriesList;
  final bool animate;
  final DateTime registrationDate;
  final int cigarettesPerDay;
  final double nicotineSmokedToday;
  final double dailyNicotineTarget;


  NicotineChart(
    this.seriesList, {
    this.animate = false,
    required this.registrationDate,
    required this.cigarettesPerDay,
    required this.nicotineSmokedToday,
    required this.dailyNicotineTarget,
  });


  @override
  Widget build(BuildContext context) {

    DateTime fixedStartDate =
        registrationDate.subtract(Duration(days: 1));
    DateTime fixedEndDate = registrationDate
        .add(Duration(days: cigarettesPerDay * 7));


    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'dd', // Formatta i giorni sull'asse X
            transitionFormat: 'dd MMM',
          ),
        ),
        tickProviderSpec: charts.DayTickProviderSpec(increments: [1]), // Increments day by day
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 14,
            color: charts.MaterialPalette.white,
          ),
          lineStyle: charts.LineStyleSpec(
            color: charts.MaterialPalette.white,
          ),
          axisLineStyle: charts.LineStyleSpec(
            color: charts.MaterialPalette.white,
          ),
        ),
        // sets x-axis on registration date
        viewport: charts.DateTimeExtents(
          start: fixedStartDate,
          end: fixedEndDate,
        ),
      ),
      defaultRenderer: charts.BarRendererConfig<DateTime>(
        groupingType: charts.BarGroupingType.grouped,
        cornerStrategy: const charts.ConstCornerStrategy(20),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredTickCount: 10),
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 14,
            color: charts.MaterialPalette.white,
          ),
          lineStyle: charts.LineStyleSpec(
            color: charts.MaterialPalette.white,
        ),
      ),
      ),
    );
  }


  // creates sample data
  static List<charts.Series<NicotineLevel, DateTime>> createSampleData(List<NicotineLevel> data) {
    return [
      charts.Series<NicotineLevel, DateTime>(
        id: 'Nicotine Level',
        colorFn: (_, __) => charts.MaterialPalette.white,
        domainFn: (NicotineLevel levels, _) => DateTime(levels.date.year, levels.date.month, levels.date.day), //ignores hours
        measureFn: (NicotineLevel levels, _) => levels.level,
        data: data,
      )
    ];
  }
}


class HourlyNicotineLevel {
  final DateTime time;
  double level;

  HourlyNicotineLevel({required this.time, required this.level});
}


class HourlyNicotineChart extends StatelessWidget {
  final List<charts.Series<HourlyNicotineLevel, DateTime>> seriesList;
  final bool animate;
  final double nicotineSmokedThisHour;

  HourlyNicotineChart(
    this.seriesList, {
    this.animate = false,
    required this.nicotineSmokedThisHour,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //nicotine chart
        Expanded(
          child: charts.TimeSeriesChart(
            seriesList,
            animate: animate,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
            domainAxis: charts.DateTimeAxisSpec(
              tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                hour: charts.TimeFormatterSpec(
                  format: 'HH',
                  transitionFormat: 'HH',
                ),
              ),
              tickProviderSpec: charts.StaticDateTimeTickProviderSpec(
                List.generate(12, (i) {
                  return charts.TickSpec<DateTime>(
                    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, i*2),
                    label: (i*2).toString().padLeft(2, '0'),
                  );
                }),
              ),
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 14,
                  color: charts.MaterialPalette.white,
                ),
                lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.white,
                ),
                axisLineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.white,
                ),
              ),
            ),
            defaultRenderer: charts.BarRendererConfig<DateTime>(
              groupingType: charts.BarGroupingType.grouped,
              cornerStrategy: const charts.ConstCornerStrategy(20),
            ),
            primaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredTickCount: 10),
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: 14,
                  color: charts.MaterialPalette.white,
                ),
                lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.white,
              ),
            ),
            ),
            
          ),
        ),
      ],
    );
  }

  static List<charts.Series<HourlyNicotineLevel, DateTime>> createSampleData(List<HourlyNicotineLevel> data) {
    return [
      charts.Series<HourlyNicotineLevel, DateTime>(
        id: 'Hourly Nicotine Level',
        colorFn: (_, __) => charts.MaterialPalette.white,
        domainFn: (HourlyNicotineLevel levels, _) => DateTime(levels.time.year, levels.time.month, levels.time.day, levels.time.hour),
        measureFn: (HourlyNicotineLevel levels, _) => levels.level,
        data: data,
      )
    ];
  }
}
