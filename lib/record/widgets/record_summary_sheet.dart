import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/social_service.dart' show friendlyError;
import '../models/activity_type.dart';
import '../record_format.dart';

enum RecordSummaryResult { saved, resume, discard }

class RecordSummary {
  const RecordSummary({
    required this.type,
    required this.distanceKm,
    required this.duration,
    this.laps = const [],
  });

  final ActivityType type;
  final double distanceKm;
  final Duration duration;
  final List<Duration> laps;

  double get roundedKm => double.parse(distanceKm.toStringAsFixed(2));

  int get minutes => math.max(1, (duration.inSeconds / 60).round());

  bool get canPublish => roundedKm > 0 && minutes <= 1440;
}

class RecordSummarySheet extends StatefulWidget {
  const RecordSummarySheet({
    super.key,
    required this.summary,
    required this.onSave,
  });

  final RecordSummary summary;

  final Future<void> Function(String caption) onSave;

  static Future<RecordSummaryResult?> show(
    BuildContext context, {
    required RecordSummary summary,
    required Future<void> Function(String caption) onSave,
  }) {
    return showModalBottomSheet<RecordSummaryResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF1D1D1B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RecordSummarySheet(summary: summary, onSave: onSave),
    );
  }

  @override
  State<RecordSummarySheet> createState() => _RecordSummarySheetState();
}

class _RecordSummarySheetState extends State<RecordSummarySheet> {
  final _caption = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSave(_caption.text);
      if (mounted) Navigator.pop(context, RecordSummaryResult.saved);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = friendlyError(e);
          _busy = false;
        });
      }
    }
  }

  Future<void> _discard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buang aktivitas?'),
        content: const Text('Rekaman ini akan dihapus dan tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Buang'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.pop(context, RecordSummaryResult.discard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final meters = summary.distanceKm * 1000;
    final usesSpeed = summary.type.usesSpeed;
    final average = usesSpeed
        ? formatSpeed(meters, summary.duration)
        : formatPace(meters, summary.duration);

    return PopScope(
      canPop: !_busy,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      summary.type.icon,
                      color: const Color(0xFFFC4C02),
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${summary.type.label} selesai',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'Distance',
                        value: '${summary.distanceKm.toStringAsFixed(2)} km',
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Time',
                        value: formatClock(summary.duration),
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: usesSpeed ? 'Avg speed' : 'Avg pace',
                        value: average == null
                            ? '--'
                            : (usesSpeed ? '$average km/h' : '$average /km'),
                      ),
                    ),
                  ],
                ),
                if (summary.laps.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${summary.laps.length} lap tercatat',
                    style: const TextStyle(color: Color(0xFFBDBDBD)),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: _caption,
                  enabled: !_busy,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 2000,
                  decoration: const InputDecoration(
                    labelText: 'Ceritakan aktivitasmu (opsional)',
                  ),
                ),
                if (!summary.canPublish)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Aktivitas belum bisa dibagikan karena jarak masih 0 km. '
                      'Pastikan GPS aktif dan kamu sudah bergerak.',
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_busy || !summary.canPublish) ? null : _save,
                    child: Text(_busy ? 'Menyimpan…' : 'Simpan & bagikan'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.pop(
                                context,
                                RecordSummaryResult.resume,
                              ),
                        child: const Text('Lanjutkan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: _busy ? null : _discard,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                        child: const Text('Buang'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}