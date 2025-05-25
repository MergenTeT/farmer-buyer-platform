class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String advertId; // İlgili ilanın ID'si
  final String content;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.advertId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}

class Chat {
  final String id;
  final String user1Id;
  final String user2Id;
  final String advertId;
  final DateTime lastMessageTime;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.advertId,
    required this.lastMessageTime,
    required this.messages,
  });

  // Sohbetin diğer kullanıcısını bulma
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
}

class MessageRepository {
  static final List<Chat> _chats = [];
  static final Map<String, List<String>> _userChats = {}; // userId -> chatIds

  // Yeni mesaj gönderme
  static Message sendMessage({
    required String senderId,
    required String receiverId,
    required String advertId,
    required String content,
  }) {
    // Yeni mesaj oluştur
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      advertId: advertId,
      content: content,
      timestamp: DateTime.now(),
    );

    // Mevcut sohbeti bul veya yeni oluştur
    String? chatId = _findChatId(senderId, receiverId, advertId);
    if (chatId == null) {
      // Yeni sohbet oluştur
      final chat = Chat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user1Id: senderId,
        user2Id: receiverId,
        advertId: advertId,
        lastMessageTime: message.timestamp,
        messages: [message],
      );
      _chats.add(chat);
      chatId = chat.id;

      // Kullanıcı sohbet eşleşmelerini güncelle
      _addUserChat(senderId, chatId);
      _addUserChat(receiverId, chatId);
    } else {
      // Mevcut sohbete mesaj ekle
      final chat = _chats.firstWhere((c) => c.id == chatId);
      chat.messages.add(message);
    }

    return message;
  }

  // Kullanıcının tüm sohbetlerini getir
  static List<Chat> getUserChats(String userId) {
    final chatIds = _userChats[userId] ?? [];
    return _chats
        .where((chat) => chatIds.contains(chat.id))
        .toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  // Belirli bir sohbetin mesajlarını getir
  static List<Message> getChatMessages(String chatId) {
    final chat = _chats.firstWhere((c) => c.id == chatId);
    return chat.messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Okunmamış mesaj sayısını getir
  static int getUnreadMessageCount(String userId) {
    int count = 0;
    final userChatIds = _userChats[userId] ?? [];
    
    for (final chatId in userChatIds) {
      final chat = _chats.firstWhere((c) => c.id == chatId);
      count += chat.messages
          .where((m) => m.receiverId == userId && !m.isRead)
          .length;
    }
    
    return count;
  }

  // Yardımcı metodlar
  static String? _findChatId(String user1Id, String user2Id, String advertId) {
    try {
      final chat = _chats.firstWhere(
        (c) => c.advertId == advertId &&
            ((c.user1Id == user1Id && c.user2Id == user2Id) ||
             (c.user1Id == user2Id && c.user2Id == user1Id))
      );
      return chat.id;
    } catch (e) {
      return null;
    }
  }

  static void _addUserChat(String userId, String chatId) {
    if (!_userChats.containsKey(userId)) {
      _userChats[userId] = [];
    }
    _userChats[userId]!.add(chatId);
  }
} 