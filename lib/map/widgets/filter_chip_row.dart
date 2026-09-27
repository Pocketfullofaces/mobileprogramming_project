import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _MapFilterChip(label: 'Routes'),
          _MapFilterChip(label: 'Length'),
          _MapFilterChip(label: 'Elevation'),
        ],
      ),
    );
  }
}

class _MapFilterChip extends StatelessWidget {
  const _MapFilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}