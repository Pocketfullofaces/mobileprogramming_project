import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        18,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF333333),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.forum_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 29,
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }
}