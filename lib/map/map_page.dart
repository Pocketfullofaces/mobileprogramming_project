import 'package:flutter/material.dart';
import 'services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _locationService = const LocationService();
  String _status = 'Checking permission...';
  String _position = '-';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final result = await _locationService.ensurePermission();
    if (!result.granted) {
      setState(() => _status = result.message ?? 'Permission denied');
      return;
    }

    setState(() => _status = 'Permission granted. Getting position...');

    final pos = await _locationService.currentPosition();
    setState(() {
      _status = 'Got position!';
      _position = 'Lat: ${pos.latitude}, Lng: ${pos.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Page (temp test)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 12),
            Text(_position),
          ],
        ),
      ),
    );
  }
}