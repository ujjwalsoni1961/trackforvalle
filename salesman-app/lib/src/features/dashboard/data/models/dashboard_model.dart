import 'package:track/src/features/dashboard/domain/entities/dashboard_entity.dart';

class PublicHolidayModel extends PublicHolidayEntity {
  const PublicHolidayModel({required super.date, required super.name});

  factory PublicHolidayModel.fromMap(Map<String, dynamic> map) {
    return PublicHolidayModel(
      date: map['date'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': date, 'name': name};
  }
}

class CalendarModel extends CalendarEntity {
  const CalendarModel({
    required super.currentMonth,
    required super.monthName,
    required super.totalDays,
    required super.holidays,
    required super.weekends,
    required super.publicHolidays,
    required super.workingDaysLeft,
  });

  factory CalendarModel.fromMap(Map<String, dynamic> map) {
    return CalendarModel(
      currentMonth: (map['currentMonth'] as num?)?.toInt() ?? 0,
      monthName: (map['monthName'] as String?) ?? '',
      totalDays: (map['totalDays'] as num?)?.toInt() ?? 0,
      holidays: (map['holidays'] as num?)?.toInt() ?? 0,
      weekends: (map['weekends'] as num?)?.toInt() ?? 0,
      publicHolidays: ((map['publicHolidays'] as List<dynamic>?) ?? [])
          .map((e) => PublicHolidayModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      workingDaysLeft: (map['workingDaysLeft'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentMonth': currentMonth,
      'monthName': monthName,
      'totalDays': totalDays,
      'holidays': holidays,
      'weekends': weekends,
      'publicHolidays': publicHolidays
          .map((e) => (e as PublicHolidayModel).toMap())
          .toList(),
      'workingDaysLeft': workingDaysLeft,
    };
  }
}

class DashboardDataModel extends DashboardDataEntity {
  const DashboardDataModel({
    required super.unSignedLeads,
    required super.signedLeads,
    required super.totalLeads,
    required super.unVisitedLeads,
    required super.visitedLeads,
    required super.calendar,
  });

  factory DashboardDataModel.fromMap(Map<String, dynamic> map) {
    return DashboardDataModel(
      unSignedLeads: (map['unSignedLeads'] as num?)?.toInt() ?? 0,
      signedLeads: (map['signedLeads'] as num?)?.toInt() ?? 0,
      totalLeads: (map['totalLeads'] as num?)?.toInt() ?? 0,
      unVisitedLeads: (map['unVisitedLeads'] as num?)?.toInt() ?? 0,
      visitedLeads: (map['visitedLeads'] as num?)?.toInt() ?? 0,
      calendar: CalendarModel.fromMap(
        (map['calender'] ?? map['calendar']) as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unSignedLeads': unSignedLeads,
      'signedLeads': signedLeads,
      'totalLeads': totalLeads,
      'unVisitedLeads': unVisitedLeads,
      'visitedLeads': visitedLeads,
      'calender': (calendar as CalendarModel).toMap(),
    };
  }
}
