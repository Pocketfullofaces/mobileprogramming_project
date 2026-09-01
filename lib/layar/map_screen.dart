import 'package:flutter/material.dart';
import '../widget/home/tracker.dart'; // sesuaikan path kalau beda

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121210),
      body: SafeArea(
        child: MapTrackerWidget(),
      ),
    );
  }
}