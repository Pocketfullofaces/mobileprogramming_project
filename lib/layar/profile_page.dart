import 'package:flutter/material.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

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
        body: const TabBarView(
          children: [
            ProgressTabContent(),
            Center(child: Text('Workouts Tab', style: TextStyle(color: Colors.white))),
            Center(child: Text('Activities Tab', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }
}

class ProgressTabContent extends StatelessWidget {
  const ProgressTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        ActivityHeaderWidget(),
        SizedBox(height: 16),
        WeeklyStatsWidget(),
        SizedBox(height: 24),
        Chart12WeeksWidget(),
        SizedBox(height: 16),
        StreakWidget(),
        SizedBox(height: 16)
      ],
    );
  }
}

class ActivityHeaderWidget extends StatelessWidget {
  const ActivityHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFC4C02)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_run, color: Color(0xFFFC4C02), size: 18),
              SizedBox(width: 4),
              Text('Run', style: TextStyle(color: Color(0xFFFC4C02), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Aug 10 - Aug 16, 2026',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class WeeklyStatsWidget extends StatelessWidget {
  const WeeklyStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatItem(label: 'Distance', value: '0 km'),
        _StatItem(label: 'Time', value: '0 m'),
        _StatItem(label: 'Elev Gain', value: '0 m'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class Chart12WeeksWidget extends StatelessWidget {
  const Chart12WeeksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Past 12 weeks', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Column(
            children: [
              _buildGridLine('6 km'),
              const SizedBox(height: 30),
              _buildGridLine('3 km'),
              const SizedBox(height: 30),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Divider(color: Colors.grey, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(12, (index) {
                      bool isCurrent = index == 7;
                      return Container(
                        width: isCurrent ? 10 : 6,
                        height: isCurrent ? 10 : 6,
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xFFFC4C02) : Colors.transparent,
                          border: Border.all(color: const Color(0xFFFC4C02), width: 2),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  Positioned(
                    left: 205,
                    bottom: 0,
                    child: Container(width: 2, height: 70, color: Colors.white),
                  )
                ],
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('0 km', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('JUL', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('AUG', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('SEP', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGridLine(String label) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class StreakWidget extends StatelessWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Streak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Row(
                children: const [
                  Text('This month', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.white, size: 40),
                  const Text('0', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Weeks', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(28, (index) {
                    bool isToday = index == 10;
                    return Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: isToday ? Colors.transparent : Colors.grey.withOpacity(0.2),
                        border: isToday ? Border.all(color: Colors.white, width: 1.5) : null,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}