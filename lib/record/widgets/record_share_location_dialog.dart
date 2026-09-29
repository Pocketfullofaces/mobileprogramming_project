import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' show Position;

Future<void> showShareLocationDialog(
  BuildContext context, {
  required Position position,
}) {
  final link =
      'https://maps.google.com/?q=${position.latitude},${position.longitude}';
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Bagikan Lokasi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live location sharing penuh belum tersedia. Untuk sekarang, '
            'salin link lokasi saat ini dan kirim manual ke temanmu.',
          ),
          const SizedBox(height: 12),
          SelectableText(link),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Tutup'),
        ),
        FilledButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: link));
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: const Text('Salin link'),
        ),
      ],
    ),
  );
}