import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/social_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.kind});
  final String kind;
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _form = GlobalKey<FormState>();
  final _caption = TextEditingController();
  final _distance = TextEditingController();
  final _minutes = TextEditingController();
  Uint8List? _photo;
  String? _mime, _error;
  bool _busy = false;

  Future<void> _pick() async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 45,
      );
      if (photo == null) return;
      final bytes = await photo.readAsBytes();
      if (bytes.length > 600 * 1024) {
        throw StateError('Pilih foto berukuran maksimal 600 KB.');
      }
      final mime =
          photo.mimeType ??
          (photo.name.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');
      if (!mounted) return;
      setState(() {
        _photo = bytes;
        _mime = mime;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    }
  }

  Future<void> _publish() async {
    if (!_form.currentState!.validate()) return;
    if (widget.kind == 'photo' && _photo == null) {
      setState(() => _error = 'Pilih foto terlebih dahulu.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SocialService.instance.publish(
        kind: widget.kind,
        caption: _caption.text,
        photo: _photo,
        contentType: _mime,
        distance: double.tryParse(_distance.text.replaceAll(',', '.')),
        minutes: int.tryParse(_minutes.text),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    _distance.dispose();
    _minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.kind) {
          'photo' => 'Post foto',
          'activity' => 'Catat aktivitas',
          _ => 'Buat post',
        }),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _caption,
              enabled: !_busy,
              minLines: 3,
              maxLines: 6,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'Ceritakan aktivitasmu',
              ),
              validator: (v) =>
                  widget.kind == 'text' && (v ?? '').trim().isEmpty
                  ? 'Isi post terlebih dahulu.'
                  : null,
            ),
            if (widget.kind == 'photo') ...[
              if (_photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_photo!, height: 260, fit: BoxFit.cover),
                ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _photo == null ? 'Pilih foto dari galeri' : 'Ganti foto',
                ),
              ),
            ],
            if (widget.kind == 'activity') ...[
              const Text(
                'Catat aktivitas yang sudah kamu selesaikan hari ini. Aktivitas menambah streak maksimal satu kali per hari.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distance,
                enabled: !_busy,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Jarak (km)'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return n == null || !n.isFinite || n <= 0 || n > 1000
                      ? 'Isi jarak lebih dari 0, maksimal 1000 km.'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minutes,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Durasi (menit)'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return n == null || n <= 0 || n > 1440
                      ? 'Isi durasi 1-1440 menit.'
                      : null;
                },
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _publish,
              child: Text(_busy ? 'Menyimpan…' : 'Bagikan'),
            ),
          ],
        ),
      ),
    ),
  );
}
