String formatClock(Duration value) {
  final hours = value.inHours.toString().padLeft(2, '0');
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String? formatPace(double meters, Duration time) {
  if (meters <= 0 || time.inMilliseconds <= 0) return null;
  final secondsPerKm = (time.inMilliseconds / 1000) / (meters / 1000);
  if (!secondsPerKm.isFinite || secondsPerKm > 5999) return null; // > 99:59
  final total = secondsPerKm.round();
  final minutes = total ~/ 60;
  final seconds = (total % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String? formatSpeed(double meters, Duration time) {
  if (meters <= 0 || time.inMilliseconds <= 0) return null;
  final kmh = (meters / 1000) / (time.inMilliseconds / 3600000);
  if (!kmh.isFinite) return null;
  return kmh.toStringAsFixed(1);
}