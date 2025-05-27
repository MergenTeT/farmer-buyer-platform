import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  // JSON dönüşümleri
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'advertId': advertId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      advertId: json['advertId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }
}

class Chat {
  final String id;
  final String user1Id;
  final String user2Id;
  final String advertId;
  DateTime lastMessageTime;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.advertId,
    required this.lastMessageTime,
    required this.messages,
  });

  // JSON dönüşümleri
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'advertId': advertId,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      user1Id: json['user1Id'],
      user2Id: json['user2Id'],
      advertId: json['advertId'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
    );
  }

  // Sohbetin diğer kullanıcısını bulma
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
}

class MessageRepository {
  static const String _chatsKey = 'chats';
  static const String _userChatsKey = 'user_chats';
  static List<Chat> _chats = [];
  static Map<String, List<String>> _userChats = {};
  static SharedPreferences? _prefs;

  // SharedPreferences'ı başlat
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  // Verileri yükle
  static Future<void> _loadData() async {
    final prefs = _prefs;
    if (prefs == null) return;

    // Sohbetleri yükle
    final chatsJson = prefs.getString(_chatsKey);
    if (chatsJson != null) {
      final chatsList = jsonDecode(chatsJson) as List;
      _chats = chatsList.map((json) => Chat.fromJson(json)).toList();
    }

    // Kullanıcı sohbetlerini yükle
    final userChatsJson = prefs.getString(_userChatsKey);
    if (userChatsJson != null) {
      final userChatsMap = jsonDecode(userChatsJson) as Map<String, dynamic>;
      _userChats = Map.fromEntries(
        userChatsMap.entries.map(
          (e) => MapEntry(e.key, List<String>.from(e.value)),
        ),
      );
    }
  }

  // Verileri kaydet
  static Future<void> _saveData() async {
    final prefs = _prefs;
    if (prefs == null) return;

    // Sohbetleri kaydet
    final chatsJson = jsonEncode(_chats.map((chat) => chat.toJson()).toList());
    await prefs.setString(_chatsKey, chatsJson);

    // Kullanıcı sohbetlerini kaydet
    final userChatsJson = jsonEncode(_userChats);
    await prefs.setString(_userChatsKey, userChatsJson);
  }

  // Yeni mesaj gönderme
  static Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String advertId,
    required String content,
  }) async {
    await init(); // Repository'yi başlat

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      advertId: advertId,
      content: content,
      timestamp: DateTime.now(),
    );

    String? chatId = _findChatId(senderId, receiverId, advertId);
    if (chatId == null) {
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

      _addUserChat(senderId, chatId);
      _addUserChat(receiverId, chatId);
    } else {
      final chat = _chats.firstWhere((c) => c.id == chatId);
      chat.messages.add(message);
      chat.lastMessageTime = message.timestamp;
    }

    await _saveData(); // Değişiklikleri kaydet
    return message;
  }

  // Kullanıcının tüm sohbetlerini getir
  static Future<List<Chat>> getUserChats(String userId) async {
    await init(); // Repository'yi başlat
    final chatIds = _userChats[userId] ?? [];
    return _chats
        .where((chat) => chatIds.contains(chat.id))
        .toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  // Belirli bir sohbetin mesajlarını getir
  static Future<List<Message>> getChatMessages(String chatId) async {
    await init(); // Repository'yi başlat
    final chat = _chats.firstWhere((c) => c.id == chatId);
    return chat.messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Okunmamış mesaj sayısını getir
  static Future<int> getUnreadMessageCount(String userId) async {
    await init(); // Repository'yi başlat
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