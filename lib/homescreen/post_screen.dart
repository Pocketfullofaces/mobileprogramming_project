import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/social_service.dart';

void showFailure(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(friendlyError(error))));
}

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String _query = '';
  final _service = SocialService.instance;
  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> users = _service.db
        .collection('users')
        .orderBy('usernameLowercase');
    if (_query.isNotEmpty) {
      users = users.startAt([_query]).endAt(['$_query\uf8ff']);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Cari teman')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autocorrect: false,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari berdasarkan username',
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          if (_query.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Temukan akun untuk diikuti atau diajak chat'),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: users.limit(30).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(friendlyError(snapshot.error!)));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs
                    .where((d) => d.id != _service.uid)
                    .toList();
                if (docs.isEmpty) {
                  return const Center(child: Text('Akun tidak ditemukan.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) =>
                      _FriendTile(key: ValueKey(docs[i].id), user: docs[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatefulWidget {
  const _FriendTile({super.key, required this.user});
  final QueryDocumentSnapshot<Map<String, dynamic>> user;
  @override
  State<_FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<_FriendTile> {
  bool _busy = false;
  final _service = SocialService.instance;
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user.data()['username'] as String? ?? 'User';
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _service.db
          .collection('users')
          .doc(_service.uid)
          .collection('following')
          .doc(widget.user.id)
          .snapshots(),
      builder: (context, snapshot) {
        final following = snapshot.data?.exists ?? false;
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('@$name'),
          subtitle: snapshot.hasError
              ? const Text('Status follow gagal dimuat')
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Chat',
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        final id = await _service.chatWith(widget.user.id);
                        if (!context.mounted) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ChatScreen(chatId: id, title: '@$name'),
                          ),
                        );
                      }),
              ),
              FilledButton(
                onPressed: _busy || !snapshot.hasData || snapshot.hasError
                    ? null
                    : () => _run(
                        () => _service.follow(widget.user.id, following),
                      ),
                child: Text(following ? 'Unfollow' : 'Follow'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final service = SocialService.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            tooltip: 'Chat baru',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const FriendsScreen()),
            ),
            icon: const Icon(Icons.edit_square),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.db
            .collection('chats')
            .where('members', arrayContains: service.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(friendlyError(snapshot.error!)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs.toList()
            ..sort(
              (a, b) =>
                  timestamp(
                    b.data()['updatedAt'] ?? b.data()['createdAt'],
                  ).compareTo(
                    timestamp(a.data()['updatedAt'] ?? a.data()['createdAt']),
                  ),
            );
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada chat. Tekan tombol kanan atas untuk cari teman.',
              ),
            );
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, i) {
              final chat = chats[i];
              final other = (chat.data()['members'] as List).firstWhere(
                (id) => id != service.uid,
              ) as String;
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: service.db.collection('users').doc(other).snapshots(),
                builder: (context, user) {
                  final name =
                      user.data?.data()?['username'] as String? ?? 'User';
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('@$name'),
                    subtitle: Text(
                      chat.data()['lastMessage'] as String? ??
                          'Mulai percakapan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ChatScreen(chatId: chat.id, title: '@$name'),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

DateTime timestamp(dynamic value) => value is Timestamp
    ? value.toDate()
    : DateTime.fromMillisecondsSinceEpoch(0);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chatId, required this.title});
  final String chatId, title;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  bool _busy = false;
  int _limit = 50;
  Future<void> _send() async {
    if (_busy || _text.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await SocialService.instance.sendMessage(widget.chatId, _text.text);
      _text.clear();
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = SocialService.instance;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: service.db
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .limit(_limit)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(friendlyError(snapshot.error!)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Kirim pesan pertama kamu.'),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length + 1,
                    itemBuilder: (_, i) {
                      if (i == docs.length) {
                        return docs.length < _limit
                            ? const SizedBox.shrink()
                            : TextButton(
                                onPressed: () => setState(() => _limit += 50),
                                child: const Text('Muat pesan sebelumnya'),
                              );
                      }
                      final data = docs[i].data();
                      final mine = data['senderId'] == service.uid;
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * .78,
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mine
                                ? const Color(0xFF9C3500)
                                : const Color(0xFF292927),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(data['text'] as String? ?? ''),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      enabled: !_busy,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan…',
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kirim',
                    onPressed: _busy ? null : _send,
                    icon: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _limit = 30;
  @override
  Widget build(BuildContext context) {
    final service = SocialService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.db
            .collection('users')
            .doc(service.uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(friendlyError(snapshot.error!)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada notifikasi.'));
          }
          return ListView.builder(
            itemCount: docs.length + 1,
            itemBuilder: (context, i) {
              if (i == docs.length) {
                return docs.length < _limit
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () => setState(() => _limit += 30),
                        child: const Text('Muat lagi'),
                      );
              }
              final doc = docs[i];
              final data = doc.data();
              return ListTile(
                leading: Icon(
                  data['type'] == 'message'
                      ? Icons.chat_bubble_outline
                      : Icons.person_add_outlined,
                ),
                title: Text(data['title'] as String? ?? 'Notifikasi'),
                subtitle: Text(data['body'] as String? ?? ''),
                trailing: data['read'] == true
                    ? null
                    : const Icon(Icons.circle, size: 10, color: Colors.orange),
                onTap: () async {
                  try {
                    await doc.reference.update({'read': true});
                    if (!context.mounted) return;
                    if (data['chatId'] is String) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ChatScreen(
                            chatId: data['chatId'] as String,
                            title: data['title'] as String? ?? 'Chat',
                          ),
                        ),
                      );
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const FriendsScreen(),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) showFailure(context, e);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
