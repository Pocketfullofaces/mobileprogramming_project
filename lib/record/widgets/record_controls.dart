import 'package:flutter/material.dart';

import '../models/activity_type.dart';

const _orange = Color(0xFFFC4C02);
const _runBackground = Color(0xFF4A2312);
const _greyBackground = Color(0xFF3A3A38);

class RecordControls extends StatelessWidget {
  const RecordControls({
    super.key,
    required this.type,
    required this.isRecording,
    required this.isPaused,
    required this.trackLaps,
    required this.onPickType,
    required this.onStartPause,
    required this.onFinish,
    required this.onLap,
    required this.onAddRoute,
    this.hasRoute = false,
  });

  final ActivityType type;
  final bool isRecording;
  final bool isPaused;
  final bool trackLaps;
  final VoidCallback onPickType;
  final VoidCallback onStartPause;
  final VoidCallback onFinish;
  final VoidCallback onLap;
  final VoidCallback onAddRoute;
  final bool hasRoute;

  @override
  Widget build(BuildContext context) {
    final showPause = isRecording && !isPaused;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleAction(
            label: type.label,
            icon: type.icon,
            background: _runBackground,
            iconColor: _orange,
            showCheck: true,
            onTap: isRecording ? null : onPickType,
          ),
          Tooltip(
            message: !isRecording
                ? 'Mulai'
                : (showPause ? 'Jeda' : 'Lanjutkan'),
            child: Material(
              color: _orange,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onStartPause,
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Icon(
                    showPause
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          _rightAction(),
        ],
      ),
    );
  }

  Widget _rightAction() {
    if (isRecording && isPaused) {
      return _CircleAction(
        label: 'Finish',
        icon: Icons.stop_rounded,
        background: _greyBackground,
        iconColor: Colors.white,
        onTap: onFinish,
      );
    }
    if (isRecording && trackLaps) {
      return _CircleAction(
        label: 'Lap',
        icon: Icons.flag_outlined,
        background: _greyBackground,
        iconColor: Colors.white,
        onTap: onLap,
      );
    }
    return _CircleAction(
      label: 'Add Route',
      icon: Icons.route,
      background: _greyBackground,
      iconColor: Colors.white,
      showCheck: hasRoute,
      onTap: isRecording ? null : onAddRoute,
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.showCheck = false,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: SizedBox(
        width: 88,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: background,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onTap,
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Icon(icon, size: 30, color: iconColor),
                      ),
                    ),
                  ),
                  if (showCheck)
                    const Positioned(top: -2, right: -2, child: _CheckBadge()),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: _orange, shape: BoxShape.circle),
      child: SizedBox(
        width: 20,
        height: 20,
        child: Icon(Icons.check, size: 14, color: Colors.white),
      ),
    );
  }
}

Future<ActivityType?> showActivityTypeSheet(
  BuildContext context, {
  required ActivityType selected,
}) {
  return showModalBottomSheet<ActivityType>(
    context: context,
    backgroundColor: const Color(0xFF1D1D1B),
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in ActivityType.values)
            ListTile(
              leading: Icon(
                option.icon,
                color: option == selected ? _orange : Colors.white,
              ),
              title: Text(option.label),
              trailing: option == selected
                  ? const Icon(Icons.check, color: _orange)
                  : null,
              onTap: () => Navigator.pop(sheetContext, option),
            ),
        ],
      ),
    ),
  );
}