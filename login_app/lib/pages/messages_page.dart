import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user_model.dart';
import '../models/advertisement.dart';
import '../widgets/message_bubble.dart';
import 'advert_detail_page.dart';

class MessagesPage extends StatefulWidget {
  final String userEmail;

  const MessagesPage({super.key, required this.userEmail});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  User? _currentUser;
  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    _currentUser = UserRepository.findUserByEmail(widget.userEmail);
    if (_currentUser != null) {
      final userChats = await MessageRepository.getUserChats(_currentUser!.id);
      setState(() {
        _chats = userChats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: Text('Kullanıcı bulunamadı'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: _chats.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 200),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Henüz mesajınız yok',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final otherUserId = chat.getOtherUserId(_currentUser!.id);
                final otherUser = UserRepository.findUserById(otherUserId);
                final advert = AdvertRepository.findById(chat.advertId);

                if (otherUser == null || advert == null) return const SizedBox();

                final lastMessage = chat.messages.last;
                final unreadCount = chat.messages
                    .where((m) =>
                        m.receiverId == _currentUser!.id && !m.isRead)
                    .length;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Text(
                        otherUser.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(otherUser.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advert.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          lastMessage.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(lastMessage.timestamp),
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chat: chat,
                            currentUser: _currentUser!,
                            otherUser: otherUser,
                            advertisement: advert,
                          ),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Dün';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

class ChatPage extends StatefulWidget {
  final Chat chat;
  final User currentUser;
  final User otherUser;
  final Advertisement advertisement;

  const ChatPage({
    super.key,
    required this.chat,
    required this.currentUser,
    required this.otherUser,
    required this.advertisement,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    final messages = await MessageRepository.getChatMessages(widget.chat.id);
    setState(() {
      _messages = messages;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Text(
                widget.otherUser.name[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.advertisement.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // İlan detayına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdvertDetailPage(
                    advertisement: widget.advertisement,
                    currentUserEmail: widget.currentUser.email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.senderId == widget.currentUser.id;
                  final showDate = index == 0 || 
                    !_isSameDay(_messages[index - 1].timestamp, message.timestamp);

                  return Column(
                    children: [
                      if (showDate) _buildDateDivider(message.timestamp),
                      MessageBubble(
                        message: message,
                        isMe: isMe,
                        showTail: true,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_camera),
                    onPressed: () {
                      // Kamera/galeri özelliği eklenecek
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Mesaj yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      final content = _messageController.text.trim();
                      if (content.isNotEmpty) {
                        await MessageRepository.sendMessage(
                          senderId: widget.currentUser.id,
                          receiverId: widget.otherUser.id,
                          advertId: widget.advertisement.id,
                          content: content,
                        );
                        _messageController.clear();
                        _loadMessages();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _formatDateForDivider(date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  String _formatDateForDivider(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (_isSameDay(date, now)) {
      return 'Bugün';
    } else if (_isSameDay(date, yesterday)) {
      return 'Dün';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
} 