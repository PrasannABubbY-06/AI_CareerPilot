import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/glass_container.dart';
import '../../services/notification_service.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // NotificationService is initialized at app startup, we just consume its notifier.
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
  }

  void _clearAll() {
    _notificationService.clearAll();
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.careerUpdate:
        return Icons.work_outline_rounded;
      case NotificationCategory.resumeInsight:
        return Icons.insert_chart_outlined_rounded;
      case NotificationCategory.learningReminder:
        return Icons.menu_book_rounded;
      case NotificationCategory.goalProgress:
        return Icons.local_fire_department_rounded;
      case NotificationCategory.interviewPrep:
        return Icons.mic_none_rounded;
      case NotificationCategory.systemUpdate:
        return Icons.lightbulb_outline_rounded;
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.careerUpdate:
        return const Color(0xFF3B82F6); // Blue
      case NotificationCategory.resumeInsight:
        return const Color(0xFF10B981); // Green
      case NotificationCategory.learningReminder:
        return const Color(0xFFF59E0B); // Amber
      case NotificationCategory.goalProgress:
        return const Color(0xFFEF4444); // Red
      case NotificationCategory.interviewPrep:
        return const Color(0xFF8B5CF6); // Purple
      case NotificationCategory.systemUpdate:
        return const Color(0xFF06B6D4); // Cyan
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      final min = difference.inMinutes == 0 ? 1 : difference.inMinutes;
      return '${min}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            "No Notifications Yet",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fade(delay: 400.ms),
          const SizedBox(height: 8),
          Text(
            "When you get updates about your career,\nresume, or learning, they'll show up here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
              fontSize: 13,
            ),
          ).animate().fade(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item, int index) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _notificationService.deleteNotification(item.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
      ),
      child: GestureDetector(
        onTap: () {
          if (!item.isRead) {
            _notificationService.markAsRead(item.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            opacity: item.isRead ? 0.02 : 0.08,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(item.isRead ? 0.05 : 0.15),
              width: 1.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withOpacity(item.isRead ? 0.1 : 0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: item.isRead
                        ? null
                        : [
                            BoxShadow(
                              color: _getCategoryColor(item.category).withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: _getCategoryColor(item.category).withOpacity(item.isRead ? 0.6 : 1.0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              color: item.isRead ? (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey) : Colors.white,
                              fontSize: 14,
                              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatTimestamp(item.timestamp),
                            style: GoogleFonts.poppins(
                              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey).withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.message,
                        style: GoogleFonts.poppins(
                          color: item.isRead ? (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey) : Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unread Indicator
                if (!item.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 12, top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 800.ms),
              ],
            ),
          ),
        ).animate().fade(delay: (50 * index).ms, duration: 300.ms).slideX(begin: 0.05, end: 0, delay: (50 * index).ms, duration: 300.ms),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'read_all') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAll();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'read_all',
                child: Row(
                  children: [
                    const Icon(Icons.done_all_rounded, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Text('Mark all read', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 12),
                    Text('Clear all', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: _notificationService.notificationsNotifier,
        builder: (context, notifications, child) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notifications[index], index);
            },
          );
        },
      ),
    );
  }
}
