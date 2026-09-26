import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../login/login_screen.dart';
import '../services/social_service.dart';
import '../homescreen/streak_logic.dart';

const _bg = Color(0xFF0F0F0D);
const _card = Color(0xFF181816);
const _line = Color(0xFF333330);
const _orange = Color(0xFFFC4C02);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SocialService.instance;
    final user = service.auth.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Silakan login terlebih dahulu.')),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: service.db.collection('users').doc(user.uid).snapshots(),
          builder: (context, profileSnap) {
            final profile = profileSnap.data?.data() ?? {};
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: service.db
                  .collection('activities')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, activitySnap) {
                final activities = activitySnap.data?.docs ?? [];
                final activityDates = activities
                    .where((doc) => doc.data()['kind'] == 'activity')
                    .map((doc) => doc.data()['createdAt'])
                    .whereType<Timestamp>()
                    .map((time) => time.toDate())
                    .toList();
                final stats = _RunStats.fromDocs(activities);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  children: [
                    _ProfileTopBar(
                      onSearch: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(builder: (_) => const _PeopleScreen()),
                      ),
                      onLogout: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _ProfileHeader(
                      uid: user.uid,
                      profile: profile,
                      activitiesCount: activities.length,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _OutlinePill(
                            label: 'Edit profile',
                            onTap: () => Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(
                                  initialProfile: profile,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OutlinePill(
                            label: 'Share profile',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Share profile disiapkan nanti.'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _ProfileSectionTabs(
                      onStats: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _StatisticsPage(stats: stats),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ProgressCard(stats: stats),
                    const SizedBox(height: 18),
                    _StreakCard(
                      dates: activityDates,
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => _StreakSheet(dates: activityDates),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _StatisticsPreview(stats: stats),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onSearch, required this.onLogout});

  final VoidCallback onSearch;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: SizedBox()),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.white, size: 34),
        ),
        IconButton(
          onPressed: onSearch,
          icon: const Icon(Icons.search, color: Colors.white, size: 34),
        ),
        IconButton(
          onPressed: onLogout,
          tooltip: 'Logout',
          icon: const Icon(Icons.logout, color: Colors.white, size: 30),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.uid,
    required this.profile,
    required this.activitiesCount,
  });

  final String uid;
  final Map<String, dynamic> profile;
  final int activitiesCount;

  @override
  Widget build(BuildContext context) {
    final name =
        profile['displayName'] as String? ??
        profile['username'] as String? ??
        'User';
    final location = [
      profile['city'] as String? ?? '',
      profile['country'] as String? ?? '',
    ].where((part) => part.trim().isNotEmpty).join(', ');
    final bio = profile['bio'] as String? ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileAvatar(profile: profile, radius: 48),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$activitiesCount activities',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(location, style: const TextStyle(color: Colors.white60)),
              ],
              if (bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(bio, style: const TextStyle(color: Colors.white70)),
              ],
              const SizedBox(height: 14),
              _FollowCounts(uid: uid),
            ],
          ),
        ),
      ],
    );
  }
}

class _FollowCounts extends StatelessWidget {
  const _FollowCounts({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final db = SocialService.instance.db;
    return Row(
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db.collection('users').doc(uid).collection('followers').snapshots(),
          builder: (_, snap) => Text(
            '${snap.data?.docs.length ?? 0} followers',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const Text('  •  ', style: TextStyle(color: Colors.white70)),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db.collection('users').doc(uid).collection('following').snapshots(),
          builder: (_, snap) => Text(
            '${snap.data?.docs.length ?? 0} following',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.radius});

  final Map<String, dynamic> profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photo = _decodePhoto(profile['photoData']);
    final name =
        profile['displayName'] as String? ??
        profile['username'] as String? ??
        'User';
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF425866),
      backgroundImage: photo == null ? null : MemoryImage(photo),
      child: photo == null
          ? Text(
              name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: radius,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}

class _OutlinePill extends StatelessWidget {
  const _OutlinePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: _line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _ProfileSectionTabs extends StatelessWidget {
  const _ProfileSectionTabs({required this.onStats});

  final VoidCallback onStats;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: _ProfileTab(
              icon: Icons.insert_chart,
              label: 'Progress',
              active: true,
            ),
          ),
          const Expanded(
            child: _ProfileTab(
              icon: Icons.timeline,
              label: 'Activities',
              active: false,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onStats,
              child: const _ProfileTab(
                icon: Icons.menu,
                label: 'Statistics',
                active: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: active ? Colors.white : Colors.white54, size: 34),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 4,
          width: active ? 92 : 0,
          decoration: BoxDecoration(
            color: _orange,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.stats});

  final _RunStats stats;

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: _orange),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_run, color: _orange),
                  SizedBox(width: 8),
                  Text(
                    'Run',
                    style: TextStyle(color: _orange, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Jul 20 - Jul 26, 2026',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _SmallMetric(label: 'Distance', value: '${stats.weekKm.toStringAsFixed(0)} km'),
              _SmallMetric(label: 'Time', value: '${stats.weekMinutes}m'),
              const _SmallMetric(label: 'Elev Gain', value: '0 m'),
            ],
          ),
          const SizedBox(height: 26),
          const Text('Past 12 weeks', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          SizedBox(height: 160, child: _ProgressChart(points: stats.weeklyKm)),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.dates, required this.onTap});

  final List<DateTime> dates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final weeks = calculateStreak(dates, DateTime.now()) ~/ 7;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: _RoundedCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Streak',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white70, size: 72),
                      const SizedBox(width: 12),
                      Text(
                        '$weeks\nWeeks',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 26,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  children: [
                    Text('This month', style: TextStyle(color: Colors.white70)),
                    Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 20),
                _MiniCalendar(dates: dates),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsPreview extends StatelessWidget {
  const _StatisticsPreview({required this.stats});

  final _RunStats stats;

  @override
  Widget build(BuildContext context) {
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _StatLine(label: 'Runs', value: '${stats.runs}'),
          _StatLine(label: 'Time', value: '${stats.totalHours}h'),
          _StatLine(label: 'Distance', value: '${stats.totalKm.toStringAsFixed(0)} km'),
        ],
      ),
    );
  }
}