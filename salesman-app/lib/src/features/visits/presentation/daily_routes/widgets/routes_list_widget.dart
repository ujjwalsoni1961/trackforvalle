import 'package:flutter/material.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_entity.dart';
import 'package:track/src/features/visits/presentation/daily_routes/widgets/route_card.dart';

class DailyRoutesListWidget extends StatelessWidget {
  final List<DailyRoutesEntity> routes;

  const DailyRoutesListWidget({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RouteCard(route: route, showExtraButtons: false, index: index),
        );
      },
    );
  }
}
