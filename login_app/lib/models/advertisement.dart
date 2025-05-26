enum ProductCategory {
  fruit('Meyve'),
  vegetable('Sebze'),
  grain('Tahıl'),
  legume('Bakliyat'),
  other('Diğer');

  final String displayName;
  const ProductCategory(this.displayName);
}

enum UnitType {
  kg('Kilogram'),
  ton('Ton'),
  piece('Adet'),
  box('Kasa');

  final String displayName;
  const UnitType(this.displayName);
}

class Advertisement {
  final String id;
  final String userId; // İlan sahibinin ID'si
  final String title;
  final ProductCategory category;
  final double price; // Birim fiyat
  final UnitType unit; // Birim tipi (kg, ton, adet)
  final double quantity; // Toplam miktar
  final String city;
  final String district;
  final String description;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime availableFrom; // Satış başlangıç tarihi
  final DateTime availableTo; // Satış bitiş tarihi
  final bool isActive;
  final bool isOrganic; // Organik ürün mü?
  final String? certificateUrl; // Organik sertifika URL'si (varsa)

  Advertisement({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.city,
    required this.district,
    required this.description,
    required this.imageUrls,
    required this.createdAt,
    required this.availableFrom,
    required this.availableTo,
    this.isActive = true,
    this.isOrganic = false,
    this.certificateUrl,
  });

  // Toplam fiyat hesaplama
  double get totalPrice => price * quantity;

  // İlanın aktif olup olmadığını kontrol etme
  bool get isAvailable {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(availableFrom) && 
           now.isBefore(availableTo);
  }

  // Lokasyon bilgisini birleştirme
  String get location => '$district, $city';
}

// İlan deposu
class AdvertRepository {
  static final List<Advertisement> _adverts = [
    // Örnek ilanlar
    Advertisement(
      id: '1',
      userId: 'user1',
      title: 'Organik Domates',
      category: ProductCategory.vegetable,
      price: 15.0,
      unit: UnitType.kg,
      quantity: 1000,
      city: 'Antalya',
      district: 'Kumluca',
      description: 'Tamamen organik, sertifikalı domates satılık. Minimum alım miktarı 100 kg.',
      imageUrls: ['assets/images/tomatoes.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: true,
      certificateUrl: 'assets/certificates/organic_cert.pdf',
    ),
    Advertisement(
      id: '2',
      userId: 'user2',
      title: 'Taze Elma',
      category: ProductCategory.fruit,
      price: 8.0,
      unit: UnitType.kg,
      quantity: 500,
      city: 'Isparta',
      district: 'Merkez',
      description: 'Bahçeden yeni toplanmış taze elmalar. Toplu alımlarda indirim yapılır.',
      imageUrls: ['assets/images/apples.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 15)),
    ),
  ];

  // Debug fonksiyonu
  static void debugPrintAllAdverts() {
    print('\n=== Mevcut İlanlar ===');
    for (var ad in _adverts) {
      print('ID: ${ad.id}');
      print('Başlık: ${ad.title}');
      print('Fiyat: ${ad.price} ₺/${ad.unit.displayName}');
      print('Konum: ${ad.location}');
      print('Durum: ${ad.isAvailable ? "Aktif" : "Pasif"}');
      print('------------------------');
    }
    print('Toplam İlan Sayısı: ${_adverts.length}\n');
  }

  // İlan ID'sine göre ilanı bul
  static Advertisement? findById(String id) {
    try {
      return _adverts.firstWhere((ad) => ad.id == id);
    } catch (e) {
      return null;
    }
  }

  // Tüm aktif ilanları getir
  static List<Advertisement> getAllAdverts() {
    return _adverts.where((ad) => ad.isActive && ad.isAvailable).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Kategoriye göre ilanları getir
  static List<Advertisement> getAdvertsByCategory(ProductCategory category) {
    return _adverts
        .where((ad) => ad.isActive && ad.isAvailable && ad.category == category)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Kullanıcının ilanlarını getir
  static List<Advertisement> getUserAdverts(String userId) {
    return _adverts.where((ad) => ad.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Lokasyona göre ilanları getir
  static List<Advertisement> getAdvertsByLocation(String city, {String? district}) {
    return _adverts
        .where((ad) => 
          ad.isActive && 
          ad.isAvailable && 
          ad.city == city && 
          (district == null || ad.district == district))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // İlan ara
  static List<Advertisement> searchAdverts(String query) {
    query = query.toLowerCase();
    return _adverts
        .where((ad) => 
          ad.isActive && 
          ad.isAvailable && 
          (ad.title.toLowerCase().contains(query) ||
           ad.description.toLowerCase().contains(query) ||
           ad.city.toLowerCase().contains(query) ||
           ad.district.toLowerCase().contains(query)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // İlan ekle
  static void addAdvert(Advertisement advert) {
    _adverts.add(advert);
  }

  // İlan güncelle
  static void updateAdvert(Advertisement advert) {
    final index = _adverts.indexWhere((ad) => ad.id == advert.id);
    if (index != -1) {
      _adverts[index] = advert;
    }
  }

  // İlan sil/pasifleştir
  static void deactivateAdvert(String id) {
    final index = _adverts.indexWhere((ad) => ad.id == id);
    if (index != -1) {
      final advert = _adverts[index];
      _adverts[index] = Advertisement(
        id: advert.id,
        userId: advert.userId,
        title: advert.title,
        category: advert.category,
        price: advert.price,
        unit: advert.unit,
        quantity: advert.quantity,
        city: advert.city,
        district: advert.district,
        description: advert.description,
        imageUrls: advert.imageUrls,
        createdAt: advert.createdAt,
        availableFrom: advert.availableFrom,
        availableTo: advert.availableTo,
        isActive: false,
        isOrganic: advert.isOrganic,
        certificateUrl: advert.certificateUrl,
      );
    }
  }
} 