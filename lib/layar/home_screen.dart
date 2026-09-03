import 'package:flutter/material.dart';
import '../widget/home/home_header.dart';

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
              child: Center(
                child: Text(
                  'Home Content',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}