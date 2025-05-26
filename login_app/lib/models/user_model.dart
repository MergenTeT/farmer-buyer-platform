import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum UserType {
  farmer('Çiftçi'),
  buyer('Alıcı');

  final String displayName;
  const UserType(this.displayName);
}

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserType userType;
  UserProfile? profile;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    this.profile,
  });

  // JSON dönüşümleri için
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'userType': userType.index,
      'profile': profile?.toJson(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      userType: UserType.values[json['userType']],
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
    );
  }

  // Kullanıcı ID'sini getir
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class UserProfile {
  final String phoneNumber; // +90 ile başlayan telefon numarası
  final String city; // İl
  final String district; // İlçe
  final String detailedAddress; // Detaylı adres
  final String? companyName; // Şirket adı (opsiyonel)
  final String? taxNumber; // Vergi numarası (opsiyonel)
  final String? about; // Hakkında
  final String? profileImage; // Profil fotoğrafı
  final DateTime createdAt;
  final List<String> favorites; // Favori ilanlar
  final double rating; // Değerlendirme puanı (5 üzerinden)
  final int ratingCount; // Toplam değerlendirme sayısı
  final int totalAdverts; // Toplam ilan sayısı
  final bool isActive; // Aktiflik durumu

  UserProfile({
    required this.phoneNumber,
    required this.city,
    required this.district,
    required this.detailedAddress,
    this.companyName,
    this.taxNumber,
    this.about,
    this.profileImage,
    required this.createdAt,
    List<String>? favorites,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.totalAdverts = 0,
    this.isActive = true,
  }) : favorites = favorites ?? [];

  // JSON dönüşümleri için
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'city': city,
      'district': district,
      'detailedAddress': detailedAddress,
      'companyName': companyName,
      'taxNumber': taxNumber,
      'about': about,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'favorites': favorites,
      'rating': rating,
      'ratingCount': ratingCount,
      'totalAdverts': totalAdverts,
      'isActive': isActive,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      phoneNumber: json['phoneNumber'],
      city: json['city'],
      district: json['district'],
      detailedAddress: json['detailedAddress'],
      companyName: json['companyName'],
      taxNumber: json['taxNumber'],
      about: json['about'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      favorites: List<String>.from(json['favorites']),
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      totalAdverts: json['totalAdverts'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  // Telefon numarası doğrulama
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+90[0-9]{10}$');
    return phoneRegex.hasMatch(phone);
  }

  // Üyelik süresini hesapla
  String getMembershipDuration() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} gün';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl';
    }
  }
}

// Türkiye'deki iller ve ilçeler
class TurkishLocations {
  static const Map<String, List<String>> citiesAndDistricts = {
    'Adana': ['Aladağ', 'Ceyhan', 'Çukurova', 'Feke', 'İmamoğlu', 'Karaisalı', 'Karataş', 'Kozan', 'Pozantı', 'Saimbeyli', 'Sarıçam', 'Seyhan', 'Tufanbeyli', 'Yumurtalık', 'Yüreğir'],
    'Adıyaman': ['Besni', 'Çelikhan', 'Gerger', 'Gölbaşı', 'Kahta', 'Merkez', 'Samsat', 'Sincik', 'Tut'],
    'Afyonkarahisar': ['Başmakçı', 'Bayat', 'Bolvadin', 'Çay', 'Çobanlar', 'Dazkırı', 'Dinar', 'Emirdağ', 'Evciler', 'Hocalar', 'İhsaniye', 'İscehisar', 'Kızılören', 'Merkez', 'Sandıklı', 'Sinanpaşa', 'Sultandağı', 'Şuhut'],
    'Ağrı': ['Diyadin', 'Doğubayazıt', 'Eleşkirt', 'Hamur', 'Merkez', 'Patnos', 'Taşlıçay', 'Tutak'],
    'Amasya': ['Göynücek', 'Gümüşhacıköy', 'Hamamözü', 'Merkez', 'Merzifon', 'Suluova', 'Taşova'],
    'Ankara': ['Akyurt', 'Altındağ', 'Ayaş', 'Bala', 'Beypazarı', 'Çamlıdere', 'Çankaya', 'Çubuk', 'Elmadağ', 'Etimesgut', 'Evren', 'Gölbaşı', 'Güdül', 'Haymana', 'Kalecik', 'Kazan', 'Keçiören', 'Kızılcahamam', 'Mamak', 'Nallıhan', 'Polatlı', 'Pursaklar', 'Sincan', 'Şereflikoçhisar', 'Yenimahalle'],
    'Antalya': ['Akseki', 'Aksu', 'Alanya', 'Demre', 'Döşemealtı', 'Elmalı', 'Finike', 'Gazipaşa', 'Gündoğmuş', 'İbradı', 'Kaş', 'Kemer', 'Kepez', 'Konyaaltı', 'Korkuteli', 'Kumluca', 'Manavgat', 'Muratpaşa', 'Serik'],
    'Artvin': ['Ardanuç', 'Arhavi', 'Borçka', 'Hopa', 'Kemalpaşa', 'Merkez', 'Murgul', 'Şavşat', 'Yusufeli'],
    'Aydın': ['Bozdoğan', 'Buharkent', 'Çine', 'Didim', 'Efeler', 'Germencik', 'İncirliova', 'Karacasu', 'Karpuzlu', 'Koçarlı', 'Köşk', 'Kuşadası', 'Kuyucak', 'Nazilli', 'Söke', 'Sultanhisar', 'Yenipazar'],
    'Balıkesir': ['Altıeylül', 'Ayvalık', 'Balya', 'Bandırma', 'Bigadiç', 'Burhaniye', 'Dursunbey', 'Edremit', 'Erdek', 'Gömeç', 'Gönen', 'Havran', 'İvrindi', 'Karesi', 'Kepsut', 'Manyas', 'Marmara', 'Savaştepe', 'Sındırgı', 'Susurluk'],
    'Bilecik': ['Bozüyük', 'Gölpazarı', 'İnhisar', 'Merkez', 'Osmaneli', 'Pazaryeri', 'Söğüt', 'Yenipazar'],
    'Bingöl': ['Adaklı', 'Genç', 'Karlıova', 'Kiğı', 'Merkez', 'Solhan', 'Yayladere', 'Yedisu'],
    'Bitlis': ['Adilcevaz', 'Ahlat', 'Güroymak', 'Hizan', 'Merkez', 'Mutki', 'Tatvan'],
    'Bolu': ['Dörtdivan', 'Gerede', 'Göynük', 'Kıbrıscık', 'Mengen', 'Merkez', 'Mudurnu', 'Seben', 'Yeniçağa'],
    'Burdur': ['Ağlasun', 'Altınyayla', 'Bucak', 'Çavdır', 'Çeltikçi', 'Gölhisar', 'Karamanlı', 'Kemer', 'Merkez', 'Tefenni', 'Yeşilova'],
    'Bursa': ['Büyükorhan', 'Gemlik', 'Gürsu', 'Harmancık', 'İnegöl', 'İznik', 'Karacabey', 'Keles', 'Kestel', 'Mudanya', 'Mustafakemalpaşa', 'Nilüfer', 'Orhaneli', 'Orhangazi', 'Osmangazi', 'Yenişehir', 'Yıldırım'],
    'İstanbul': ['Adalar', 'Arnavutköy', 'Ataşehir', 'Avcılar', 'Bağcılar', 'Bahçelievler', 'Bakırköy', 'Başakşehir', 'Bayrampaşa', 'Beşiktaş', 'Beykoz', 'Beylikdüzü', 'Beyoğlu', 'Büyükçekmece', 'Çatalca', 'Çekmeköy', 'Esenler', 'Esenyurt', 'Eyüpsultan', 'Fatih', 'Gaziosmanpaşa', 'Güngören', 'Kadıköy', 'Kağıthane', 'Kartal', 'Küçükçekmece', 'Maltepe', 'Pendik', 'Sancaktepe', 'Sarıyer', 'Silivri', 'Sultanbeyli', 'Sultangazi', 'Şile', 'Şişli', 'Tuzla', 'Ümraniye', 'Üsküdar', 'Zeytinburnu'],
    'İzmir': ['Aliağa', 'Balçova', 'Bayındır', 'Bayraklı', 'Bergama', 'Beydağ', 'Bornova', 'Buca', 'Çeşme', 'Çiğli', 'Dikili', 'Foça', 'Gaziemir', 'Güzelbahçe', 'Karabağlar', 'Karaburun', 'Karşıyaka', 'Kemalpaşa', 'Kınık', 'Kiraz', 'Konak', 'Menderes', 'Menemen', 'Narlıdere', 'Ödemiş', 'Seferihisar', 'Selçuk', 'Tire', 'Torbalı', 'Urla'],
    // ... Diğer iller buraya eklenecek
  };

  static List<String> getAllCities() {
    return citiesAndDistricts.keys.toList()..sort();
  }

  static List<String> getDistricts(String city) {
    return citiesAndDistricts[city] ?? [];
  }
}

// Kullanıcı deposu
class UserRepository {
  static const String _usersKey = 'users';
  static List<User>? _users;
  static SharedPreferences? _prefs;

  // SharedPreferences'ı başlat
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUsers();
  }

  // Kullanıcıları yükle
  static Future<void> _loadUsers() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final usersList = jsonDecode(usersJson) as List;
      _users = usersList.map((json) => User.fromJson(json)).toList();
    } else {
      _users = [
        User(
          id: '1',
          name: 'Test Çiftçi',
          email: 'test@test.com',
          password: '123456',
          userType: UserType.farmer,
          profile: UserProfile(
            phoneNumber: '+905551234567',
            city: 'Antalya',
            district: 'Kumluca',
            detailedAddress: 'Test Mahallesi',
            createdAt: DateTime.now().subtract(const Duration(days: 730)), // 2 yıl önce
            rating: 4.8,
            ratingCount: 156,
            totalAdverts: 124,
            isActive: true,
          ),
        ),
        User(
          id: '2',
          name: 'Test Alıcı',
          email: 'alici@test.com',
          password: '123456',
          userType: UserType.buyer,
          profile: UserProfile(
            phoneNumber: '+905559876543',
            city: 'İstanbul',
            district: 'Kadıköy',
            detailedAddress: 'Test Sokak',
            createdAt: DateTime.now().subtract(const Duration(days: 45)), // 45 gün önce
            rating: 4.2,
            ratingCount: 23,
            totalAdverts: 5,
            isActive: true,
          ),
        ),
      ];
      await _saveUsers();
    }
  }

  // Kullanıcıları kaydet
  static Future<void> _saveUsers() async {
    final prefs = _prefs;
    if (prefs == null || _users == null) return;

    final usersJson = jsonEncode(_users!.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }

  static Future<void> addUser(User user) async {
    if (_users == null) await _loadUsers();
    if (_users == null) return;

    print('=== KAYIT İŞLEMİ BAŞLADI ===');
    print('Eklenecek kullanıcı bilgileri:');
    print('- E-posta: ${user.email}');
    print('- Şifre: ${user.password}');
    print('- İsim: ${user.name}');
    print('- Tip: ${user.userType.displayName}');
    
    _users!.add(user);
    await _saveUsers();
    
    print('\nMevcut kullanıcı listesi:');
    for (var u in _users!) {
      print('* ${u.email} (${u.password})');
    }
    print('=== KAYIT İŞLEMİ TAMAMLANDI ===\n');
  }

  static User? findUserById(String id) {
    if (_users == null) return null;
    print('\nKullanıcı ID ile arama: $id');
    try {
      final user = _users!.firstWhere((user) => user.id == id);
      print('Kullanıcı bulundu: ${user.email}');
      return user;
    } catch (e) {
      print('Kullanıcı bulunamadı: $id');
      return null;
    }
  }

  static User? findUserByEmail(String email) {
    if (_users == null) return null;
    print('\nKullanıcı arama: $email');
    try {
      final user = _users!.firstWhere(
        (user) => user.email.trim().toLowerCase() == email.trim().toLowerCase()
      );
      print('Kullanıcı bulundu: ${user.email}');
      return user;
    } catch (e) {
      print('Kullanıcı bulunamadı: $email');
      return null;
    }
  }

  static bool validateUser(String email, String password) {
    if (_users == null) return false;
    
    print('\n=== GİRİŞ DOĞRULAMA BAŞLADI ===');
    print('Girilen bilgiler:');
    print('- E-posta: $email');
    print('- Şifre: $password');
    
    print('\nKayıtlı kullanıcılar:');
    for (var user in _users!) {
      print('* ${user.email} (${user.password})');
    }
    
    final user = findUserByEmail(email);
    if (user != null) {
      print('\nKullanıcı bulundu:');
      print('- Kayıtlı e-posta: ${user.email}');
      print('- Kayıtlı şifre: ${user.password}');
      
      final isValid = user.password == password;
      print('\nŞifre kontrolü: ${isValid ? "BAŞARILI" : "BAŞARISIZ"}');
      print('=== GİRİŞ DOĞRULAMA TAMAMLANDI ===\n');
      return isValid;
    }
    
    print('\nKullanıcı bulunamadı!');
    print('=== GİRİŞ DOĞRULAMA TAMAMLANDI ===\n');
    return false;
  }

  static Future<void> updateUserProfile(String email, UserProfile profile) async {
    if (_users == null) return;
    final user = findUserByEmail(email);
    if (user != null) {
      user.profile = profile;
      await _saveUsers();
      print('Profil güncellendi: ${user.email}');
    } else {
      print('Kullanıcı bulunamadı: $email');
    }
  }

  static bool hasProfile(String email) {
    if (_users == null) return false;
    final user = findUserByEmail(email);
    final hasProfile = user?.profile != null;
    print('Profil kontrolü: $email - $hasProfile');
    return hasProfile;
  }

  static void toggleFavorite(String email, String advertId) {
    if (_users == null) return;
    final user = findUserByEmail(email);
    if (user?.profile != null) {
      final favorites = user!.profile!.favorites;
      if (favorites.contains(advertId)) {
        favorites.remove(advertId);
      } else {
        favorites.add(advertId);
      }
      _saveUsers();
    }
  }

  static List<String> getUserFavorites(String email) {
    if (_users == null) return [];
    final user = findUserByEmail(email);
    return user?.profile?.favorites ?? [];
  }

  // Kullanıcı güncelle
  static Future<void> updateUser(User user) async {
    await _loadUsers();
    final index = _users?.indexWhere((u) => u.id == user.id) ?? -1;
    if (index != -1 && _users != null) {
      _users![index] = user;
      await _saveUsers();
    }
  }
} 