import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool validUsername(String value) =>
    RegExp(r'^[a-zA-Z0-9_.]{3,20}$').hasMatch(value.trim());

String friendlyError(Object error) {
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => 'Akses database ditolak. Pastikan rules Firebase sudah dipasang dan kamu sudah login. Username juga mungkin sudah digunakan.',
      'unavailable' || 'network-request-failed' =>
        'Koneksi gagal. Periksa internet lalu coba lagi.',
      'email-already-in-use' =>
        'Username sudah digunakan. Pilih username lain.',
      'weak-password' => 'Password terlalu lemah. Gunakan minimal 6 karakter.',
      'invalid-credential' ||
      'unauthenticated' ||
      'wrong-password' ||
      'user-not-found' => 'Username atau password salah.',
      'already-exists' => 'Username sudah digunakan. Pilih username lain.',
      'resource-exhausted' || 'too-many-requests' =>
        'Terlalu banyak percobaan. Tunggu 15 menit lalu coba lagi.',
      'not-found' => 'Username tidak ditemukan.',
      'internal' => 'Layanan Firebase sedang bermasalah. Coba lagi nanti.',
      'operation-not-allowed' =>
        'Aktifkan Email/Password di Firebase Authentication.',
      'failed-precondition' => 'Konfigurasi atau index Firebase belum siap.',
      _ => 'Proses gagal (${error.code}). Coba lagi.',
    };
  }
  return error is StateError
      ? error.message.toString()
      : 'Proses gagal. Silakan coba lagi.';
}

class SocialService {
  SocialService._();
  static final instance = SocialService._();
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  String get uid =>
      auth.currentUser?.uid ??
      (throw StateError('Silakan login terlebih dahulu.'));

  String _authEmailForUsername(String username) =>
      '${username.trim().toLowerCase()}@mobileprog.app';

  Future<void> register(String username, String email, String password) async {
    final name = username.trim();
    if (!validUsername(name)) throw StateError('Username tidak valid.');
    final gmail = email.trim().toLowerCase();
    final credential = await auth.createUserWithEmailAndPassword(
      email: _authEmailForUsername(name),
      password: password,
    );
    final user = credential.user!;
    try {
      final batch = db.batch();
      batch.set(db.collection('usernames').doc(name.toLowerCase()), {
        'uid': user.uid,
      });
      batch.set(db.collection('users').doc(user.uid), {
        'username': name,
        'usernameLowercase': name.toLowerCase(),
        'displayName': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(db.collection('privateUsers').doc(user.uid), {
        'gmail': gmail,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (e) {
      try {
        await user.delete();
      } catch (_) {
        throw StateError(
          'Profil gagal disimpan. Minta admin memeriksa akun Authentication sebelum register ulang.',
        );
      }
      rethrow;
    } finally {
      await auth.signOut();
    }
  }

  Future<void> login(String username, String password) async {
    final name = username.trim().toLowerCase();
    if (!validUsername(name)) throw StateError('Username tidak valid.');
    await auth.signInWithEmailAndPassword(
      email: _authEmailForUsername(name),
      password: password,
    );
    try {
      if (!(await db.collection('users').doc(uid).get()).exists) {
        throw StateError(
          'Profil akun belum tersedia. Hubungi pengelola aplikasi.',
        );
      }
    } catch (_) {
      await auth.signOut();
      rethrow;
    }
  }

  Future<void> publish({
    required String kind,
    required String caption,
    Uint8List? photo,
    String? contentType,
    double?  distance,
    int? minutes,
  }) async {
    final owner = uid;
    final profile = (await db.collection('users').doc(owner).get()).data();
    if (profile == null) {
      throw StateError('Profil belum tersedia. Silakan login ulang.');
    }
    String? photoData;
    if (photo != null) {
      photoData = base64Encode(photo);
      if (photoData.length > 800000) {
        throw StateError('Foto terlalu besar. Pilih foto yang lebih kecil.');
      }
    }
    await db.collection('activities').add({
      'userId': owner,
      'userName': profile['username'],
      'kind': kind,
      'caption': caption.trim(),
      'type': kind == 'activity' ? 'Activity' : 'Post',
      'createdAt': FieldValue.serverTimestamp(),
      'photoData': ?photoData,
      'photoContentType': ?(photoData == null
          ? null
          : contentType ?? 'image/jpeg'),
      if (kind == 'activity') 'distanceKm': distance,
      if (kind == 'activity') 'durationMinutes': minutes,
    });
  }

  Future<void> follow(String target, bool following) async {
    if (target == uid) return;
    final followingRef = db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(target);
    final followerRef = db
        .collection('users')
        .doc(target)
        .collection('followers')
        .doc(uid);
    if (following) {
      final batch = db.batch()
        ..delete(followingRef)
        ..delete(followerRef);
      await batch.commit();
    } else {
      final batch = db.batch()
        ..set(followingRef, {'createdAt': FieldValue.serverTimestamp()})
        ..set(followerRef, {'createdAt': FieldValue.serverTimestamp()});
      await batch.commit();
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String country,
    required String city,
    required String bio,
    required String birthDate,
    required String gender,
    Uint8List? photo,
    bool removePhoto = false,
  }) async {
    final data = <String, dynamic>{
      'displayName': displayName.trim().isEmpty
          ? (auth.currentUser?.email?.split('@').first ?? 'User')
          : displayName.trim(),
      'country': country.trim(),
      'city': city.trim(),
      'bio': bio.trim(),
      'birthDate': birthDate,
      'gender': gender,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (removePhoto) {
      data['photoData'] = FieldValue.delete();
    } else if (photo != null) {
      final encoded = base64Encode(photo);
      if (encoded.length > 800000) {
        throw StateError('Foto terlalu besar. Pilih foto yang lebih kecil.');
      }
      data['photoData'] = encoded;
    }
    await db.collection('users').doc(uid).update(data);
  }

  Future<String> chatWith(String target) async {
    if (target == uid) throw StateError('Pilih akun orang lain.');
    final members = [uid, target]..sort();
    final id = members.join('_');
    final ref = db.collection('chats').doc(id);
    await db.runTransaction((tx) async {
      if (!(await tx.get(ref)).exists) {
        tx.set(ref, {
          'members': members,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
    return id;
  }

  Future<void> sendMessage(String chatId, String text) async {
    final content = text.trim();
    if (content.isEmpty || content.length > 2000) {
      throw StateError('Pesan harus berisi 1–2000 karakter.');
    }
    await db.collection('chats').doc(chatId).collection('messages').add({
      'senderId': uid,
      'text': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
