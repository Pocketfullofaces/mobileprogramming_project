import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

  Future<LocationPermissionResult> ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return const LocationPermissionResult(
        granted: false,
        message: 'Location service belum aktif, nyalakan GPS dulu.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationPermissionResult(
        granted: false,
        message: 'Izin lokasi ditolak, izinkan lokasi untuk melihat lokasi',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationPermissionResult(
        granted: false,
        message:
            'izin lokasi ditolak permanen, buka settings dan izinkan lokasi',
      );
    }

    return const LocationPermissionResult(granted: true);
  }

  Future<Position> currentPosition() => Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );

  Stream<Position> positionStream() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 4,
    ),
  );

  double distanceMeters(Position a, Position b) => Geolocator.distanceBetween(
    a.latitude,
    a.longitude,
    b.latitude,
    b.longitude,
  );
}

class LocationPermissionResult {
  const LocationPermissionResult({required this.granted, this.message});

  final bool granted;
  final String? message;
}
