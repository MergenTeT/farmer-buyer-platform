import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'models/advertisement.dart';
import 'models/message.dart';
import 'pages/advertisements_page.dart';
import 'pages/create_advert_page.dart';
import 'pages/messages_page.dart';
import 'pages/create_profile_page.dart';
import 'pages/advert_detail_page.dart';

class HomePage extends StatefulWidget {
  final String userEmail;
  
  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _scrollController = ScrollController();
  
  // Sayfalama için değişkenler
  int _currentPage = 1;
  static const int _pageSize = 5;
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    // Simüle edilmiş ağ gecikmesi
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
                          'Bugün ne almak/satmak istersiniz?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Kategoriler
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kategoriler',
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
                                Text('Tümü'),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: ProductCategory.values.length,
                          itemBuilder: (context, index) {
                            final category = ProductCategory.values[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: CategoryCard(
                                category: category,
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = 1; // İlanlar sekmesine geç
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Son ilanlar
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
                                _selectedIndex = 1;
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
          SafeArea(
            child: AdvertisementsPage(userEmail: widget.userEmail),
          ),

          // Profil Sayfası
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser?.name ?? 'Kullanıcı',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentUser?.email ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Profil menüsü
                  _buildProfileMenuItem(
                    icon: Icons.person,
                    title: 'Profili Düzenle',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateProfilePage(
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.favorite,
                    title: 'Favorilerim',
                    onTap: () {
                      // Favoriler sayfasına git
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.settings,
                    title: 'Ayarlar',
                    onTap: () {
                      // Ayarlar sayfasına git
                    },
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.exit_to_app,
                    title: 'Çıkış Yap',
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'İlanlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAdvertPage(userEmail: widget.userEmail),
            ),
          ).then((_) {
            setState(() {
              // İlan eklenince listeyi yenile
              _currentPage = 1;
              _hasMoreData = true;
            });
          });
        },
        child: const Icon(Icons.add),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              advertisement.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              advertisement.category.displayName,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${advertisement.price.toStringAsFixed(2)} ₺/${advertisement.unit.displayName}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            '${advertisement.quantity} ${advertisement.unit.displayName}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        advertisement.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      if (advertisement.isOrganic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.eco,
                                size: 16,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Organik',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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