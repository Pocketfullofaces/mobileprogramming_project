import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('You', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          actions: [
            IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
          ],
          bottom: TabBar(
            indicatorColor: const Color(0xFFFC4C02),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.grey.withOpacity(0.2),
            tabs: [
              const Tab(text: 'Progress'),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Workouts'),
                    const SizedBox(width: 4),
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Activities'),
                    const SizedBox(width: 4),
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
      );
      }
      }