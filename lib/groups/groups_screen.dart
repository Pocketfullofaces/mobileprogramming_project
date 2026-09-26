import 'package:flutter/material.dart';

const _bg = Color(0xFF0F0F0D);
const _surface = Color(0xFF1C1C1A);
const _orange = Color(0xFFFC4C02);

enum GroupTab { challenges, clubs, events }

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  GroupTab _tab = GroupTab.challenges;
  String _genre = 'Run';

  final _challengeGenres = const [
    ('Run', Icons.directions_run),
    ('Ride', Icons.pedal_bike),
    ('Swim', Icons.waves),
    ('Walk', Icons.directions_walk),
    ('Hike', Icons.terrain),
    ('Workout', Icons.fitness_center),
  ];

  final _challenges = <ChallengeItem>[
    const ChallengeItem(
      title: 'The Forge with Bandit Running',
      genre: 'Run',
      target: 'Complete 150 minutes',
      date: 'Sep 14 to Sep 28, 2026',
      accent: Color(0xFF7048E8),
      icon: Icons.local_fire_department,
    ),
    const ChallengeItem(
      title: 'Tracksmith Stack Miles Challenge',
      genre: 'Run',
      target: '15 Miles in one week',
      date: 'Sep 24 to Sep 30, 2026',
      accent: Color(0xFF375A7F),
      icon: Icons.workspace_premium,
    ),
    const ChallengeItem(
      title: 'Team End Polio Challenge',
      genre: 'Workout',
      target: 'Complete 300 minutes of movement',
      date: 'Sep 24 to Oct 24, 2026',
      accent: Color(0xFFF08C00),
      icon: Icons.health_and_safety,
    ),
    const ChallengeItem(
      title: 'Weekend Ride Quest',
      genre: 'Ride',
      target: 'Ride 40 km this weekend',
      date: 'Oct 3 to Oct 5, 2026',
      accent: Color(0xFF1971C2),
      icon: Icons.pedal_bike,
    ),
    const ChallengeItem(
      title: 'Morning Walk Reset',
      genre: 'Walk',
      target: 'Walk 5 days in a row',
      date: 'Oct 1 to Oct 7, 2026',
      accent: Color(0xFF2F9E44),
      icon: Icons.directions_walk,
    ),
  ];

  final _clubs = <ClubItem>[
    const ClubItem(
      name: 'Anjay Klub',
      location: 'Jakarta, Indonesia',
      members: 128,
      accent: Color(0xFFFC4C02),
    ),
    const ClubItem(
      name: 'Ayok Lari Community',
      location: 'BSD, Tangerang Selatan',
      members: 342,
      accent: Color(0xFF339AF0),
    ),
    const ClubItem(
      name: 'The Strava Club',
      location: 'San Francisco, California',
      members: 7273174,
      accent: Color(0xFFFF6B35),
    ),
  ];

  final _events = <EventItem>[
    const EventItem(
      title: 'Garmin Run',
      sport: 'Run',
      place: 'BSD City, Legok, BT, Indonesia',
      dateMonth: 'SEP',
      dateDay: '20',
      dateWeekday: 'SUN',
      members: 39,
    ),
    const EventItem(
      title: 'Jogging bersama di Monas',
      sport: 'Run',
      place: 'Monas, Jakarta Pusat',
      dateMonth: 'SEP',
      dateDay: '27',
      dateWeekday: 'SUN',
      members: 56,
    ),
    const EventItem(
      title: 'TCS London Marathon',
      sport: 'Marathon',
      place: 'Greater London, United Kingdom',
      dateMonth: 'APR',
      dateDay: '24',
      dateWeekday: 'SAT',
      members: 13097,
      range: 'Apr 24 - 25, 2027',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(onCreate: _openCreateDialog),
            _TabRow(
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            Expanded(
              child: switch (_tab) {
                GroupTab.challenges => _ChallengesView(
                  genres: _challengeGenres,
                  selectedGenre: _genre,
                  challenges: _challenges,
                  onGenreChanged: (genre) => setState(() => _genre = genre),
                  onJoin: _showJoined,
                ),
                GroupTab.clubs => _ClubsView(
                  clubs: _clubs,
                  onCreate: _openCreateClub,
                  onJoin: _showJoined,
                ),
                GroupTab.events => _EventsView(
                  events: _events,
                  onCreate: _openCreateEvent,
                  onJoin: _showJoined,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateDialog() {
    if (_tab == GroupTab.clubs) {
      _openCreateClub();
    } else if (_tab == GroupTab.events) {
      _openCreateEvent();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom challenge bisa ditambahkan nanti.')),
      );
    }
  }

  Future<void> _openCreateClub() async {
    final result = await showDialog<ClubItem>(
      context: context,
      builder: (_) => const _CreateClubDialog(),
    );
    if (result == null) return;
    setState(() => _clubs.insert(0, result));
    _showJoined(result.name);
  }

  Future<void> _openCreateEvent() async {
    final result = await showDialog<EventItem>(
      context: context,
      builder: (_) => const _CreateEventDialog(),
    );
    if (result == null) return;
    setState(() => _events.insert(0, result));
    _showJoined(result.title);
  }

  void _showJoined(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berhasil join $name')),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Groups',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: () {},
            icon: const Icon(Icons.forum_outlined, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Create',
            onPressed: onCreate,
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({required this.selected, required this.onChanged});

  final GroupTab selected;
  final ValueChanged<GroupTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2B2B2A))),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Challenges',
            tab: GroupTab.challenges,
            selected: selected,
            onChanged: onChanged,
          ),
          _TabButton(
            label: 'Clubs',
            tab: GroupTab.clubs,
            selected: selected,
            onChanged: onChanged,
          ),
          _TabButton(
            label: 'Events',
            tab: GroupTab.events,
            selected: selected,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.tab,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final GroupTab tab;
  final GroupTab selected;
  final ValueChanged<GroupTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = selected == tab;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(tab),
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 3,
                width: active ? 76 : 0,
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengesView extends StatelessWidget {
  const _ChallengesView({
    required this.genres,
    required this.selectedGenre,
    required this.challenges,
    required this.onGenreChanged,
    required this.onJoin,
  });

  final List<(String, IconData)> genres;
  final String selectedGenre;
  final List<ChallengeItem> challenges;
  final ValueChanged<String> onGenreChanged;
  final ValueChanged<String> onJoin;

  @override
  Widget build(BuildContext context) {
    final filtered = challenges
        .where((challenge) => challenge.genre == selectedGenre)
        .toList();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 68,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final item = genres[index];
              final active = item.$1 == selectedGenre;
              return ChoiceChip(
                selected: active,
                label: Text(item.$1),
                avatar: Icon(item.$2, size: 18),
                onSelected: (_) => onGenreChanged(item.$1),
                selectedColor: const Color(0xFF26211E),
                backgroundColor: _bg,
                labelStyle: TextStyle(color: active ? Colors.white : Colors.white70),
                side: BorderSide(color: active ? _orange : Colors.white38),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemCount: genres.length,
          ),
        ),
        if (filtered.isNotEmpty)
          _FeaturedChallenge(challenge: filtered.first, onJoin: onJoin),
        const _GroupChallengePromo(),
        const _SectionTitle(title: "What's New", subtitle: 'Find your next challenge'),
        SizedBox(
          height: 268,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final challenge = filtered.isEmpty ? challenges[index] : filtered[index % filtered.length];
              return _ChallengeCard(challenge: challenge, onJoin: onJoin);
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: filtered.isEmpty ? challenges.length : filtered.length,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _FeaturedChallenge extends StatelessWidget {
  const _FeaturedChallenge({required this.challenge, required this.onJoin});

  final ChallengeItem challenge;
  final ValueChanged<String> onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroBand(
          icon: Icons.directions_run,
          colors: [challenge.accent, const Color(0xFF111111)],
          label: challenge.genre,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BadgeIcon(color: challenge.accent, icon: challenge.icon),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${challenge.target}\n${challenge.date}',
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _OrangeButton(label: 'Join', onPressed: () => onJoin(challenge.title)),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupChallengePromo extends StatelessWidget {
  const _GroupChallengePromo();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department_outlined, color: _orange),
              SizedBox(width: 10),
              Text(
                'Group Challenges',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a custom challenge with friends',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          _OrangeButton(label: 'Start Your Free Trial', onPressed: () {}),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.onJoin});

  final ChallengeItem challenge;
  final ValueChanged<String> onJoin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        color: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BadgeIcon(color: challenge.accent, icon: challenge.icon),
              const Spacer(),
              Text(
                challenge.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${challenge.target}\n${challenge.date}',
                style: const TextStyle(color: Colors.white70, height: 1.35),
              ),
              const SizedBox(height: 16),
              _OrangeButton(label: 'Join', onPressed: () => onJoin(challenge.title)),
            ],
          ),
        ),
      ),
    );
  }
}


class _ClubsView extends StatelessWidget {
  const _ClubsView({
    required this.clubs,
    required this.onCreate,
    required this.onJoin,
  });

  final List<ClubItem> clubs;
  final VoidCallback onCreate;
  final ValueChanged<String> onJoin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _HeroBand(
          icon: Icons.groups,
          colors: [Color(0xFF365E54), Color(0xFF111111)],
          label: 'Clubs',
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Your Own Strava Club',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Give your community a motivating home base.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              _OrangeButton(label: 'Get Started', onPressed: onCreate),
              const SizedBox(height: 10),
              const _BubbleNote(text: 'New! Create and manage your club right from the app.'),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  'Learn More',
                  style: TextStyle(color: _orange, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const _HeroBand(
          icon: Icons.landscape,
          colors: [Color(0xFFB14A1A), Color(0xFFFF8A3D)],
          label: 'Community',
        ),
        for (final club in clubs)
          _ClubCard(club: club, onJoin: onJoin),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({required this.club, required this.onJoin});

  final ClubItem club;
  final ValueChanged<String> onJoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        children: [
          Row(
            children: [
              _BadgeIcon(color: club.accent, icon: Icons.groups, size: 58),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${club.location}\n${_formatNumber(club.members)} Athletes',
                      style: const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _OrangeButton(label: 'Join', onPressed: () => onJoin(club.name)),
        ],
      ),
    );
  }
}

class _EventsView extends StatelessWidget {
  const _EventsView({
    required this.events,
    required this.onCreate,
    required this.onJoin,
  });

  final List<EventItem> events;
  final VoidCallback onCreate;
  final ValueChanged<String> onJoin;

  @override
  Widget build(BuildContext context) {
    final localEvents = events.where((event) => event.range == null).toList();
    final races = events.where((event) => event.range != null).toList();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _SectionHeader(title: 'Local Club Events', action: 'Create', onAction: onCreate),
        SizedBox(
          height: 126,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => _EventTile(event: localEvents[index], onJoin: onJoin),
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: localEvents.length,
          ),
        ),
        const Divider(height: 32, color: Color(0xFF2B2B2A)),
        const _SectionHeader(title: 'Races', action: 'View all'),
        SizedBox(
          height: 430,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => _RaceCard(event: races[index], onJoin: onJoin),
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemCount: races.length,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}