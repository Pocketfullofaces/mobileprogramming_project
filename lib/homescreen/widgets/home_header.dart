import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onSearch,
    required this.onMessages,
    required this.onCreate,
    required this.onNotifications,
    this.hasUnread = false,
  });

  final VoidCallback onSearch;
  final VoidCallback onMessages;
  final VoidCallback onCreate;
  final VoidCallback onNotifications;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
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
          IconButton(
            tooltip: 'Create',
            onPressed: onCreate,
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: onMessages,
            icon: const Icon(Icons.forum_outlined, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Search friends',
            onPressed: onSearch,
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: onNotifications,
                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),
              if (hasUnread)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
