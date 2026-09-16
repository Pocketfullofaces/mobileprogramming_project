import 'package:flutter/material.dart';
import '../widget/home/home_header.dart';
import '../widget/home/tracker.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121210),
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: MapTrackerWidget(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
