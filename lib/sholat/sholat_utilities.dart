import 'package:flutter/material.dart';

class AppBarMoreOptions extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback? onTestNotification;

  const AppBarMoreOptions({
    super.key,
    required this.onRefresh,
    this.onTestNotification,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        if (value == 1) {
          onRefresh();
        } else if (value == 2 && onTestNotification != null) {
          onTestNotification!();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Refresh Halaman'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('Tes Notifikasi 10 detik'),
        ),
      ],
    );
  }
}

class NotificationToggleCheckbox extends StatelessWidget {
  final bool allEnabled;
  final ValueChanged<bool?> onChanged;

  const NotificationToggleCheckbox({
    super.key,
    required this.allEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: allEnabled, onChanged: onChanged),
        const Text(
          'Aktifkan semua notifikasi',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
