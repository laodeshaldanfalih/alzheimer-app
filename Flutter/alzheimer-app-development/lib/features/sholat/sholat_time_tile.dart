import 'package:flutter/material.dart';

class PrayerTimeTile extends StatelessWidget {
  final String name;
  final String time;
  final bool isCurrent;
  final bool isNext;
  final bool isNotificationOn;
  final VoidCallback onNotificationToggle;

  const PrayerTimeTile({
    super.key,
    required this.name,
    required this.time,
    required this.isCurrent,
    required this.isNext,
    required this.isNotificationOn,
    required this.onNotificationToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isCurrent || isNext ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            color: isCurrent
                ? Colors.blue[700]
                : isNext
                    ? Colors.green[700]
                    : Colors.black,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrent || isNext ? FontWeight.bold : FontWeight.normal,
                color: isCurrent
                    ? Colors.blue[700]
                    : isNext
                        ? Colors.green[700]
                        : Colors.grey[600],
              ),
            ),
            IconButton(
              icon: Icon(
                isNotificationOn
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: isNotificationOn ? Colors.green : Colors.grey,
                size: 20,
              ),
              onPressed: onNotificationToggle,
            ),
          ],
        ),
      ),
    );
  }
}
