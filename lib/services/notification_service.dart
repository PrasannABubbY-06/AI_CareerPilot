import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationCategory {
  careerUpdate,
  resumeInsight,
  learningReminder,
  goalProgress,
  interviewPrep,
  systemUpdate,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      category: NotificationCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => NotificationCategory.systemUpdate,
      ),
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<NotificationItem>> notificationsNotifier = ValueNotifier<List<NotificationItem>>([]);

  Future<void> initialize() async {
    await loadLocalNotifications();
    _listenToFirebaseNotifications();
  }

  Future<void> loadLocalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('saved_notifications');
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        notificationsNotifier.value = decoded.map((e) => NotificationItem.fromMap(e)).toList();
        _updateUnreadCount();
      } catch (e) {
        debugPrint('Error parsing notifications: $e');
      }
    }
  }

  Future<void> _saveLocalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = notificationsNotifier.value.map((e) => e.toMap()).toList();
    await prefs.setString('saved_notifications', jsonEncode(data));
    _updateUnreadCount();
  }

  void _listenToFirebaseNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      
      final currentList = List<NotificationItem>.from(notificationsNotifier.value);
      bool changed = false;

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final newItem = NotificationItem.fromMap({
            'id': change.doc.id,
            ...data,
          });

          final index = currentList.indexWhere((n) => n.id == newItem.id);
          if (index == -1) {
            currentList.insert(0, newItem);
            changed = true;
          }
        } else if (change.type == DocumentChangeType.removed) {
          currentList.removeWhere((n) => n.id == change.doc.id);
          changed = true;
        } else if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data()!;
          final index = currentList.indexWhere((n) => n.id == change.doc.id);
          if (index != -1) {
             currentList[index] = NotificationItem.fromMap({
               'id': change.doc.id,
               ...data,
             });
             changed = true;
          }
        }
      }
      
      if (changed) {
        // Sort
        currentList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notificationsNotifier.value = currentList;
        _saveLocalNotifications();
      }
    });
  }

  Future<void> sendNotification({
    required String title,
    required String message,
    required NotificationCategory category,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'category': category.name,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });
    } catch (e) {
      debugPrint('Failed to send notification: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    final currentList = List<NotificationItem>.from(notificationsNotifier.value);
    final index = currentList.indexWhere((n) => n.id == id);
    if (index != -1) {
      currentList[index].isRead = true;
      notificationsNotifier.value = currentList;
      await _saveLocalNotifications();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('notifications')
              .doc(id)
              .update({'isRead': true});
        } catch (_) {}
      }
    }
  }

  Future<void> markAllAsRead() async {
    final currentList = List<NotificationItem>.from(notificationsNotifier.value);
    for (var n in currentList) {
      n.isRead = true;
    }
    notificationsNotifier.value = currentList;
    await _saveLocalNotifications();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final query = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .where('isRead', isEqualTo: false)
            .get();
        for (var doc in query.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      } catch (_) {}
    }
  }

  Future<void> deleteNotification(String id) async {
    final currentList = List<NotificationItem>.from(notificationsNotifier.value);
    currentList.removeWhere((n) => n.id == id);
    notificationsNotifier.value = currentList;
    await _saveLocalNotifications();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(id)
            .delete();
      } catch (_) {}
    }
  }

  Future<void> clearAll() async {
    notificationsNotifier.value = [];
    await _saveLocalNotifications();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final query = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .get();
        for (var doc in query.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (_) {}
    }
  }

  void _updateUnreadCount() {
    unreadCountNotifier.value = notificationsNotifier.value.where((n) => !n.isRead).length;
  }
}
