class AgricultureNews {
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String newsUrl;
  final String date;
  final String? source;

  AgricultureNews({
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.newsUrl,
    required this.date,
    this.source,
  });
}

// Örnek haberler
final List<AgricultureNews> agricultureNews = [
  AgricultureNews(
    title: 'TÜİK: Tarım sektörü %2.5 büyüdü',
    summary: 'Türkiye İstatistik Kurumu 2024 ilk çeyrek verilerine göre tarım sektörü büyümeye devam ediyor.',
    content: '''
Türkiye İstatistik Kurumu (TÜİK) tarafından açıklanan 2024 yılı ilk çeyrek verilerine göre, tarım sektörü bir önceki yılın aynı dönemine göre %2.5 büyüme kaydetti.

Büyümenin ana nedenleri arasında:
• Teknolojik tarım uygulamalarının yaygınlaşması
• Devlet desteklerinin artması
• İhracat potansiyelinin yükselmesi
• Çiftçilerin modern tarım tekniklerine adaptasyonu

Bu büyüme, tarım sektörünün Türkiye ekonomisindeki önemini bir kez daha ortaya koydu. Özellikle genç çiftçilerin teknolojik tarıma olan ilgisi, sektörün geleceği açısından umut verici görünüyor.
    ''',
    imageUrl: 'assets/images/Tuik.png',
    newsUrl: 'https://www.tuik.gov.tr/tarim-haberleri',
    date: '15 Mart 2024',
    source: 'TÜİK',
  ),
  AgricultureNews(
    title: 'Akıllı tarım uygulamaları yaygınlaşıyor',
    summary: 'Türkiye\'de akıllı tarım uygulamalarını kullanan çiftçi sayısı her geçen gün artıyor.',
    content: '''
Türkiye'de akıllı tarım uygulamalarının kullanımı son yıllarda önemli bir artış gösterdi. Özellikle genç çiftçiler arasında yaygınlaşan bu teknolojiler, verimliliği artırırken maliyetleri düşürüyor.

Öne çıkan akıllı tarım uygulamaları:
• Drone ile ilaçlama ve gözlem
• Toprak sensörleri ile nem ve mineral takibi
• Akıllı sulama sistemleri
• Yapay zeka destekli hasat planlama

Bu teknolojileri kullanan çiftçiler, su tüketiminde %30'a varan tasarruf sağlarken, verimliliklerini %25 oranında artırdıklarını bildiriyor.
    ''',
    imageUrl: 'assets/images/akıllı tarim uygulamaları.png',
    newsUrl: 'https://www.tarim.gov.tr/akilli-tarim',
    date: '14 Mart 2024',
    source: 'Tarım ve Orman Bakanlığı',
  ),
  AgricultureNews(
    title: 'Organik tarım destekleri açıklandı',
    summary: '2024 yılı organik tarım destekleme ödemeleri başvuruları başladı.',
    content: '''
Tarım ve Orman Bakanlığı, 2024 yılı organik tarım destekleme ödemelerini açıkladı. Bu yıl destekleme miktarları geçen yıla göre ortalama %40 artış gösterdi.

Destek Kalemleri:
• Meyve-sebze yetiştiriciliği: Dekar başına 150 TL
• Tarla bitkileri: Dekar başına 100 TL
• Seracılık: Dekar başına 200 TL
• Hayvancılık: Büyükbaş başına 1000 TL

Başvurular 1 Nisan 2024 tarihinde başlayacak ve 30 Nisan 2024 tarihine kadar devam edecek. Çiftçiler başvurularını e-Devlet üzerinden veya il/ilçe tarım müdürlüklerine yapabilecek.
    ''',
    imageUrl: 'assets/images/organik tarım desteklemeleri.png',
    newsUrl: 'https://www.tarim.gov.tr/destekler',
    date: '13 Mart 2024',
    source: 'Tarım ve Orman Bakanlığı',
  ),
]; 