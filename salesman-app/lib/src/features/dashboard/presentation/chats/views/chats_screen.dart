import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/dashboard/presentation/chats/views/firebase_chat_utils_manager.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseChatUtilsManager _messaging = FirebaseChatUtilsManager();
  late String userId;
  late String managerId;
  List<DocumentSnapshot> messages = [];
  bool isLoadingMore = false;
  bool hasMoreMessages = true;
  final int pageSize = 20;
  double? _lastScrollOffset;

  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser!.uid;
    managerId = 'manager_unique_id';
    super.initState();
  }

  void _loadMoreMessages() async {
    if (isLoadingMore || !hasMoreMessages) return;

    // Save current scroll position
    if (_scrollController.hasClients) {
      _lastScrollOffset = _scrollController.offset;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final lastMessage = messages.isNotEmpty ? messages.last : null;
      if (lastMessage == null) {
        setState(() {
          isLoadingMore = false;
        });
        return;
      }

      final moreMessages = await _messaging.fetchMoreMessages(
        userId,
        lastDocument: lastMessage,
        limit: pageSize,
      );

      setState(() {
        messages.addAll(moreMessages.docs);
        isLoadingMore = false;
        hasMoreMessages = moreMessages.docs.length >= pageSize;
      });

      // Restore scroll position after loading more messages
      if (_scrollController.hasClients && _lastScrollOffset != null) {
        final newOffset =
            _lastScrollOffset! +
            (moreMessages.docs.length * 80.0); // Approximate height per message
        _scrollController.jumpTo(newOffset);
      }
    } catch (e) {
      debugPrint('Error loading more messages: $e');
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "Manager",
      showBottomLine: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.white, Colors.blue.shade50],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messaging.getMessagesStream(userId, limit: pageSize),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading messages'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Update messages only for initial load or new messages
                  if (messages.isEmpty ||
                      snapshot.data!.docs.length > messages.length) {
                    messages = snapshot.data!.docs;
                    // Only auto-scroll for initial load or new messages
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients &&
                          _lastScrollOffset == null) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: messages.length + (hasMoreMessages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (hasMoreMessages && index == messages.length) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: _loadMoreMessages,
                            child: isLoadingMore
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'View Previous Messages',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        );
                      }

                      final message = messages[index];
                      final isUser = message['senderId'] == userId;

                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['text'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isUser
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _messaging.formatTimestamp(
                                    message['timestamp'],
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUser
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _messaging.sendMessage(
                      userId: userId,
                      managerId: managerId,
                      text: _messageController.text.trim(),
                      onSuccess: () {
                        _messageController.clear();
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    icon: AppIcons.getIcon(AppIcons.arrowRight, size: 30),
                  ),
                ],
              ),
            ),
            const GapV(16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
