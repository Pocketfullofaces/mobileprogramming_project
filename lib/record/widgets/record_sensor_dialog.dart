import 'package:flutter/material.dart';

Future<int?> showSensorDialog(BuildContext context, {int? current}) {
  final controller = TextEditingController(
    text: current == null ? '' : current.toString(),
  );
  return showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Input Detak Jantung'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Belum ada sensor Bluetooth yang terhubung ke aplikasi ini. '
            'Untuk sementara, masukkan detak jantung secara manual (bpm).',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Detak jantung (bpm)',
            ),
          ),
        ],
      ),
      actions: [
        if (current != null)
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, -1),
            child: const Text('Hapus'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final value = int.tryParse(controller.text.trim());
            if (value == null || value <= 0 || value > 250) return;
            Navigator.pop(dialogContext, value);
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}