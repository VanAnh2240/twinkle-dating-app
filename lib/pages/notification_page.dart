import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:twinkle/components/notification_item.dart';
import 'package:twinkle/controllers/notification_controller.dart';
import 'package:twinkle/themes/theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());
  }
  @override
  void dispose() {
    Get.delete<NotificationController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          Obx(() {
            final unreadCount = controller.getUnreadCount();
            return unreadCount > 0 
                ? TextButton(
                    onPressed: controller.markAllAsRead,
                    child: Icon(Icons.done_all_outlined, size: 25),
                  )
                : SizedBox.shrink();
          }), 
        ], 
      ), 
      body: Obx((){
        if(controller.notifications.isEmpty){
          return _buildEmptyState();
        }
        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            final user = controller.getUser(notification.user_id);

            return NotificationItem(
              notification: notification,
              user: user,
              timeText: controller.getNotificationTimeText(notification.sent_at),
              onTap: () => controller.handleNotificationTap(notification),
            );
          },
        );
      }),
    );
  }

   Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.notifications_rounded,
                size: 30,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.secondaryColor, 
              ),
            ),
            SizedBox(height: 24),
            Text(
              'When you got a match, messages or other updates, they will appear here',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor, 
              ),
            ),
          ],
        ), 
      ),
    );
  }
}
