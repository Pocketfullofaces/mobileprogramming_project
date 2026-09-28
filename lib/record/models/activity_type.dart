import 'package:flutter/material.dart';

enum ActivityType {
  run('Run', Icons.directions_run, false),
  ride('Ride', Icons.directions_bike, true),
  walk('Walk', Icons.directions_walk, false),
  hike('Hike', Icons.hiking, false);

  const ActivityType(this.label, this.icon, this.usesSpeed);

  final String label;
  final IconData icon;
  final bool usesSpeed;
}