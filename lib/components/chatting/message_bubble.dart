import 'package:flutter/material.dart';
import 'package:twinkle/models/messages_model.dart';
import 'package:twinkle/themes/theme.dart';

class MessageBubble extends StatelessWidget {
  final MessagesModel message;
  final bool isMyMessage;
  final bool showTime;
  final String timeText;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.showTime,
    required this.timeText,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(showTime)...{
          SizedBox(height: 16,),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                timeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTeriaryColor,
                ),
              ),
            ),
          ),

          SizedBox(height: 16,),
        }
        else 
          SizedBox(height: 4,),

        Row(
          mainAxisAlignment: isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
          
          children: [
            if(!isMyMessage)...[
              SizedBox(width: 0,),
            ],
            Flexible(
              child: GestureDetector(
                onLongPress: onLongPress,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width*0.75,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isMyMessage ? AppTheme.secondaryColor : AppTheme.tertiaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message_text,
                        style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: AppTheme.textTeriaryColor,
                          )
                      ),
                    ],
                  )
                )
              )
            ),

            if (isMyMessage)...[
              SizedBox(width: 8,),
              _buildMessageStatus()],
          ],
        ),
      ],
    );
  }


  Widget _buildMessageStatus() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Icon(
        message.is_read ? Icons.done_all : Icons.done,
        size: 16,
        color: message.is_read ? Colors.white :AppTheme.borderColor,
      ),
    );
  }
}
