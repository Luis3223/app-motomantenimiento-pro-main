class OilChangeStatus {
  const OilChangeStatus({
    required this.lastServiceDate,
    required this.daysElapsed,
    required this.daysRemaining,
    required this.progress,
    required this.statusText,
    required this.isDue,
    required this.isWarning,
  });

  final String lastServiceDate;
  final int daysElapsed;
  final int daysRemaining;
  final double progress;
  final String statusText;
  final bool isDue;
  final bool isWarning;
}

enum FirebaseSyncStatus { onlineSynced, pending, offline }

class InAppNotification {
  const InAppNotification({
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });

  final String title;
  final String message;
  final String date;
  final bool isRead;
}
