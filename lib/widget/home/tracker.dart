import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapTrackerWidget extends StatefulWidget {
  const MapTrackerWidget({super.key});

  @override
  State<MapTrackerWidget> createState() => _MapTrackerWidgetState();
}

class _MapTrackerWidgetState extends State<MapTrackerWidget> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _points = [];
  LatLng? _currentLocation;
  double _distanceKm = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Aktifkan layanan lokasi terlebih dahulu';
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Izin lokasi ditolak';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Izin lokasi ditolak permanen, ubah dari pengaturan';
        _isLoading = false;
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _points.add(_currentLocation!);
      _isLoading = false;
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    final newLocation = LatLng(position.latitude, position.longitude);

    if (_points.isNotEmpty) {
      final last = _points.last;
      _distanceKm += Geolocator.distanceBetween(
            last.latitude,
            last.longitude,
            newLocation.latitude,
            newLocation.longitude,
          ) /
          1000;
    }

    setState(() {
      _currentLocation = newLocation;
      _points.add(newLocation);
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFC4C02)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentLocation!,
            zoom: 17,
          ),
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          polylines: {
            Polyline(
              polylineId: const PolylineId('route'),
              points: _points,
              width: 4,
              color: const Color(0xFFFC4C02),
            ),
          },
          markers: {
            Marker(
              markerId: const MarkerId('current'),
              position: _currentLocation!,
            ),
          },
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_distanceKm.toStringAsFixed(2)} km',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
