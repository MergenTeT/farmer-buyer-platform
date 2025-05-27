import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'models/advertisement.dart';
import 'models/message.dart';
import 'models/agriculture_news.dart';
import 'models/price_data.dart';
import 'pages/advertisements_page.dart';
import 'pages/create_advert_page.dart';
import 'pages/messages_page.dart';
import 'pages/create_profile_page.dart';
import 'pages/advert_detail_page.dart';
import 'pages/profile_page.dart';
import 'pages/news_detail_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final String userEmail;
  
  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _scrollController = ScrollController();
  int _currentNewsIndex = 0;
  final _newsPageController = PageController();
  Timer? _newsTimer;
  
  // Sayfalama için değişkenler
  int _currentPage = 1;
  static const int _pageSize = 5;
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Otomatik haber kaydırma için timer başlat
    _startNewsTimer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newsPageController.dispose();
    _newsTimer?.cancel();
    super.dispose();
  }

  void _startNewsTimer() {
    _newsTimer?.cancel();
    _newsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentNewsIndex < agricultureNews.length - 1) {
        _newsPageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _newsPageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Scroll listener
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMoreData) {
      _loadMoreData();
    }
  }

  // Veri yükleme fonksiyonu
  Future<void> _loadMoreData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final newAdverts = AdvertRepository.getAdvertsByPage(_currentPage + 1, _pageSize);
    
    if (newAdverts.isEmpty) {
      setState(() {
        _hasMoreData = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _currentPage++;
      _isLoading = false;
    });
  }

  // Haber kartı widget'ı
  Widget _buildNewsCard(AgricultureNews news) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailPage(news: news),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                news.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.summary,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fiyat kartı widget'ı
  Widget _buildPriceSection(String title, List<PriceData> prices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Son Güncelleme: ${prices.first.lastUpdate}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prices.length,
          itemBuilder: (context, index) {
            final price = prices[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            price.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${price.price} ${price.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: price.change >= 0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            price.change >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: price.change >= 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${price.change.abs()}%',
                            style: TextStyle(
                              color: price.change >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = UserRepository.findUserByEmail(widget.userEmail);
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Ana Sayfa
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green.shade50,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                children: [
                  // Hoş geldin mesajı
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba, ${currentUser?.name ?? 'Kullanıcı'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bugün tarım dünyasında neler oluyor?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tarım Haberleri
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 16),
                        child: Text(
                          'Tarım Haberleri',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          controller: _newsPageController,
                          itemCount: agricultureNews.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentNewsIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildNewsCard(agricultureNews[index]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Haber indikatörleri
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: agricultureNews.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () {
                              _newsPageController.animateToPage(
                                entry.key,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentNewsIndex == entry.key
                                    ? Colors.green
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Güncel Fiyatlar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 16),
                        child: Text(
                          'Güncel Fiyatlar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildPriceSection('Gübre Fiyatları', fertilizers),
                      const SizedBox(height: 24),
                      _buildPriceSection('Akaryakıt Fiyatları', fuelPrices),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Son İlanlar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Son İlanlar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedIndex = 1; // İlanlar sekmesine geç
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                            child: const Row(
                              children: [
                                Text('Tümünü Gör'),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // İlan listesi
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: AdvertRepository.getAdvertsByPage(_currentPage, _pageSize).length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          final adverts = AdvertRepository.getAdvertsByPage(_currentPage, _pageSize);
                          
                          if (index == adverts.length) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AdvertCard(
                              advertisement: adverts[index],
                              currentUserEmail: widget.userEmail,
                            ),
                          );
                        },
                      ),

                      // Daha fazla veri yüklenirken gösterilecek indicator
                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),

                      // Tüm veriler yüklendiğinde gösterilecek mesaj
                      if (!_hasMoreData && AdvertRepository.getAllAdverts().isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Tüm ilanlar yüklendi',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // İlanlar Sayfası
          AdvertisementsPage(userEmail: widget.userEmail),
          // İlan Oluşturma Sayfası
          CreateAdvertPage(userEmail: widget.userEmail),
          // Mesajlar Sayfası
          MessagesPage(userEmail: widget.userEmail),
          // Profil Sayfası
          ProfilePage(userEmail: widget.userEmail),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'İlanlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'İlan Ekle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (category) {
      case ProductCategory.fruit:
        icon = Icons.apple;
        break;
      case ProductCategory.vegetable:
        icon = Icons.eco;
        break;
      case ProductCategory.grain:
        icon = Icons.grass;
        break;
      case ProductCategory.legume:
        icon = Icons.spa;
        break;
      case ProductCategory.other:
        icon = Icons.category;
        break;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                category.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdvertCard extends StatelessWidget {
  final Advertisement advertisement;
  final String currentUserEmail;

  const AdvertCard({
    super.key,
    required this.advertisement,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: advertisement.category.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdvertDetailPage(
                advertisement: advertisement,
                currentUserEmail: currentUserEmail,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (advertisement.imageUrls.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      advertisement.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: advertisement.category.color.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          advertisement.category.icon,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          advertisement.category.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (advertisement.isOrganic)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Organik',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advertisement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${advertisement.price.toStringAsFixed(2)} ₺/${advertisement.unit.displayName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          advertisement.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 