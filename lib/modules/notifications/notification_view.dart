import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mr_expense/core/services/update_service.dart';
import 'notification_controller.dart';
import '../../core/constants/app_colors.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলার পুট করা
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.neonGreen, fontSize: 14),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text(
              'No new notifications',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            final isRead = notif.isRead;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRead
                    ? AppColors.surface
                    : AppColors.neonGreen.withValues(
                        alpha: 0.05,
                      ), // ফিক্সড Deprecation
                borderRadius: BorderRadius.circular(15),
                border: isRead
                    ? null
                    : Border.all(
                        color: AppColors.neonGreen.withValues(alpha: 0.3),
                      ),
              ),
              child: InkWell(
                onTap: () {
                  if (notif.actionType == 'update') {
                    // 🔥 ডিরেক্ট সার্ভিস কল
                    final updateService = Get.find<UpdateService>();
                    final remoteConfig = FirebaseRemoteConfig.instance;
                    updateService.showUpdateDialog(
                      remoteConfig.getString('latest_version'),
                      remoteConfig.getString('apk_url'),
                      false,
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: Text(
                        notif.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.neonGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif.message,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _formatTime(notif.timestamp),
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // আপডেট পপআপ ডায়ালগ
  void _showUpdateDialog() {
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Update Available',
      titleStyle: const TextStyle(
        color: AppColors.neonGreen,
        fontWeight: FontWeight.bold,
      ),
      content: const Column(
        children: [
          Icon(Icons.system_update, color: AppColors.neonGreen, size: 50),
          SizedBox(height: 10),
          Text(
            'New features and security fixes are waiting for you!',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
        onPressed: () {
          // এখানে আপডেট ডাউনলোডের লজিক হবে
          Get.back();
        },
        child: const Text('Update Now', style: TextStyle(color: Colors.black)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Later', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
