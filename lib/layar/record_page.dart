import 'dart:async';
import 'package:flutter/material.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  double _distanceKm = 0;
  bool _isRunning = false;
  String _activityType = 'Lari';

  static const List<String> _activityTypes = ['Lari', 'Sepeda', 'Jalan Kaki'];

  double get _simulatedSpeedPerSecond {
    switch (_activityType) {
      case 'Sepeda':
        return 20 / 3600;
      case 'Jalan Kaki':
        return 5 / 3600;
      default:
        return 10 / 3600;
    }
  }

  void _startPause() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      setState(() => _isRunning = true);
    }
  }

  void _tick() {
    setState(() {
      _elapsed += const Duration(seconds: 1);
      _distanceKm += _simulatedSpeedPerSecond;
    });
  }

  void _stop() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktivitas Selesai'),
        content: Text(
          'Jenis: $_activityType\n'
          'Waktu: ${_formatDuration(_elapsed)}\n'
          'Jarak: ${_distanceKm.toStringAsFixed(2)} km\n'
          'Pace: ${_formatPace()}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _elapsed = Duration.zero;
                _distanceKm = 0;
                _isRunning = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String _formatPace() {
    if (_distanceKm == 0) return '-';
    final paceSeconds = _elapsed.inSeconds / _distanceKm;
    final minutes = (paceSeconds / 60).floor();
    final seconds = (paceSeconds % 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Activity')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            SegmentedButton<String>(
              segments: _activityTypes
                  .map((type) => ButtonSegment(value: type, label: Text(type)))
                  .toList(),
              selected: {_activityType},
              onSelectionChanged: _isRunning
                  ? null
                  : (selection) {
                      setState(() => _activityType = selection.first);
                    },
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LiveStat(label: 'Waktu', value: _formatDuration(_elapsed)),
                _LiveStat(label: 'Jarak', value: '${_distanceKm.toStringAsFixed(2)} km'),
                _LiveStat(label: 'Pace', value: _formatPace()),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'startPause',
                  onPressed: _startPause,
                  backgroundColor: _isRunning ? Colors.orange : Colors.green,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'stop',
                  onPressed: _elapsed == Duration.zero ? null : _stop,
                  backgroundColor: Colors.red,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveStat extends StatelessWidget {
  final String label;
  final String value;

  const _LiveStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}