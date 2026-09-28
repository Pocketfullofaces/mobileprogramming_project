import 'package:flutter/material.dart';

import 'tracking_control_panel.dart';

class RouteInfoCard extends StatelessWidget {
  const RouteInfoCard({
    super.key,
    required this.distanceKm,
    required this.elapsed,
    required this.isRecording,
    required this.isPaused,
    required this.hasRoute,
    required this.onStart,
    required this.onPauseResume,
    required this.onStop,
    this.summaryText,
  });

  final double distanceKm;
  final Duration elapsed;
  final bool isRecording;
  final bool isPaused;
  final bool hasRoute;
  final VoidCallback onStart;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;
  final String? summaryText;

  @override
  Widget build(BuildContext context) {
    final status = isRecording
        ? (isPaused ? 'Paused' : 'Recording...')
        : 'Current Location';
    return Material(
      color: const Color(0xFF171717),
      borderRadius: BorderRadius.circular(24),
      elevation: 10,
      shadowColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Current Route',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC4C02).withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Easy',
                    style: TextStyle(
                      color: Color(0xFFFF7A3D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(status, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 16),
            Row(
              children: [
                _Metric(
                  label: 'Distance',
                  value: '${distanceKm.toStringAsFixed(2)} km',
                ),
                _Metric(label: 'Elev.', value: '0 m'),
                _Metric(label: 'Duration', value: _formatDuration(elapsed)),
              ],
            ),
            if (summaryText != null) ...[
              const SizedBox(height: 12),
              Text(summaryText!, style: const TextStyle(color: Colors.white70)),
            ],
            const SizedBox(height: 16),
            TrackingControlPanel(
              isRecording: isRecording,
              isPaused: isPaused,
              hasRoute: hasRoute,
              onStart: onStart,
              onPauseResume: onPauseResume,
              onStop: onStop,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
