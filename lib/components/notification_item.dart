import 'package:flutter/material.dart';
import 'package:twinkle/models/notifications_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/themes/theme.dart';

class NotificationItem extends StatelessWidget {
  final NotificationsModel notification;
  final UsersModel? user;
  final String timeText;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.user,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.is_read
          ? null
          : AppTheme.secondaryColor.withOpacity(0.05), 
      child: InkWell(
        onTap: onTap, 
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
              ), 
              
              SizedBox(width: 16,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.notification_text,
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ),
                        if (!notification.is_read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(4),
                            )
                          ),
                      ],
                    )
                  ],
                )
              ),
            ],
          ), 
        ), 
      ), 
    ); 
  }
}