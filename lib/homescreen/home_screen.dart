import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/social_service.dart';
import 'post_screen.dart';
import 'social_screens.dart';
import 'streak_logic.dart';
import 'widgets/home_header.dart';
import 'widgets/streak.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = SocialService.instance;
  int _limit = 30;
  void _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  void _create() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in [
              ('text', 'Post', Icons.edit_outlined),
              ('photo', 'Post foto', Icons.photo_camera_outlined),
              ('activity', 'Activity kita', Icons.directions_run),
              ('chat', 'Chat', Icons.chat_bubble_outline),
            ])
              ListTile(
                leading: Icon(option.$3),
                title: Text(option.$2),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (option.$1 == 'chat') {
                    _open(const FriendsScreen());
                    return;
                  }
                  final published = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostScreen(kind: option.$1),
                    ),
                  );
                  if (published == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Berhasil dibagikan!')),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _service.auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Silakan login terlebih dahulu.'));
    }
    return SafeArea(
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _service.db
                .collection('users')
                .doc(user.uid)
                .collection('notifications')
                .where('read', isEqualTo: false)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) => HomeHeader(
              onCreate: _create,
              onMessages: () => _open(const MessagesScreen()),
              onSearch: () => _open(const FriendsScreen()),
              onNotifications: () => _open(const NotificationsScreen()),
              hasUnread: snapshot.data?.docs.isNotEmpty ?? false,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _service.db
                  .collection('users')
                  .doc(user.uid)
                  .collection('following')
                  .snapshots(),
              builder: (context, follows) {
                if (follows.hasError) {
                  return Center(child: Text(friendlyError(follows.error!)));
                }
                if (!follows.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final authors = {
                  user.uid,
                  ...follows.data!.docs.map((d) => d.id),
                };
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          // No limit: repeated activities in one day must not truncate streaks.
                          stream: _service.db
                              .collection('activities')
                              .where('userId', isEqualTo: user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                'Streak gagal dimuat: ${friendlyError(snapshot.error!)}',
                              );
                            }
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator();
                            }
                            final dates =
                                snapshot.data!.docs
                                    .where(
                                      (d) => d.data()['kind'] == 'activity',
                                    )
                                    .map((d) => d.data()['createdAt'])
                                    .whereType<Timestamp>()
                                    .map((t) => t.toDate())
                                    .toList()
                                  ..sort((a, b) => b.compareTo(a));
                            return StreakCard(
                              currentStreak: calculateStreak(
                                dates,
                                DateTime.now(),
                              ),
                              lastActivityLabel: dates.isEmpty
                                  ? null
                                  : 'Activity terakhir: ${dates.first.day}/${dates.first.month}/${dates.first.year}',
                            );
                          },
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _service.db
                          .collection('activities')
                          .orderBy('createdAt', descending: true)
                          .limit(_limit)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Feed belum bisa dimuat. ${friendlyError(snapshot.error!)}',
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final all = snapshot.data!.docs;
                        final posts = all
                            .where((d) => authors.contains(d.data()['userId']))
                            .toList();
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            if (posts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(28),
                                child: Text(
                                  'Belum ada post. Buat post pertama atau cari teman untuk diikuti.',
                                ),
                              ),
                            for (final post in posts)
                              ActivityCard(data: post.data()),
                            if (all.length == _limit)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _limit += 30),
                                  child: const Text('Muat post lebih lama'),
                                ),
                              ),
                            const SizedBox(height: 24),
                          ]),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '@${data['userName'] ?? 'User'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(data['kind'] == 'activity' ? 'Activity' : 'Post'),
            ],
          ),
          const SizedBox(height: 12),
          if ((data['caption'] as String? ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(data['caption'] as String),
            ),
          if (data['photoData'] is String)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(data['photoData'] as String),
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => const SizedBox(
                  height: 120,
                  child: Center(child: Text('Foto gagal dimuat')),
                ),
              ),
            ),
          if (data['kind'] == 'activity')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                spacing: 24,
                children: [
                  Text('${data['distanceKm']} km'),
                  Text('${data['durationMinutes']} menit'),
                ],
              ),
            ),
          if (data['createdAt'] is Timestamp)
            Text(
              _label((data['createdAt'] as Timestamp).toDate()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    ),
  );
  String _label(DateTime date) =>
      '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
