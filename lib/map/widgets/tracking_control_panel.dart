import 'package:flutter/material.dart';

class TrackingControlPanel extends StatelessWidget {
  const TrackingControlPanel({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.hasRoute,
    required this.onStart,
    required this.onPauseResume,
    required this.onStop,
  });

  final bool isRecording;
  final bool isPaused;
  final bool hasRoute;
  final VoidCallback onStart;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    if (!isRecording) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow),
          label: Text(hasRoute ? 'Start Again' : 'Start'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPauseResume,
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(isPaused ? 'Resume' : 'Pause'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: onStop,
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
          ),
        ),
      ],
    );
  }
}
