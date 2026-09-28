import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/route_point.dart';
import 'services/location_service.dart';
import 'widgets/filter_chip_row.dart';
import 'widgets/map_action_button.dart';
import 'widgets/route_info_card.dart';
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
  final _routePoints = <RoutePoint>[];

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSub;
  Timer? _timer;
  Position? _currentPosition;
  Position? _lastTrackedPosition;
  DateTime? _startedAt;
  DateTime? _pausedAt;
  Duration _elapsed = Duration.zero;
  Duration _pausedTotal = Duration.zero;
  double _distanceMeters = 0;
  bool _permissionReady = false;
  bool _loadingLocation = true;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _followUser = true;
  bool _cameraMoveByCode = false;
  bool _tilted = false;
  bool _searching = false;
  MapType _mapType = MapType.normal;
  String? _message;
  String? _summaryText;

  @override
  void initState() {
    super.initState();
    _prepareLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _positionSub?.cancel();
    _timer?.cancel();
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

    try {
      final current = await _locationService.currentPosition();
      if (!mounted) return;
      _handlePosition(current, animate: true);
    } catch (e) {
      if (mounted) setState(() => _message = 'Lokasi belum bisa dibaca.');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }

    await _positionSub?.cancel();
    _positionSub = _locationService.positionStream().listen(
      _handlePosition,
      onError: (_) {
        if (mounted) setState(() => _message = 'Stream lokasi terputus.');
      },
    );
  }

  void _handlePosition(Position position, {bool animate = false}) {
    final point = RoutePoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentPosition = position;
      _markers
        ..removeWhere((marker) => marker.markerId.value == 'current-location')
        ..add(
          Marker(
            markerId: const MarkerId('current-location'),
            position: point.latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
        );

      if (_isRecording && !_isPaused) {
        if (_lastTrackedPosition != null) {
          final delta = _locationService.distanceMeters(
            _lastTrackedPosition!,
            position,
          );
          if (delta >= 1) _distanceMeters += delta;
        }
        _lastTrackedPosition = position;
        _routePoints.add(point);
      }
    });

    if ((animate || _followUser) && _mapController != null) {
      _animateTo(point.latLng, keepZoom: true);
    }
  }

  void _startTracking() {
    final now = DateTime.now();
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _followUser = true;
      _startedAt = now;
      _pausedAt = null;
      _elapsed = Duration.zero;
      _pausedTotal = Duration.zero;
      _distanceMeters = 0;
      _routePoints.clear();
      _summaryText = null;
      _lastTrackedPosition = _currentPosition;
      if (_currentPosition != null) {
        _routePoints.add(
          RoutePoint(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            timestamp: now,
          ),
        );
      }
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final startedAt = _startedAt;
    if (startedAt == null || _isPaused) return;
    setState(() {
      _elapsed = DateTime.now().difference(startedAt) - _pausedTotal;
    });
  }

  void _pauseResumeTracking() {
    if (!_isRecording) return;
    setState(() {
      if (_isPaused) {
        if (_pausedAt != null) {
          _pausedTotal += DateTime.now().difference(_pausedAt!);
        }
        _pausedAt = null;
        _lastTrackedPosition = _currentPosition;
        _isPaused = false;
      } else {
        _pausedAt = DateTime.now();
        _isPaused = true;
      }
    });
  }

  void _stopTracking() {
    _timer?.cancel();
    final pace = _paceLabel();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _pausedAt = null;
      _summaryText =
          'Summary: ${(_distanceMeters / 1000).toStringAsFixed(2)} km, ${_formatDuration(_elapsed)}, pace $pace.';
    });
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
        _followUser = false;
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
    _cameraMoveByCode = true;
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

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  void _toggleTilt() {
    setState(() => _tilted = !_tilted);
    final position = _currentPosition;
    if (position != null) {
      _animateTo(LatLng(position.latitude, position.longitude), keepZoom: true);
    }
  }

  void _recenter() {
    final position = _currentPosition;
    if (position == null) {
      setState(() => _message = 'Lokasi kamu belum tersedia.');
      return;
    }
    setState(() => _followUser = true);
    _animateTo(LatLng(position.latitude, position.longitude), keepZoom: true);
  }

  Set<Polyline> get _polylines {
    if (_routePoints.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('live-route'),
        points: _routePoints.map((point) => point.latLng).toList(),
        color: const Color(0xFFFC4C02),
        width: 6,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  String _paceLabel() {
    final km = _distanceMeters / 1000;
    if (km <= 0 || _elapsed.inSeconds <= 0) return '--';
    final secondsPerKm = _elapsed.inSeconds / km;
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm % 60).round().toString().padLeft(2, '0');
    return '$minutes:$seconds /km';
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return value.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            myLocationEnabled: _permissionReady,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            mapType: _mapType,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              final position = _currentPosition;
              if (position != null) {
                _animateTo(
                  LatLng(position.latitude, position.longitude),
                  keepZoom: true,
                );
              }
            },
            onCameraMoveStarted: () {
              if (!_cameraMoveByCode && _followUser) {
                setState(() => _followUser = false);
              }
            },
            onCameraIdle: () => _cameraMoveByCode = false,
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
          Positioned(
            right: 16,
            bottom: 246 + bottomInset,
            child: Column(
              children: [
                MapActionButton(
                  icon: Icons.layers_outlined,
                  tooltip: 'Toggle layer',
                  onPressed: _toggleMapType,
                  active: _mapType == MapType.hybrid,
                ),
                MapActionButton(
                  icon: Icons.threed_rotation,
                  tooltip: 'Toggle 3D tilt',
                  onPressed: _toggleTilt,
                  active: _tilted,
                ),
                MapActionButton(
                  icon: Icons.my_location,
                  tooltip: 'Recenter',
                  onPressed: _recenter,
                  active: _followUser,
                ),
                MapActionButton(
                  icon: Icons.edit_location_alt_outlined,
                  tooltip: 'Draw route',
                  onPressed: () {
                    setState(() {
                      _message = 'Mode gambar rute manual belum diaktifkan.';
                    });
                  },
                ),
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: RouteInfoCard(
              distanceKm: _distanceMeters / 1000,
              elapsed: _elapsed,
              isRecording: _isRecording,
              isPaused: _isPaused,
              hasRoute: _routePoints.isNotEmpty,
              summaryText: _summaryText,
              onStart: _startTracking,
              onPauseResume: _pauseResumeTracking,
              onStop: _stopTracking,
            ),
          ),
        ],
      ),
    );
  }
}