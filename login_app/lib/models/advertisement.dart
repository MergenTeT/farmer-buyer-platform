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
    Advertisement(
      id: '1',
      userId: 'user1',
      title: 'Taze Organik Domates',
      description: 'Antalya\'dan taze organik domates. Özenle yetiştirilmiş.',
      price: 24.99,
      quantity: 100,
      unit: UnitType.kg,
      category: ProductCategory.vegetable,
      city: 'Antalya',
      district: 'Merkez',
      imageUrls: ['assets/images/tomato.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: true,
    ),
    Advertisement(
      id: '2',
      userId: 'user2',
      title: 'Yerli Buğday',
      description: 'Konya\'dan yerli buğday. Yüksek protein değeri.',
      price: 15.50,
      quantity: 1000,
      unit: UnitType.kg,
      category: ProductCategory.grain,
      city: 'Konya',
      district: 'Çumra',
      imageUrls: ['assets/images/wheat.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: false,
    ),
    Advertisement(
      id: '3',
      userId: 'user3',
      title: 'Organik Çilek',
      description: 'Aydın\'dan taze organik çilek. Doğal tadıyla.',
      price: 45.00,
      quantity: 50,
      unit: UnitType.kg,
      category: ProductCategory.fruit,
      city: 'Aydın',
      district: 'Sultanhisar',
      imageUrls: ['assets/images/strawberry.jpg'],
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 15)),
      isOrganic: true,
    ),
    Advertisement(
      id: '4',
      userId: 'user1',
      title: 'Kuru Fasulye',
      description: 'Bolu\'dan yerli kuru fasulye. Yüksek kalite.',
      price: 35.75,
      quantity: 200,
      unit: UnitType.kg,
      category: ProductCategory.legume,
      city: 'Bolu',
      district: 'Merkez',
      imageUrls: ['assets/images/beans.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 45)),
      isOrganic: false,
    ),
    Advertisement(
      id: '5',
      userId: 'user4',
      title: 'Organik Patates',
      description: 'Niğde\'den organik patates. Taze hasat.',
      price: 18.50,
      quantity: 300,
      unit: UnitType.kg,
      category: ProductCategory.vegetable,
      city: 'Niğde',
      district: 'Merkez',
      imageUrls: ['assets/images/potato.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 20)),
      isOrganic: true,
    ),
    Advertisement(
      id: '6',
      userId: 'user2',
      title: 'Taze Üzüm',
      description: 'Manisa\'dan taze üzüm. Sofralık ve şaraplık çeşitler.',
      price: 28.90,
      quantity: 150,
      unit: UnitType.kg,
      category: ProductCategory.fruit,
      city: 'Manisa',
      district: 'Alaşehir',
      imageUrls: ['assets/images/grape.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: false,
    ),
    Advertisement(
      id: '7',
      userId: 'user5',
      title: 'Organik Mercimek',
      description: 'Şanlıurfa\'dan organik kırmızı mercimek.',
      price: 42.00,
      quantity: 250,
      unit: UnitType.kg,
      category: ProductCategory.legume,
      city: 'Şanlıurfa',
      district: 'Siverek',
      imageUrls: ['assets/images/lentil.jpg'],
      createdAt: DateTime.now().subtract(const Duration(hours: 36)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: true,
    ),
    Advertisement(
      id: '8',
      userId: 'user3',
      title: 'Taze Mısır',
      description: 'Samsun\'dan taze mısır. Doğal yetiştirilmiş.',
      price: 12.75,
      quantity: 400,
      unit: UnitType.kg,
      category: ProductCategory.grain,
      city: 'Samsun',
      district: 'Bafra',
      imageUrls: ['assets/images/corn.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: false,
    ),
    Advertisement(
      id: '9',
      userId: 'user4',
      title: 'Organik Elma',
      description: 'Isparta\'dan organik elma. Taze ve sulu.',
      price: 32.50,
      quantity: 175,
      unit: UnitType.kg,
      category: ProductCategory.fruit,
      city: 'Isparta',
      district: 'Eğirdir',
      imageUrls: ['assets/images/apple.jpg'],
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 15)),
      isOrganic: true,
    ),
    Advertisement(
      id: '10',
      userId: 'user1',
      title: 'Taze Biber',
      description: 'Bursa\'dan taze biber. Közlemelik ve dolmalık.',
      price: 27.90,
      quantity: 80,
      unit: UnitType.kg,
      category: ProductCategory.vegetable,
      city: 'Bursa',
      district: 'Gemlik',
      imageUrls: ['assets/images/pepper.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: false,
    ),
    Advertisement(
      id: '11',
      userId: 'user5',
      title: 'Organik Nohut',
      description: 'Mersin\'den organik nohut. İri taneli.',
      price: 38.50,
      quantity: 225,
      unit: UnitType.kg,
      category: ProductCategory.legume,
      city: 'Mersin',
      district: 'Tarsus',
      imageUrls: ['assets/images/chickpea.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: true,
    ),
    Advertisement(
      id: '12',
      userId: 'user2',
      title: 'Taze Portakal',
      description: 'Adana\'dan taze portakal. Vitamin deposu.',
      price: 22.75,
      quantity: 300,
      unit: UnitType.kg,
      category: ProductCategory.fruit,
      city: 'Adana',
      district: 'Kozan',
      imageUrls: ['assets/images/orange.jpg'],
      createdAt: DateTime.now().subtract(const Duration(hours: 48)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: false,
    ),
    Advertisement(
      id: '13',
      userId: 'user3',
      title: 'Organik Pirinç',
      description: 'Edirne\'den organik pirinç. Baldo çeşidi.',
      price: 55.00,
      quantity: 500,
      unit: UnitType.kg,
      category: ProductCategory.grain,
      city: 'Edirne',
      district: 'İpsala',
      imageUrls: ['assets/images/rice.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: true,
    ),
    Advertisement(
      id: '14',
      userId: 'user4',
      title: 'Taze Patlıcan',
      description: 'Mersin\'den taze patlıcan. Kızartmalık ve közlemelik.',
      price: 29.90,
      quantity: 120,
      unit: UnitType.kg,
      category: ProductCategory.vegetable,
      city: 'Mersin',
      district: 'Erdemli',
      imageUrls: ['assets/images/eggplant.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: false,
    ),
    Advertisement(
      id: '15',
      userId: 'user5',
      title: 'Organik Barbunya',
      description: 'Trabzon\'dan organik barbunya. Taze hasat.',
      price: 44.50,
      quantity: 150,
      unit: UnitType.kg,
      category: ProductCategory.legume,
      city: 'Trabzon',
      district: 'Akçaabat',
      imageUrls: ['assets/images/cranberry_beans.jpg'],
      createdAt: DateTime.now().subtract(const Duration(hours: 72)),
      availableFrom: DateTime.now(),
      availableTo: DateTime.now().add(const Duration(days: 30)),
      isOrganic: true,
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

  static List<Advertisement> getAdvertsByPage(int page, int pageSize) {
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    
    if (startIndex >= _adverts.length) {
      return [];
    }
    
    return _adverts.sublist(
      startIndex,
      endIndex > _adverts.length ? _adverts.length : endIndex,
    );
  }

  static int getTotalPages(int pageSize) {
    return (_adverts.length / pageSize).ceil();
  }
} 