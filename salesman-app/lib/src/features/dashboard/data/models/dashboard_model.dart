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
      currentMonth: map['currentMonth'] as int,
      monthName: map['monthName'] as String,
      totalDays: map['totalDays'] as int,
      holidays: map['holidays'] as int,
      weekends: map['weekends'] as int,
      publicHolidays: (map['publicHolidays'] as List<dynamic>)
          .map((e) => PublicHolidayModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      workingDaysLeft: map['workingDaysLeft'] as int,
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
      unSignedLeads: map['unSignedLeads'] as int,
      signedLeads: map['signedLeads'] as int,
      totalLeads: map['totalLeads'] as int,
      unVisitedLeads: map['unVisitedLeads'] as int,
      visitedLeads: map['visitedLeads'] as int,
      calendar: CalendarModel.fromMap(map['calender'] as Map<String, dynamic>),
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
