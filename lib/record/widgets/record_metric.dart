import 'package:flutter/material.dart';

class RecordMetric extends StatelessWidget {
  const RecordMetric({super.key, required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final current = value;
    return Semantics(
      label: '$label ${current ?? 'belum tersedia'}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 72,
            child: Center(
              child: current == null
                  ? const _EmptyReading()
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        current,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 68,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReading extends StatelessWidget {
  const _EmptyReading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Bar(),
        SizedBox(width: 6),
        _Colon(),
        SizedBox(width: 9),
        _Bar(),
        SizedBox(width: 9),
        _Bar(),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 31,
      height: 15,
      child: DecoratedBox(decoration: BoxDecoration(color: Colors.white)),
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [_Dot(), SizedBox(height: 25), _Dot()],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 21,
      height: 21,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}