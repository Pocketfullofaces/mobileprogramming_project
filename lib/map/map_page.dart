import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _initialCamera = CameraPosition(
    target: LatLng(-6.2088, 106.8456),
    zoom: 14,
  );

  final _locationService = const LocationService();

  GoogleMapController? _mapController;
  bool _permissionReady = false;
  bool _loadingLocation = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _prepareLocation();
  }

  Future<void> _prepareLocation() async {
    final permission = await _locationService.ensurePermission();
    if (!mounted) return;
    if (!permission.granted) {
      setState(() {
        _loadingLocation = false;
        _message = permission.message;
      });
      return;
    }

    setState(() {
      _permissionReady = true;
      _message = null;
    });

    if (mounted) setState(() => _loadingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            myLocationEnabled: _permissionReady,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          if (_loadingLocation)
            const Center(child: CircularProgressIndicator())
          else if (_message != null)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.paddingOf(context).top + 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .74),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _message!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}