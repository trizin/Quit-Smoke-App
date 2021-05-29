import 'package:quitsmoke/static/htimes.dart';

class Cigaratte {
  final DateTime startDate;
  final double pricePerCigaratte;
  final int dailyCigarattes;
  final String lang;

  double cigarattePerSecond;
  double moneyPerSecond;
  double toUp = 0;

  Cigaratte(
      {this.startDate,
      this.pricePerCigaratte,
      this.dailyCigarattes,
      this.lang}) {
    cigarattePerSecond = dailyCigarattes / (24 * 60 * 60.0);
    moneyPerSecond = cigarattePerSecond * pricePerCigaratte;
  }

  Duration calculatePassedTime() {
    DateTime now = DateTime.now();
    return now.difference(startDate);
  }

  double get getSavedMoney {
    return calculatePassedTime().inSeconds * moneyPerSecond;
  }

  double get getsavedCigarattes {
    return calculatePassedTime().inSeconds * cigarattePerSecond;
  }

  double get getdayPercentage {
    final now = DateTime.now();
    DateTime midnight =
        startDate.add(Duration(days: calculatePassedTime().inDays + 1));
    return 100 - (midnight.difference(now).inSeconds * 100 / (24 * 60 * 60));
  }

  Map get upcomingEvent {
    Duration maduration = calculatePassedTime();
    Map event;
    for (Map element in htimes) {
      if (element["time"].inSeconds > maduration.inSeconds) {
        event = element;
        return event;
      }
    }
    return {
      "id": "15",
      "time": Duration(days: 365 * 100),
    };
  }

  List<int> get generateDayItem {
    List<int> daylist = [];

    for (int i = calculatePassedTime().inDays - 2;
        i < calculatePassedTime().inDays + 5;
        i++) {
      if (i > 0) daylist.add(i);
    }
    for (int i = calculatePassedTime().inDays - 3; i < 0; i++) {
      daylist.add(i + 8);
    }

    return daylist;
  }
}

/* void main() {
  Cigaratte cigara = Cigaratte(
      dailyCigarattes: 20,
      pricePerCigaratte: 12,
      startDate: DateTime.now().subtract(Duration(days: 0, seconds: 500)));
  print(cigara.upcomingEvent);
}
 */
