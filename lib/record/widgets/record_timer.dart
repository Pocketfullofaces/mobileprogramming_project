import 'package:flutter/material.dart';
import '../record_format.dart';

class RecordTimer extends StatelessWidget {
  const RecordTimer({
    super.key,
    required this.elapsed,
    this.isPaused = false,
    this.onCollapse,
  });

  final Duration elapsed;
  final bool isPaused;
  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Perkecil',
            onPressed: onCollapse,
            icon: const Icon(
              Icons.close_fullscreen,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Semantics(
              label: 'Waktu ${formatClock(elapsed)}',
              excludeSemantics: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatClock(elapsed),
                  maxLines: 1,
                  style: TextStyle(
                    color: isPaused ? Colors.white54 : Colors.white,
                    fontSize: 76,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}