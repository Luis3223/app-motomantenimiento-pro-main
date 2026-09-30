import 'package:flutter/material.dart';

import '../data/models/oil_status.dart';
import '../theme/app_theme.dart';

class NotificationBanner extends StatelessWidget {
  const NotificationBanner({
    super.key,
    required this.alert,
    required this.onDismiss,
  });

  final InAppNotification? alert;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: alert == null ? const Offset(0, -1.2) : Offset.zero,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: alert == null
              ? const SizedBox.shrink()
              : Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.surfaceMatte,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onDismiss,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.strongRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              color: AppColors.strongRed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  alert!.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  alert!.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            alert!.date,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
