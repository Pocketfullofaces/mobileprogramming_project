import 'package:flutter/material.dart';

class RecordSettingsSheet extends StatelessWidget {
  const RecordSettingsSheet({
    super.key,
    required this.audioCues,
    required this.onAudioCuesChanged,
    required this.autoPause,
    required this.onAutoPauseChanged,
  });

  final bool audioCues;
  final ValueChanged<bool> onAudioCuesChanged;
  final bool autoPause;
  final ValueChanged<bool> onAutoPauseChanged;

  static Future<void> show(
    BuildContext context, {
    required bool audioCues,
    required ValueChanged<bool> onAudioCuesChanged,
    required bool autoPause,
    required ValueChanged<bool> onAutoPauseChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1D1D1B),
      showDragHandle: true,
      builder: (_) => RecordSettingsSheet(
        audioCues: audioCues,
        onAudioCuesChanged: onAudioCuesChanged,
        autoPause: autoPause,
        onAutoPauseChanged: onAutoPauseChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              value: audioCues,
              onChanged: onAudioCuesChanged,
              title: const Text(
                'Audio cues',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text('Bunyi klik setiap 1 km'),
            ),
            SwitchListTile(
              value: autoPause,
              onChanged: onAutoPauseChanged,
              title: const Text(
                'Auto-pause',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text('Jeda otomatis saat berhenti ~10 detik'),
            ),
            const ListTile(
              enabled: false,
              title: Text('Live segments'),
              subtitle: Text('Belum tersedia'),
            ),
          ],
        ),
      ),
    );
  }
}