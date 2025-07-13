import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/color_constants.dart';

class EnhancedChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isEnabled;

  const EnhancedChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  State<EnhancedChatInput> createState() => _EnhancedChatInputState();
}

class _EnhancedChatInputState extends State<EnhancedChatInput> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    if (_hasText && widget.isEnabled) {
      HapticFeedback.lightImpact(); // Haptic feedback on send
      widget.onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: ColorConstants.bgSecondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.isEnabled,
                maxLines: 4,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Material(
              color: _hasText && widget.isEnabled
                  ? ColorConstants.textPrimary
                  : ColorConstants.bgSecondary,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: widget.isEnabled
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _hasText
                              ? Icon(
                                  Icons.send,
                                  key: const ValueKey('send'),
                                  size: 20,
                                  color: ColorConstants.bgPrimary,
                                )
                              : Icon(
                                  Icons.send,
                                  key: const ValueKey('send-disabled'),
                                  size: 20,
                                  color: ColorConstants.textTertiary,
                                ),
                        )
                      : const SizedBox(
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
          ),
        ],
      ),
    );
  }
}