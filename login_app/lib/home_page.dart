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
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = UserRepository.findUserByEmail(widget.userEmail);
    final List<Widget> _pages = [
      // Ana Sayfa
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Arama kutusu
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'İlan ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Kategoriler
          const Text(
            'Kategoriler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: ProductCategory.values.map((category) {
              return CategoryCard(
                category: category,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1; // İlanlar sekmesine geç
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Son ilanlar
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
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // İlan listesi
          if (_searchQuery.isEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // Son 5 ilan
              itemBuilder: (context, index) {
                final adverts = AdvertRepository.getAllAdverts();
                if (index < adverts.length) {
                  return AdvertCard(
                    advertisement: adverts[index],
                    currentUserEmail: widget.userEmail,
                  );
                }
                return null;
              },
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final searchResults = AdvertRepository.searchAdverts(_searchQuery);
                if (index < searchResults.length) {
                  return AdvertCard(
                    advertisement: searchResults[index],
                    currentUserEmail: widget.userEmail,
                  );
                }
                return null;
              },
              itemCount: AdvertRepository.searchAdverts(_searchQuery).length,
            ),
        ],
      ),
      
      // İlanlar Sayfası
      const AdvertisementsPage(),

      // İlan Ekle Sayfası
      CreateAdvertPage(userEmail: widget.userEmail),

      // Mesajlar Sayfası
      MessagesPage(userEmail: widget.userEmail),

      // Profil Sayfası
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Text(
                currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40),
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
            const SizedBox(height: 8),
            Text(
              currentUser?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ProfileInfoCard(
              icon: Icons.phone,
              title: 'Telefon',
              value: currentUser?.profile?.phoneNumber ?? 'Belirtilmedi',
            ),
            const SizedBox(height: 8),
            ProfileInfoCard(
              icon: Icons.location_on,
              title: 'Adres',
              value: currentUser?.profile?.city ?? 'Belirtilmedi',
            ),
            const SizedBox(height: 8),
            ProfileInfoCard(
              icon: Icons.business,
              title: 'Şirket',
              value: currentUser?.profile?.companyName ?? 'Belirtilmedi',
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: widget.userEmail,
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Profili Düzenle'),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favori İlanlarım'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Favori ilanlar sayfası
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('İlanlarım'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Kullanıcının ilanları sayfası
              },
            ),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Çıkış Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 
          ? 'Ana Sayfa' 
          : _selectedIndex == 1 
            ? 'İlanlar'
            : _selectedIndex == 2
              ? 'İlan Ekle'
              : _selectedIndex == 3
                ? 'Mesajlar'
                : 'Profil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedIndex == 3)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // TODO: Bildirimler sayfası
                  },
                ),
                if (currentUser != null &&
                    MessageRepository.getUnreadMessageCount(currentUser.id) > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        MessageRepository.getUnreadMessageCount(currentUser.id)
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            label: 'İlanlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'İlan Ekle',
          ),
          NavigationDestination(
            icon: Icon(Icons.message),
            label: 'Mesajlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 16),
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

class ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(value),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 