import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class TopbarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const TopbarWidget({super.key, required this.title});

  @override
  State<TopbarWidget> createState() => _TopbarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopbarWidgetState extends State<TopbarWidget> {

  void openNotifications() {
    Navigator.pushNamed(context, "/notifications");
  }

  void openProfile() {
    Navigator.pushNamed(context, "/profile");
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      backgroundColor: const Color(0xff0B1020),

      actions: [

        // 🔔 BELL ICON with Badge
        ValueListenableBuilder<int>(
          valueListenable: NotificationService().unreadCountNotifier,
          builder: (context, unreadCount, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: openNotifications,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // 👤 PROFILE OPEN
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: openProfile,
        ),
      ],
    );
  }
}