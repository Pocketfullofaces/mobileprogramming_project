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

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.initialProfile});

  final Map<String, dynamic> initialProfile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _country;
  late final TextEditingController _city;
  late final TextEditingController _bio;
  late final TextEditingController _birthDate;
  String _gender = 'Prefer not to say';
  Uint8List? _pickedPhoto;
  bool _removePhoto = false;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text:
          widget.initialProfile['displayName'] as String? ??
          widget.initialProfile['username'] as String? ??
          '',
    );
    _country = TextEditingController(
      text: widget.initialProfile['country'] as String? ?? '',
    );
    _city = TextEditingController(
      text: widget.initialProfile['city'] as String? ?? '',
    );
    _bio = TextEditingController(text: widget.initialProfile['bio'] as String? ?? '');
    _birthDate = TextEditingController(
      text: widget.initialProfile['birthDate'] as String? ?? '',
    );
    _gender =
        widget.initialProfile['gender'] as String? ?? 'Prefer not to say';
    for (final controller in [_name, _country, _city, _bio, _birthDate]) {
      controller.addListener(() => setState(() => _dirty = true));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    _city.dispose();
    _bio.dispose();
    _birthDate.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 55,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (bytes.length > 600 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto maksimal sekitar 600 KB.')),
      );
      return;
    }
    setState(() {
      _pickedPhoto = bytes;
      _removePhoto = false;
      _dirty = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await SocialService.instance.updateProfile(
        displayName: _name.text,
        country: _country.text,
        city: _city.text,
        bio: _bio.text,
        birthDate: _birthDate.text,
        gender: _gender,
        photo: _pickedPhoto,
        removePhoto: _removePhoto,
      );
      if (!mounted) return;
      setState(() => _dirty = false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmExit() async {
    if (!_dirty || _saving) return true;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Simpan perubahan profile sebelum keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == 'save') {
      await _save();
      return false;
    }
    return result == 'discard';
  }

  @override
  Widget build(BuildContext context) {
    final originalPhoto = _decodePhoto(widget.initialProfile['photoData']);
    final shownPhoto = _pickedPhoto ?? (_removePhoto ? null : originalPhoto);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: _bg,
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor: const Color(0xFF425866),
                    backgroundImage: shownPhoto == null ? null : MemoryImage(shownPhoto),
                    child: shownPhoto == null
                        ? const Icon(Icons.person, color: Colors.white, size: 64)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
            if (shownPhoto != null)
              TextButton(
                onPressed: () => setState(() {
                  _pickedPhoto = null;
                  _removePhoto = true;
                  _dirty = true;
                }),
                child: const Text('Remove photo'),
              ),
            const SizedBox(height: 22),
            _EditField(controller: _name, label: 'Nama akun'),
            _EditField(controller: _country, label: 'Negara'),
            _EditField(controller: _city, label: 'Kota'),
            _EditField(controller: _bio, label: 'Bio', maxLines: 3),
            _EditField(controller: _birthDate, label: 'Tanggal lahir'),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const ['Man', 'Woman', 'Prefer not to say']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() {
                _gender = value ?? 'Prefer not to say';
                _dirty = true;
              }),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeopleScreen extends StatelessWidget {
  const _PeopleScreen();

  @override
  Widget build(BuildContext context) {
    final service = SocialService.instance;
    final currentUid = service.auth.currentUser?.uid;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('Find People'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.db
            .collection('users')
            .orderBy('usernameLowercase')
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(friendlyError(snapshot.error!)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs
              .where((doc) => doc.id != currentUid)
              .toList();
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada akun lain.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(color: _line),
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data();
              return _PersonTile(targetUid: doc.id, profile: data);
            },
          );
        },
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.targetUid, required this.profile});

  final String targetUid;
  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final service = SocialService.instance;
    final uid = service.auth.currentUser?.uid;
    final name =
        profile['displayName'] as String? ??
        profile['username'] as String? ??
        'User';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _ProfileAvatar(profile: profile, radius: 24),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '@${profile['username'] ?? name}',
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: uid == null
          ? null
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: service.db
                  .collection('users')
                  .doc(uid)
                  .collection('following')
                  .doc(targetUid)
                  .snapshots(),
              builder: (context, snapshot) {
                final following = snapshot.data?.exists ?? false;
                return OutlinedButton(
                  onPressed: () async {
                    try {
                      await service.follow(targetUid, following);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(friendlyError(e))),
                      );
                    }
                  },
                  child: Text(following ? 'Following' : 'Follow'),
                );
              },
            ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _StatisticsPage extends StatelessWidget {
  const _StatisticsPage({required this.stats});

  final _RunStats stats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text(
          ' Statistics',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
            child: const Column(
              children: [
                Icon(Icons.directions_run, color: Colors.white, size: 58),
                SizedBox(height: 12),
                SizedBox(
                  width: 52,
                  height: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _StatsBlock(
            title: 'AVG WEEKLY ACTIVITY',
            rows: [
              ('Runs', '${stats.avgWeeklyRuns}'),
              ('Time', '${stats.avgWeeklyHours}h'),
              ('Distance', '${stats.avgWeeklyKm.toStringAsFixed(0)} km'),
            ],
          ),
          _StatsBlock(
            title: 'YEAR-TO-DATE',
            rows: [
              ('Runs', '${stats.runs}'),
              ('Time', '${stats.totalHours}h'),
              ('Distance', '${stats.totalKm.toStringAsFixed(0)} km'),
              ('Elevation Gain', '0 m'),
            ],
          ),
          _StatsBlock(
            title: 'ALL TIME',
            rows: [
              ('Runs', '${stats.runs}'),
              ('Distance', '${stats.totalKm.toStringAsFixed(0)} km'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsBlock extends StatelessWidget {
  const _StatsBlock({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ),
        Container(
          color: _bg,
          child: Column(
            children: [
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                  child: _StatLine(label: row.$1, value: row.$2, large: true),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakSheet extends StatelessWidget {
  const _StreakSheet({required this.dates});

  final List<DateTime> dates;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weeks = calculateStreak(dates, now) ~/ 7;
    return DraggableScrollableSheet(
      initialChildSize: .76,
      minChildSize: .42,
      maxChildSize: .92,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 76,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 44),
              Text(
                _monthTitle(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  _StreakMetric(title: 'Your Streak', value: '$weeks Weeks'),
                  const SizedBox(width: 44),
                  _StreakMetric(title: 'Streak Activities', value: '${dates.length}'),
                ],
              ),
              const SizedBox(height: 34),
              _FullCalendar(dates: dates, month: now),
            ],
          ),
        );
      },
    );
  }
}

class _StreakMetric extends StatelessWidget {
  const _StreakMetric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _RoundedCard extends StatelessWidget {
  const _RoundedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}