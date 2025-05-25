import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/advertisement.dart';

class FavoritesPage extends StatelessWidget {
  final String userEmail;

  const FavoritesPage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    final favorites = UserRepository.getUserFavorites(userEmail);
    final adverts = AdvertRepository.getAllAdverts()
        .where((advert) => favorites.contains(advert.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori İlanlarım'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adverts.length,
        itemBuilder: (context, index) {
          final advert = adverts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: advert.imageUrls.isNotEmpty
                ? Image.asset(
                    advert.imageUrls.first,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported),
              title: Text(advert.title),
              subtitle: Text(
                '${advert.price.toStringAsFixed(2)} ₺/${advert.unit.displayName}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  UserRepository.toggleFavorite(userEmail, advert.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('İlan favorilerden kaldırıldı'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
} 