import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.searching,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 6,
      shadowColor: Colors.black26,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 10),
            IconButton(
              tooltip: 'Activity filter',
              onPressed: () {},
              icon: const Icon(Icons.directions_run, color: Color(0xFFFC4C02)),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (searching)
              const Padding(
                padding: EdgeInsets.only(right: 14),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Saved',
                  style: TextStyle(color: Color(0xFFFC4C02)),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
