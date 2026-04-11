import 'package:equatable/equatable.dart';

class PublicHolidayEntity extends Equatable {
  final String date;
  final String name;

  const PublicHolidayEntity({required this.date, required this.name});

  @override
  List<Object?> get props => [date, name];
}

class CalendarEntity extends Equatable {
  final int currentMonth;
  final String monthName;
  final int totalDays;
  final int holidays;
  final int weekends;
  final List<PublicHolidayEntity> publicHolidays;
  final int workingDaysLeft;

  const CalendarEntity({
    required this.currentMonth,
    required this.monthName,
    required this.totalDays,
    required this.holidays,
    required this.weekends,
    required this.publicHolidays,
    required this.workingDaysLeft,
  });

  @override
  List<Object?> get props => [
    currentMonth,
    monthName,
    totalDays,
    holidays,
    weekends,
    publicHolidays,
    workingDaysLeft,
  ];
}

class DashboardDataEntity extends Equatable {
  final int unSignedLeads;
  final int signedLeads;
  final int totalLeads;
  final int unVisitedLeads;
  final int visitedLeads;
  final CalendarEntity calendar;

  const DashboardDataEntity({
    required this.unSignedLeads,
    required this.signedLeads,
    required this.totalLeads,
    required this.unVisitedLeads,
    required this.visitedLeads,
    required this.calendar,
  });

  @override
  List<Object?> get props => [
    unSignedLeads,
    signedLeads,
    totalLeads,
    unVisitedLeads,
    visitedLeads,
    calendar,
  ];
}
