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
  }) : favorites = favorites ?? [];

  // Telefon numarası doğrulama
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+90[0-9]{10}$');
    return phoneRegex.hasMatch(phone);
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
  static final List<User> _users = [];

  static void addUser(User user) {
    _users.add(user);
  }

  static User? findUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static User? findUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  static bool validateUser(String email, String password) {
    return _users.any((user) => user.email == email && user.password == password);
  }

  static void updateUserProfile(String email, UserProfile profile) {
    final user = findUserByEmail(email);
    if (user != null) {
      user.profile = profile;
      print('Profil güncellendi: ${user.email}'); // Debug için log
    } else {
      print('Kullanıcı bulunamadı: $email'); // Debug için log
    }
  }

  static bool hasProfile(String email) {
    final user = findUserByEmail(email);
    final hasProfile = user?.profile != null;
    print('Profil kontrolü: $email - $hasProfile'); // Debug için log
    return hasProfile;
  }

  // Favori ilan ekleme/çıkarma
  static void toggleFavorite(String email, String advertId) {
    final user = findUserByEmail(email);
    if (user?.profile != null) {
      final favorites = user!.profile!.favorites;
      if (favorites.contains(advertId)) {
        favorites.remove(advertId);
      } else {
        favorites.add(advertId);
      }
    }
  }

  // Kullanıcının favori ilanlarını getirme
  static List<String> getUserFavorites(String email) {
    final user = findUserByEmail(email);
    return user?.profile?.favorites ?? [];
  }
} 