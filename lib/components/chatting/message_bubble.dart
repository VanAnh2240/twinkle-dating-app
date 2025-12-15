import 'package:flutter/material.dart';
import 'package:twinkle/models/messages_model.dart';
import 'package:twinkle/themes/theme.dart';

class MessageBubble extends StatelessWidget {
  final MessagesModel message;
  final bool isMyMessage;
  final bool showTime;
  final String timeText;
  
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.showTime,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(showTime)...{
          SizedBox(height: 16),
          Center(
            child: Container(
              child: Text(
                timeText,
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        }
        else 
          SizedBox(height: 2),
        Row(
          mainAxisAlignment: isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
          
          children: [
            if(!isMyMessage)...[
              SizedBox(width: 0),
            ],
            Flexible(
              child: GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isMyMessage 
                      ? const Color.fromARGB(255, 133, 165, 234)  
                      : Color.fromARGB(255, 224, 132, 224), 
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message_text,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        )
                      ),
                    ],
                  )
                )
              )
            ),

            if (isMyMessage)...[
              SizedBox(width: 5),
              _buildMessageStatus()
            ],
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
        color: Color(0xFF8B8B8B),
      ),
    );
  }
}