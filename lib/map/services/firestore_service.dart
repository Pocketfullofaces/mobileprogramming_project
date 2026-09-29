import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/route_point.dart';

class MapFirestoreService {
  MapFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> saveActivity({
    required String userId,
    required double distanceKm,
    required Duration duration,
    required List<RoutePoint> routePoints,
  }) {
    return _firestore.collection('trackedActivities').add({
      'userId': userId,
      'distanceKm': distanceKm,
      'durationSeconds': duration.inSeconds,
      'routePoints': routePoints.map((point) => point.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
