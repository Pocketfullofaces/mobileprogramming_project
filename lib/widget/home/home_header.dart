import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      color: const Color(0xFF121210),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showMessage(context, 'Profile');
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF333333),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            onPressed: () {
              showMessage(context, 'Messages');
            },
            icon: const Icon(
              Icons.forum_outlined,
              color: Colors.white,
            ),
          ),

          IconButton(
            onPressed: () {
              showMessage(context, 'Search');
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),

          Stack(
            children: [
              IconButton(
                onPressed: () {
                  showMessage(context, 'Notifications');
                },
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
              ),

              // Titik merah notification.
              const Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
