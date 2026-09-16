import 'package:flutter/material.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  // Data dummy, langsung di dalam state biar toggle join/gabung/ikut
  // kelihatan interaktif walau belum nyambung backend.
  final List<Map<String, dynamic>> _challenges = [
    {
      'title': '50km Run Challenge',
      'subtitle': 'Run · 25 hari lagi',
      'desc': 'Selesaikan total 50km lari bulan ini.',
      'participants': 128,
      'joined': true,
      'progress': 0.32,
      'icon': Icons.directions_run,
    },
    {
      'title': 'Weekend Ride 100km',
      'subtitle': 'Ride · 2 hari lagi',
      'desc': 'Gowes 100km dalam satu weekend.',
      'participants': 64,
      'joined': false,
      'progress': 0.0,
      'icon': Icons.directions_bike,
    },
    {
      'title': 'Hike 500m Elevation',
      'subtitle': 'Hike · 13 hari lagi',
      'desc': 'Kumpulkan 500m elevation gain dari hiking.',
      'participants': 41,
      'joined': false,
      'progress': 0.0,
      'icon': Icons.terrain,
    },
  ];

  final List<Map<String, dynamic>> _clubs = [
    {
      'name': 'Jakarta Morning Runners',
      'desc': 'Komunitas lari pagi area Jakarta, kumpul tiap Minggu.',
      'members': 312,
      'joined': true,
      'tags': ['Run'],
    },
    {
      'name': 'Weekend Cyclist',
      'desc': 'Gowes santai tiap Sabtu sore, semua level welcome.',
      'members': 154,
      'joined': false,
      'tags': ['Ride'],
    },
    {
      'name': 'Trail & Hike ID',
      'desc': 'Eksplorasi jalur hiking dan trail running.',
      'members': 87,
      'joined': false,
      'tags': ['Hike', 'Run'],
    },
  ];

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'Sunday Long Run 15K',
      'desc': 'Long run bareng, pace santai, meeting point GBK.',
      'date': '19 Sep, 06:00',
      'location': 'GBK Senayan',
      'attendees': 42,
      'going': true,
    },
    {
      'title': 'Night Ride Kemang',
      'desc': 'Gowes santai malam, jarak ±20km.',
      'date': '21 Sep, 19:00',
      'location': 'Kemang',
      'attendees': 18,
      'going': false,
    },
    {
      'title': 'Trail Run Bogor',
      'desc': 'Trail run 10km, medan tanjakan sedang.',
      'date': '26 Sep, 05:00',
      'location': 'Bogor',
      'attendees': 9,
      'going': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Groups'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Challenges'),
              Tab(text: 'Clubs'),
              Tab(text: 'Events'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChallengesTab(),
            _buildClubsTab(),
            _buildEventsTab(),
          ],
        ),
      ),
    );
  }

  // ---------- Challenges ----------

  Widget _buildChallengesTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _challenges.length,
      itemBuilder: (context, i) {
        final c = _challenges[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(c['icon'] as IconData, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(c['subtitle'] as String,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(c['desc'] as String),
                if (c['joined'] as bool) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: c['progress'] as double,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${c['participants']} peserta',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    OutlinedButton(
                      onPressed: () => setState(() => c['joined'] = !(c['joined'] as bool)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: (c['joined'] as bool) ? Colors.grey : Colors.orange,
                        side: BorderSide(color: (c['joined'] as bool) ? Colors.grey : Colors.orange),
                      ),
                      child: Text((c['joined'] as bool) ? 'Keluar' : 'Ikutan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Clubs ----------

  Widget _buildClubsTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _clubs.length,
      itemBuilder: (context, i) {
        final c = _clubs[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFDCE7FF),
                  child: Icon(Icons.groups, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(c['desc'] as String),
                      const SizedBox(height: 4),
                      Text('${c['members']} anggota',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: (c['tags'] as List<String>)
                            .map((t) => Chip(
                                  label: Text(t, style: const TextStyle(fontSize: 11)),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => setState(() => c['joined'] = !(c['joined'] as bool)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: (c['joined'] as bool) ? Colors.grey : Colors.blue,
                            side: BorderSide(color: (c['joined'] as bool) ? Colors.grey : Colors.blue),
                          ),
                          child: Text((c['joined'] as bool) ? 'Keluar' : 'Gabung'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Events ----------

  Widget _buildEventsTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _events.length,
      itemBuilder: (context, i) {
        final e = _events[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (e['date'] as String).split(' ')[0],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(e['desc'] as String),
                      const SizedBox(height: 4),
                      Text('${e['date']} · ${e['location']}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${e['attendees']} akan hadir',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          OutlinedButton(
                            onPressed: () => setState(() => e['going'] = !(e['going'] as bool)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: (e['going'] as bool) ? Colors.grey : Colors.green,
                              side: BorderSide(color: (e['going'] as bool) ? Colors.grey : Colors.green),
                            ),
                            child: Text((e['going'] as bool) ? 'Batal' : 'Ikut'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}