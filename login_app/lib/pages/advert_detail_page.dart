import 'package:flutter/material.dart';
import '../models/advertisement.dart';
import '../models/user_model.dart';
import '../models/message.dart';

class AdvertDetailPage extends StatefulWidget {
  final Advertisement advertisement;
  final String currentUserEmail;

  const AdvertDetailPage({
    super.key,
    required this.advertisement,
    required this.currentUserEmail,
  });

  @override
  State<AdvertDetailPage> createState() => _AdvertDetailPageState();
}

class _AdvertDetailPageState extends State<AdvertDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isFavorite = false;
  User? _advertOwner;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _advertOwner = UserRepository.findUserById(widget.advertisement.userId);
    _currentUser = UserRepository.findUserByEmail(widget.currentUserEmail);
    if (_currentUser != null) {
      _isFavorite = UserRepository.getUserFavorites(widget.currentUserEmail)
          .contains(widget.advertisement.id);
    }
    setState(() {});
  }

  void _toggleFavorite() {
    if (_currentUser != null) {
      UserRepository.toggleFavorite(
        widget.currentUserEmail,
        widget.advertisement.id,
      );
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  void _sendMessage() {
    if (_currentUser != null && _advertOwner != null) {
      MessageRepository.sendMessage(
        senderId: _currentUser!.id,
        receiverId: _advertOwner!.id,
        advertId: widget.advertisement.id,
        content: '${widget.advertisement.title} ilanınız hakkında bilgi almak istiyorum.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesajınız gönderildi')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.advertisement.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resim galerisi
            if (widget.advertisement.imageUrls.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: widget.advertisement.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          widget.advertisement.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Sayfa indikatörü
                  if (widget.advertisement.imageUrls.length > 1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.advertisement.imageUrls.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            else
              Container(
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 50),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.advertisement.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.advertisement.category.displayName,
                              style: TextStyle(
                                fontSize: 16,
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
                            '${widget.advertisement.price.toStringAsFixed(2)} ₺/${widget.advertisement.unit.displayName}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            'Toplam: ${widget.advertisement.totalPrice.toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Miktar ve organik bilgisi
                  Row(
                    children: [
                      Text(
                        'Miktar: ${widget.advertisement.quantity} ${widget.advertisement.unit.displayName}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      if (widget.advertisement.isOrganic)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco,
                                size: 16,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Organik Ürün',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Konum
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        widget.advertisement.location,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Açıklama
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.advertisement.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Satıcı bilgileri
                  if (_advertOwner != null) ...[
                    const Text(
                      'Satıcı Bilgileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          _advertOwner!.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(_advertOwner!.name),
                      subtitle: Text(_advertOwner!.profile?.phoneNumber ?? ''),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _advertOwner?.id != _currentUser?.id
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Satıcıya Mesaj Gönder',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          : null,
    );
  }
} 