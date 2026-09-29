import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const _orange = Color(0xFFFC4C02);

class RecordRoutePicker extends StatefulWidget {
  const RecordRoutePicker({super.key, this.initialPoints = const []});

  final List<LatLng> initialPoints;

  @override
  State<RecordRoutePicker> createState() => _RecordRoutePickerState();
}

class _RecordRoutePickerState extends State<RecordRoutePicker> {
  late final List<LatLng> _points = List.of(widget.initialPoints);

  void _addPoint(LatLng point) => setState(() => _points.add(point));

  void _undo() {
    if (_points.isEmpty) return;
    setState(() => _points.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tandai Rute'),
        actions: [
          IconButton(
            tooltip: 'Hapus titik terakhir',
            onPressed: _points.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _points.isNotEmpty
                  ? _points.first
                  : const LatLng(-6.2, 106.816666),
              zoom: 15,
            ),
            onTap: _addPoint,
            markers: {
              for (var i = 0; i < _points.length; i++)
                Marker(markerId: MarkerId('point_$i'), position: _points[i]),
            },
            polylines: {
              if (_points.length > 1)
                Polyline(
                  polylineId: const PolylineId('planned_route'),
                  points: _points,
                  width: 4,
                  color: _orange,
                ),
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _points.isEmpty
                            ? 'Ketuk peta untuk menandai titik rute.'
                            : '${_points.length} titik ditandai.',
                      ),
                    ),
                    TextButton(
                      onPressed: _points.length < 2
                          ? null
                          : () => Navigator.pop(context, _points),
                      child: const Text('Selesai'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}