import 'package:flutter/material.dart';
import '../models/advertisement.dart';
import '../models/advert_filter.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'advert_detail_page.dart';
import 'dart:io';

class AdvertisementsPage extends StatefulWidget {
  final String userEmail;
  
  const AdvertisementsPage({
    super.key,
    required this.userEmail,
  });

  @override
  State<AdvertisementsPage> createState() => _AdvertisementsPageState();
}

class _AdvertisementsPageState extends State<AdvertisementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  // Filtreleme için değişkenler
  AdvertFilter _currentFilter = const AdvertFilter();
  List<Advertisement> _filteredAdverts = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ProductCategory.values.length + 1, vsync: this); // +1 for "Tümü" tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          if (_tabController.index == 0) {
            // "Tümü" seçildiğinde kategori filtresini kaldır
            _currentFilter = _currentFilter.copyWith(categories: null);
          } else {
            // Diğer kategoriler için filtreleme
            _currentFilter = _currentFilter.copyWith(
              categories: [ProductCategory.values[_tabController.index - 1]], // -1 because of "Tümü" tab
            );
          }
          _loadFilteredAdverts();
        });
      }
    });
    _loadFilteredAdverts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFilteredAdverts() {
    setState(() {
      _filteredAdverts = AdvertRepository.getFilteredAdverts(_currentFilter);
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: FilterBottomSheet(
          currentFilter: _currentFilter,
          onFilterChanged: (filter) {
            setState(() {
              _currentFilter = filter;
              // Kategori seçiliyse tab controller'ı güncelle
              if (filter.categories?.length == 1) {
                final categoryIndex = ProductCategory.values
                    .indexOf(filter.categories!.first);
                _tabController.animateTo(categoryIndex + 1);
              }
              _loadFilteredAdverts();
            });
          },
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _currentFilter = _currentFilter.copyWith(searchQuery: value);
      _loadFilteredAdverts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arama ve Filtreleme Bölümü
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'İlan Ara...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _showFilterBottomSheet,
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtreleme',
              ),
            ],
          ),
        ),

        // Aktif Filtreler
        if (_currentFilter != const AdvertFilter())
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Aktif Filtreler',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentFilter = const AdvertFilter();
                      _searchController.clear();
                      _loadFilteredAdverts();
                    });
                  },
                  child: const Text('Temizle'),
                ),
              ],
            ),
          ),

        // Kategori Tabları
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Tümü'), // Yeni tab eklendi
            ...ProductCategory.values.map((category) {
              return Tab(text: category.displayName);
            }).toList(),
          ],
        ),

        // İlan Listesi
        Expanded(
          child: _filteredAdverts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Filtrelere uygun ilan bulunamadı.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredAdverts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AdvertCard(
                        advertisement: _filteredAdverts[index],
                        userEmail: widget.userEmail,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class AdvertCard extends StatelessWidget {
  final Advertisement advertisement;
  final String userEmail;

  const AdvertCard({
    super.key,
    required this.advertisement,
    required this.userEmail,
  });

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 50),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 50),
          );
        },
      );
    }
  }

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
                currentUserEmail: userEmail,
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
                    child: _buildImage(advertisement.imageUrls.first),
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