import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/chat_session.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';

class ChatSessionsPage extends StatefulWidget {
  const ChatSessionsPage({super.key});

  @override
  State<ChatSessionsPage> createState() => _ChatSessionsPageState();
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadAllSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.bgPrimary,
      appBar: AppBar(
        backgroundColor: ColorConstants.bgPrimary,
        elevation: 0,
        title: Text(
          'Chat History',
          style: GoogleFonts.inter(
            color: ColorConstants.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: ColorConstants.textPrimary),
            onPressed: () => context.push('/chat'),
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.textSecondary,
              ),
            );
          }

          if (state is ChatSessionsLoaded) {
            if (state.sessions.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.sessions.length,
              itemBuilder: (context, index) {
                final session = state.sessions[index];
                return _buildSessionTile(session);
              },
            );
          }

          if (state is ChatError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: ColorConstants.negative,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading chats',
                      style: GoogleFonts.inter(
                        color: ColorConstants.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
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

          return _buildEmptyState();
        },
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
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: ColorConstants.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No chat history',
              style: GoogleFonts.inter(
                color: ColorConstants.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new conversation with the AI assistant',
              style: GoogleFonts.inter(
                color: ColorConstants.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/chat'),
              icon: const Icon(Icons.add),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.textPrimary,
                foregroundColor: ColorConstants.bgPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(ChatSession session) {
    final lastMessage = session.messages.isNotEmpty 
        ? session.messages.last.content 
        : 'New conversation';
    final messagePreview = lastMessage.length > 50 
        ? '${lastMessage.substring(0, 50)}...' 
        : lastMessage;

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ColorConstants.negative,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: ColorConstants.textPrimary,
        ),
      ),
      onDismissed: (direction) {
        context.read<ChatCubit>().deleteSession(session.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ColorConstants.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorConstants.borderSubtle,
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: () => context.push('/chat/${session.id}'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorConstants.bgTertiary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.chat,
              size: 20,
              color: ColorConstants.textSecondary,
            ),
          ),
          title: Text(
            messagePreview,
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            DateFormat('MMM d, h:mm a').format(
              session.lastMessageAt ?? session.createdAt,
            ),
            style: GoogleFonts.inter(
              color: ColorConstants.textTertiary,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: ColorConstants.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }
}