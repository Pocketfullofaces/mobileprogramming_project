import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemSound, SystemSoundType;
import 'package:geolocator/geolocator.dart' show Position;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import '../map/services/location_service.dart';
import '../services/social_service.dart';
import 'models/activity_type.dart';
import 'record_format.dart';
import 'record_route_picker.dart';
import 'widgets/record_controls.dart';
import 'widgets/record_metric.dart';
import 'widgets/record_options_panel.dart';
import 'widgets/record_sensor_dialog.dart';
import 'widgets/record_settings_sheet.dart';
import 'widgets/record_share_location_dialog.dart';
import 'widgets/record_summary_sheet.dart';
import 'widgets/record_timer.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  static const _minAccuracyMeters = 35.0;

  static const _autoPauseAfter = Duration(seconds: 10);

  static const _autoResumeThresholdMeters = 8.0;

  final _location = const LocationService();
  final _laps = <Duration>[];

  StreamSubscription<Position>? _positionSub;
  Timer? _ticker;
  Position? _lastPosition;

  DateTime? _segmentStart;
  Duration _accumulated = Duration.zero;

  double _distanceMeters = 0;
  double _splitStartDistance = 0;
  Duration _splitStartElapsed = Duration.zero;
  String? _lastSplitValue;
  Duration _lastLapAt = Duration.zero;
  DateTime _lastMovementAt = DateTime.now();

  ActivityType _type = ActivityType.run;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _autoPaused = false;
  bool _gpsReady = false;
  bool _trackLaps = false;
  bool _panelOpen = true;

  List<LatLng>? _routePoints;
  int? _heartRateBpm;
  bool _shareLocationOn = false;
  bool _audioCues = false;
  bool _autoPause = false;

  Duration get _elapsed {
    final start = _segmentStart;
    return start == null
        ? _accumulated
        : _accumulated + DateTime.now().difference(start);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  String? _formatMetric(double meters, Duration time) => _type.usesSpeed
      ? formatSpeed(meters, time)
      : formatPace(meters, time);

  String? get _metricValue {
    final splitMeters = _distanceMeters - _splitStartDistance;
    if (splitMeters >= 50) {
      return _formatMetric(splitMeters, _elapsed - _splitStartElapsed);
    }
    return _lastSplitValue;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {});
      _checkAutoPause();
    });
  }

  void _checkAutoPause() {
    if (!_autoPause || !_isRecording || _isPaused) return;
    if (DateTime.now().difference(_lastMovementAt) >= _autoPauseAfter) {
      _pause(auto: true);
      _showMessage('Auto-pause: tidak ada pergerakan selama 10 detik.');
    }
  }

  void _listenGps() {
    _positionSub?.cancel();
    _positionSub = _location.positionStream().listen(
      _onPosition,
      onError: (_) => _showMessage('Stream lokasi terputus.'),
    );
  }

  void _stopGps() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void _onPosition(Position position) {
    if (!_isRecording) return;

    if (_isPaused) {
      if (!_autoPaused) return;
      final last = _lastPosition;
      _lastPosition = position;
      if (last == null) return;
      if (_location.distanceMeters(last, position) >= _autoResumeThresholdMeters) {
        _resume(auto: true);
        _showMessage('Bergerak lagi, rekaman dilanjutkan.');
      }
      return;
    }

    if (position.accuracy > _minAccuracyMeters) return;

    final last = _lastPosition;
    if (last == null) {
      _lastPosition = position;
      return;
    }
    final delta = _location.distanceMeters(last, position);
    if (delta < 1) return;

    _lastPosition = position;
    _lastMovementAt = DateTime.now();
    setState(() {
      _distanceMeters += delta;
      _closeSplitIfNeeded();
    });
  }

  void _closeSplitIfNeeded() {
    final splitMeters = _distanceMeters - _splitStartDistance;
    if (splitMeters < 1000) return;
    final now = _elapsed;
    _lastSplitValue = _formatMetric(splitMeters, now - _splitStartElapsed);
    _splitStartDistance = (_distanceMeters ~/ 1000) * 1000.0;
    _splitStartElapsed = now;
    if (_audioCues) SystemSound.play(SystemSoundType.click);
  }

  Future<void> _start() async {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _autoPaused = false;
      _segmentStart = DateTime.now();
      _accumulated = Duration.zero;
      _distanceMeters = 0;
      _splitStartDistance = 0;
      _splitStartElapsed = Duration.zero;
      _lastSplitValue = null;
      _lastPosition = null;
      _lastLapAt = Duration.zero;
      _lastMovementAt = DateTime.now();
      _laps.clear();
    });
    _startTicker();

    var granted = false;
    String? message;
    try {
      final permission = await _location.ensurePermission();
      granted = permission.granted;
      message = permission.message;
    } catch (_) {
      message = 'Lokasi tidak bisa diakses di perangkat ini.';
    }
    if (!mounted) return;

    _gpsReady = granted;
    if (!granted) {
      _showMessage(
        '${message ?? 'Izin lokasi belum diberikan.'} '
        'Timer tetap jalan, tapi jarak tidak terhitung.',
      );
      return;
    }
    if (_isRecording && !_isPaused) _listenGps();
  }

  void _pause({bool auto = false}) {
    setState(() {
      _accumulated = _elapsed;
      _segmentStart = null;
      _isPaused = true;
      _autoPaused = auto;
    });
    _ticker?.cancel();
    if (!auto) _stopGps();
  }

  void _resume({bool auto = false}) {
    setState(() {
      _segmentStart = DateTime.now();
      _isPaused = false;
      _autoPaused = false;
      _lastMovementAt = DateTime.now();
      _lastPosition = null;
    });
    _startTicker();
    if (_gpsReady) _listenGps();
  }

  void _onStartPause() {
    if (!_isRecording) {
      _start();
    } else if (_isPaused) {
      _resume();
    } else {
      _pause();
    }
  }

  void _onLap() {
    final now = _elapsed;
    final lapTime = now - _lastLapAt;
    setState(() {
      _laps.add(lapTime);
      _lastLapAt = now;
    });
    _showMessage('Lap ${_laps.length} · ${formatClock(lapTime)}');
  }

  void _reset() {
    _ticker?.cancel();
    _stopGps();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _autoPaused = false;
      _segmentStart = null;
      _accumulated = Duration.zero;
      _distanceMeters = 0;
      _splitStartDistance = 0;
      _splitStartElapsed = Duration.zero;
      _lastSplitValue = null;
      _lastPosition = null;
      _lastLapAt = Duration.zero;
      _laps.clear();
    });
  }

  Future<void> _pickType() async {
    if (_isRecording) return;
    final picked = await showActivityTypeSheet(context, selected: _type);
    if (picked != null && mounted) setState(() => _type = picked);
  }

  Future<void> _finish() async {
    final summary = RecordSummary(
      type: _type,
      distanceKm: _distanceMeters / 1000,
      duration: _elapsed,
      laps: List.of(_laps),
    );
    final result = await RecordSummarySheet.show(
      context,
      summary: summary,
      onSave: (caption) => SocialService.instance.publish(
        kind: 'activity',
        caption: caption.trim().isEmpty ? _type.label : caption,
        distance: summary.roundedKm,
        minutes: summary.minutes,
      ),
    );
    if (!mounted) return;

    if (result == RecordSummaryResult.saved) {
      _reset();
      _showMessage('Aktivitas tersimpan. Cek di tab Home!');
    } else if (result == RecordSummaryResult.discard) {
      _reset();
    } else if (result == RecordSummaryResult.resume) {
      _resume();
    }
  }

  Future<void> _onAddRoute() async {
    final result = await Navigator.of(context).push<List<LatLng>>(
      MaterialPageRoute(
        builder: (_) => RecordRoutePicker(initialPoints: _routePoints ?? const []),
      ),
    );
    if (result != null && mounted) {
      setState(() => _routePoints = result);
      _showMessage('Rute tersimpan (${result.length} titik).');
    }
  }

  Future<void> _onShareLocation() async {
    Position position;
    try {
      position = await _location.currentPosition();
    } catch (_) {
      _showMessage('Lokasi tidak bisa diambil. Pastikan GPS aktif.');
      return;
    }
    if (!mounted) return;
    setState(() => _shareLocationOn = true);
    await showShareLocationDialog(context, position: position);
  }

  Future<void> _onAddSensor() async {
    final result = await showSensorDialog(context, current: _heartRateBpm);
    if (!mounted || result == null) return;
    setState(() => _heartRateBpm = result == -1 ? null : result);
  }

  void _onSettings() {
    RecordSettingsSheet.show(
      context,
      audioCues: _audioCues,
      onAudioCuesChanged: (value) => setState(() => _audioCues = value),
      autoPause: _autoPause,
      onAutoPauseChanged: (value) {
        setState(() => _autoPause = value);
        if (value) _lastMovementAt = DateTime.now();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121210),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  RecordTimer(
                    elapsed: _elapsed,
                    isPaused: _isPaused,
                    onCollapse: () => setState(() => _panelOpen = !_panelOpen),
                  ),
                  Expanded(
                    child: Center(
                      child: RecordMetric(
                        value: _metricValue,
                        label: _type.usesSpeed
                            ? 'Split avg. (km/h)'
                            : 'Split avg. (/km)',
                      ),
                    ),
                  ),
                  _SheetHandle(
                    onToggle: (open) => setState(() => _panelOpen = open),
                    isOpen: _panelOpen,
                  ),
                  RecordControls(
                    type: _type,
                    isRecording: _isRecording,
                    isPaused: _isPaused,
                    trackLaps: _trackLaps,
                    hasRoute: _routePoints != null && _routePoints!.isNotEmpty,
                    onPickType: _pickType,
                    onStartPause: _onStartPause,
                    onFinish: _finish,
                    onLap: _onLap,
                    onAddRoute: _onAddRoute,
                  ),
                  const SizedBox(height: 16),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.topCenter,
                    child: _panelOpen
                        ? RecordOptionsPanel(
                            trackLaps: _trackLaps,
                            onTrackLapsChanged: (value) =>
                                setState(() => _trackLaps = value),
                            shareLocationOn: _shareLocationOn,
                            onShareLocation: _onShareLocation,
                            sensorSubtitle: _heartRateBpm == null
                                ? null
                                : '$_heartRateBpm bpm (manual)',
                            onAddSensor: _onAddSensor,
                            onSettings: _onSettings,
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.onToggle, required this.isOpen});

  final ValueChanged<bool> onToggle;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onToggle(!isOpen),
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 0) onToggle(false);
        if (velocity < 0) onToggle(true);
      },
      child: const SizedBox(
        height: 36,
        width: double.infinity,
        child: Center(
          child: SizedBox(
            width: 36,
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}