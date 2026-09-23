import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePoint {
  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LatLng get latLng => LatLng(latitude, longitude);

  Map<String, dynamic> toMap() => {
    'lat': latitude,
    'lng': longitude,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory RoutePoint.fromMap(Map<String, dynamic> data) {
    final timestamp = data['timestamp'];
    return RoutePoint(
      latitude: (data['lat'] as num).toDouble(),
      longitude: (data['lng'] as num).toDouble(),
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }
}
