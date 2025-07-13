import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/color_constants.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isEnabled;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConstants.bgPrimary,
        border: Border(
          top: BorderSide(
            color: ColorConstants.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstants.bgSecondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                enabled: isEnabled,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: GoogleFonts.inter(
                  color: ColorConstants.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about your expenses...',
                  hintStyle: GoogleFonts.inter(
                    color: ColorConstants.textTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: isEnabled
                ? ColorConstants.textPrimary
                : ColorConstants.bgSecondary,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: isEnabled ? onSend : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: isEnabled
                    ? Icon(
                        Icons.send,
                        size: 20,
                        color: ColorConstants.bgPrimary,
                      )
                    : SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorConstants.textTertiary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}