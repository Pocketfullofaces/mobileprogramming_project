import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'services/location_service.dart';
import 'widgets/filter_chip_row.dart';
import 'widgets/search_bar_widget.dart';

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
  final _searchController = TextEditingController();
  final _markers = <Marker>{};

  GoogleMapController? _mapController;
  bool _permissionReady = false;
  bool _loadingLocation = true;
  bool _tilted = false;
  bool _searching = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _prepareLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
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

  Future<void> _searchLocation(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searching = true;
      _message = null;
    });
    try {
      final results = await locationFromAddress(text);
      if (results.isEmpty) throw StateError('Lokasi tidak ditemukan.');
      final target = LatLng(results.first.latitude, results.first.longitude);
      setState(() {
        _markers
          ..removeWhere((marker) => marker.markerId.value == 'search-result')
          ..add(
            Marker(
              markerId: const MarkerId('search-result'),
              position: target,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
              infoWindow: InfoWindow(title: text),
            ),
          );
      });
      await _animateTo(target, zoom: 15);
    } catch (_) {
      if (mounted) setState(() => _message = 'Alamat tidak ditemukan.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _animateTo(
    LatLng target, {
    double? zoom,
    bool keepZoom = false,
  }) async {
    final controller = _mapController;
    if (controller == null) return;
    final currentZoom = keepZoom ? await controller.getZoomLevel() : null;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: zoom ?? currentZoom ?? 15,
          tilt: _tilted ? 55 : 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            myLocationEnabled: _permissionReady,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            top: MediaQuery.paddingOf(context).top + 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  onSubmitted: _searchLocation,
                  searching: _searching,
                ),
                const SizedBox(height: 10),
                const FilterChipRow(),
              ],
            ),
          ),
          if (_loadingLocation)
            const Center(child: CircularProgressIndicator())
          else if (_message != null)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.paddingOf(context).top + 136,
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