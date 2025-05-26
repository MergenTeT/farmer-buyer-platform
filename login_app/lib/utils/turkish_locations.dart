class TurkishLocations {
  static List<String> getAllCities() {
    return [
      'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin',
      'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale',
      'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum',
      'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari', 'Hatay', 'Isparta', 'Mersin',
      'İstanbul', 'İzmir', 'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli',
      'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş', 'Nevşehir',
      'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Tekirdağ', 'Tokat',
      'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt',
      'Karaman', 'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük',
      'Kilis', 'Osmaniye', 'Düzce'
    ];
  }

  static List<String> getDistricts(String city) {
    final Map<String, List<String>> cityDistricts = {
      'İstanbul': ['Adalar', 'Bakırköy', 'Beşiktaş', 'Beyoğlu', 'Çatalca', 'Eyüp', 'Fatih', 'Gaziosmanpaşa', 'Kadıköy', 'Kartal', 'Sarıyer', 'Silivri', 'Şile', 'Şişli', 'Üsküdar', 'Zeytinburnu', 'Büyükçekmece', 'Kağıthane', 'Küçükçekmece', 'Pendik', 'Ümraniye', 'Bayrampaşa', 'Avcılar', 'Bağcılar', 'Bahçelievler', 'Güngören', 'Maltepe', 'Sultanbeyli', 'Tuzla', 'Esenler', 'Arnavutköy', 'Ataşehir', 'Başakşehir', 'Beylikdüzü', 'Çekmeköy', 'Esenyurt', 'Sancaktepe', 'Sultangazi'],
      'Ankara': ['Akyurt', 'Altındağ', 'Ayaş', 'Bala', 'Beypazarı', 'Çamlıdere', 'Çankaya', 'Çubuk', 'Elmadağ', 'Etimesgut', 'Evren', 'Gölbaşı', 'Güdül', 'Haymana', 'Kalecik', 'Kazan', 'Keçiören', 'Kızılcahamam', 'Mamak', 'Nallıhan', 'Polatlı', 'Pursaklar', 'Sincan', 'Şereflikoçhisar', 'Yenimahalle'],
      'İzmir': ['Aliağa', 'Balçova', 'Bayındır', 'Bayraklı', 'Bergama', 'Beydağ', 'Bornova', 'Buca', 'Çeşme', 'Çiğli', 'Dikili', 'Foça', 'Gaziemir', 'Güzelbahçe', 'Karabağlar', 'Karaburun', 'Karşıyaka', 'Kemalpaşa', 'Kınık', 'Kiraz', 'Konak', 'Menderes', 'Menemen', 'Narlıdere', 'Ödemiş', 'Seferihisar', 'Selçuk', 'Tire', 'Torbalı', 'Urla'],
      // Diğer şehirler için varsayılan ilçeler
      'default': ['Merkez', 'Yeni Mahalle', 'Eski Mahalle', 'Cumhuriyet', 'Atatürk', 'İnönü', 'Fatih', 'Yıldırım', 'Murat', 'Zafer']
    };

    return cityDistricts[city] ?? cityDistricts['default']!;
  }
} 