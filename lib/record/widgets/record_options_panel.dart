import 'package:flutter/material.dart';

class RecordOptionsPanel extends StatelessWidget {
  const RecordOptionsPanel({
    super.key,
    required this.trackLaps,
    required this.onTrackLapsChanged,
    required this.onShareLocation,
    required this.onAddSensor,
    required this.onSettings,
    this.shareLocationOn = false,
    this.sensorSubtitle,
  });

  final bool trackLaps;
  final ValueChanged<bool> onTrackLapsChanged;
  final VoidCallback onShareLocation;
  final VoidCallback onAddSensor;
  final VoidCallback onSettings;
  final bool shareLocationOn;

  final String? sensorSubtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              icon: Icons.share_location,
              title: 'Share live location',
              subtitle: shareLocationOn ? 'On' : 'Off',
              onTap: onShareLocation,
            ),
            const _OptionDivider(),
            _OptionTile(
              icon: Icons.refresh,
              title: 'Track laps',
              subtitle: 'Manually track lap times',
              onTap: () => onTrackLapsChanged(!trackLaps),
              trailing: Switch(value: trackLaps, onChanged: onTrackLapsChanged),
            ),
            const _OptionDivider(),
            _OptionTile(
              icon: Icons.monitor_heart_outlined,
              title: 'Add a sensor',
              subtitle: sensorSubtitle,
              onTap: onAddSensor,
            ),
            const _OptionDivider(),
            _OptionTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Audio cues, auto-pause, live segments',
              onTap: onSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionDivider extends StatelessWidget {
  const _OptionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 24,
      endIndent: 24,
      color: Color(0xFF2C2C2A),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;
    final trailingWidget = trailing;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitleText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        style: const TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingWidget != null) trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}