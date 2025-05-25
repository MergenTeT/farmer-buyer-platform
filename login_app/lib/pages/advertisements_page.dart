import 'package:flutter/material.dart';
import '../models/advertisement.dart';

class AdvertisementsPage extends StatefulWidget {
  const AdvertisementsPage({super.key});

  @override
  State<AdvertisementsPage> createState() => _AdvertisementsPageState();
}

class _AdvertisementsPageState extends State<AdvertisementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProductCategory _selectedCategory = ProductCategory.vegetable;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ProductCategory.values.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = ProductCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ProductCategory.values.map((category) {
            return Tab(text: category.displayName);
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: ProductCategory.values.map((category) {
              final adverts = AdvertRepository.getAdvertsByCategory(category);
              return AdvertListView(advertisements: adverts);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class AdvertListView extends StatelessWidget {
  final List<Advertisement> advertisements;

  const AdvertListView({
    super.key,
    required this.advertisements,
  });

  @override
  Widget build(BuildContext context) {
    if (advertisements.isEmpty) {
      return const Center(
        child: Text('Bu kategoride henüz ilan bulunmuyor.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: advertisements.length,
      itemBuilder: (context, index) {
        final advert = advertisements[index];
        return AdvertCard(advertisement: advert);
      },
    );
  }
}

class AdvertCard extends StatelessWidget {
  final Advertisement advertisement;

  const AdvertCard({
    super.key,
    required this.advertisement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İlan resmi
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
                // Başlık ve fiyat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        advertisement.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${advertisement.price.toStringAsFixed(2)} ₺',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Konum
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      advertisement.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Açıklama
                Text(
                  advertisement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Tarih ve detay butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getTimeAgo(advertisement.createdAt),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: İlan detay sayfasına yönlendir
                      },
                      child: const Text('Detayları Gör'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
} 