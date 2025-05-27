import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showTail;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 64 : 0,
          right: isMe ? 0 : 64,
        ),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : (showTail ? 0 : 16)),
            bottomRight: Radius.circular(isMe ? (showTail ? 0 : 16) : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (showTail)
              Positioned(
                right: isMe ? -1 : null,
                left: isMe ? null : -1,
                bottom: 0,
                child: CustomPaint(
                  size: const Size(12, 12),
                  painter: BubbleTailPainter(
                    color: isMe ? Theme.of(context).primaryColor : Colors.white,
                    isMe: isMe,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isMe;

  BubbleTailPainter({required this.color, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isMe) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(size.width, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BubbleTailPainter oldDelegate) =>
      color != oldDelegate.color || isMe != oldDelegate.isMe;
} 