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

class LeadStatusCountEntity extends Equatable {
  final String status;
  final int count;
  final String color;

  const LeadStatusCountEntity({
    required this.status,
    required this.count,
    required this.color,
  });

  @override
  List<Object?> get props => [status, count, color];
}

class RecentActivityEntity extends Equatable {
  final int visitId;
  final String leadName;
  final String status;
  final String date;
  final String? notes;

  const RecentActivityEntity({
    required this.visitId,
    required this.leadName,
    required this.status,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [visitId, leadName, status, date, notes];
}

class DashboardDataEntity extends Equatable {
  final int unSignedLeads;
  final int signedLeads;
  final int totalLeads;
  final int unVisitedLeads;
  final int visitedLeads;
  final CalendarEntity calendar;
  final int todaysVisits;
  final int conversionRate;
  final List<LeadStatusCountEntity> leadsByStatus;
  final List<RecentActivityEntity> recentActivity;

  const DashboardDataEntity({
    required this.unSignedLeads,
    required this.signedLeads,
    required this.totalLeads,
    required this.unVisitedLeads,
    required this.visitedLeads,
    required this.calendar,
    this.todaysVisits = 0,
    this.conversionRate = 0,
    this.leadsByStatus = const [],
    this.recentActivity = const [],
  });

  @override
  List<Object?> get props => [
    unSignedLeads,
    signedLeads,
    totalLeads,
    unVisitedLeads,
    visitedLeads,
    calendar,
    todaysVisits,
    conversionRate,
    leadsByStatus,
    recentActivity,
  ];
}
