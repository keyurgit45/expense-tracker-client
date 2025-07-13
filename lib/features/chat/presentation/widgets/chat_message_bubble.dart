import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showTimestamp)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              DateFormat('MMM d, h:mm a').format(message.timestamp),
              style: GoogleFonts.inter(
                color: ColorConstants.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        Row(
          mainAxisAlignment:
              message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorConstants.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 18,
                  color: ColorConstants.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? ColorConstants.textPrimary
                      : ColorConstants.bgSecondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 16),
                  ),
                ),
                child: Text(
                  message.content,
                  style: GoogleFonts.inter(
                    color: message.isUser
                        ? ColorConstants.bgPrimary
                        : ColorConstants.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorConstants.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: ColorConstants.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}