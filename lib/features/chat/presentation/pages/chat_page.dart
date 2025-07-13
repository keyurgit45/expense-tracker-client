import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/injection.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';
import '../widgets/animated_message_bubble.dart';
import '../widgets/enhanced_chat_input.dart';
import '../widgets/typing_indicator.dart';

class ChatPage extends StatefulWidget {
  final String? sessionId;

  const ChatPage({super.key, this.sessionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final cubit = context.read<ChatCubit>();
    if (widget.sessionId != null) {
      cubit.loadSession(widget.sessionId!);
    } else {
      cubit.startNewChat();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatCubit>().sendChatMessage(message);
      _messageController.clear();
      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: Scaffold(
        backgroundColor: ColorConstants.bgPrimary,
        appBar: AppBar(
          backgroundColor: ColorConstants.bgPrimary,
          elevation: 0,
          title: Text(
            'AI Assistant',
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: ColorConstants.textPrimary),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) {
              return _buildUnauthenticatedView();
            }

            return BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: ColorConstants.primary,
                    ),
                  );
                  // If there's a last session, restore it
                  if (state.lastSession != null) {
                    context
                        .read<ChatCubit>()
                        .loadSession(state.lastSession!.id);
                  }
                } else if (state is ChatLoaded) {
                  // Scroll to bottom when new messages arrive
                  Future.delayed(
                      const Duration(milliseconds: 100), _scrollToBottom);
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.primary,
                    ),
                  );
                }

                if (state is ChatLoaded) {
                  return Column(
                    children: [
                      Expanded(
                        child: state.session.messages.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 20,
                                  bottom: state.isSending ? 0 : 20,
                                ),
                                itemCount: state.session.messages.length +
                                    (state.isSending ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.session.messages.length &&
                                      state.isSending) {
                                    return const TypingIndicator();
                                  }
                                  final message = state.session.messages[index];
                                  return AnimatedMessageBubble(
                                    message: message,
                                    index: index,
                                    showTimestamp: index == 0 ||
                                        message.timestamp
                                                .difference(
                                                  state
                                                      .session
                                                      .messages[index - 1]
                                                      .timestamp,
                                                )
                                                .inMinutes >
                                            5,
                                  );
                                },
                              ),
                      ),
                      EnhancedChatInput(
                        controller: _messageController,
                        onSend: _sendMessage,
                        isEnabled: !state.isSending,
                      ),
                    ],
                  );
                }

                return _buildEmptyState();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: ColorConstants.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation...',
              style: GoogleFonts.inter(
                color: ColorConstants.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about your expenses, spending patterns, or financial advice',
              style: GoogleFonts.inter(
                color: ColorConstants.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: ColorConstants.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Required',
              style: GoogleFonts.inter(
                color: ColorConstants.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please sign in to access the AI assistant',
              style: GoogleFonts.inter(
                color: ColorConstants.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.surface3,
                foregroundColor: ColorConstants.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: ColorConstants.borderStrong,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Go to Settings',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
