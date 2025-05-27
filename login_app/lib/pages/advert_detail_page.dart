import 'package:flutter/material.dart';
import '../models/advertisement.dart';
import '../models/user_model.dart';
import '../models/message.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'messages_page.dart';

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadUsers() async {
    try {
      await UserRepository.init(); // Ensure repository is initialized
      _advertOwner = UserRepository.findUserById(widget.advertisement.userId);
      _currentUser = UserRepository.findUserByEmail(widget.currentUserEmail);
      if (_currentUser != null) {
        _isFavorite = UserRepository.getUserFavorites(widget.currentUserEmail)
            .contains(widget.advertisement.id);
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Kullanıcı yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _advertOwner = null;
          _currentUser = null;
          _isFavorite = false;
        });
      }
    }
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

  void _sendMessage() async {
    if (_advertOwner == null) return;

    try {
      // Önce repository'yi başlat
      await MessageRepository.init();

      // Mevcut sohbetleri kontrol et
      final userChats = await MessageRepository.getUserChats(_currentUser!.id);
      final existingChat = userChats.firstWhere(
        (chat) => chat.advertId == widget.advertisement.id &&
            ((chat.user1Id == _currentUser!.id && chat.user2Id == _advertOwner!.id) ||
             (chat.user1Id == _advertOwner!.id && chat.user2Id == _currentUser!.id)),
        orElse: () => Chat(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          user1Id: _currentUser!.id,
          user2Id: _advertOwner!.id,
          advertId: widget.advertisement.id,
          lastMessageTime: DateTime.now(),
          messages: [],
        ),
      );

      if (mounted) {
        // Direkt olarak chat sayfasına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chat: existingChat,
              currentUser: _currentUser!,
              otherUser: _advertOwner!,
              advertisement: widget.advertisement,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sohbet başlatılırken bir hata oluştu. Lütfen tekrar deneyin.'),
          ),
        );
      }
    }
  }

  void _shareImage(String imageUrl) async {
    try {
      if (imageUrl.startsWith('assets/')) {
        // Asset dosyasını paylaşma
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Varsayılan görseller paylaşılamaz')),
        );
      } else {
        // Dosya sistemindeki görseli paylaşma
        await Share.shareFiles(
          [imageUrl],
          text: '${widget.advertisement.title} - ${widget.advertisement.price}₺/${widget.advertisement.unit.displayName}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görsel paylaşılırken bir hata oluştu')),
      );
    }
  }

  void _openGallery(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int i) {
                  String imageUrl = widget.advertisement.imageUrls[i];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: imageUrl.startsWith('assets/')
                        ? AssetImage(imageUrl)
                        : FileImage(File(imageUrl)) as ImageProvider,
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                itemCount: widget.advertisement.imageUrls.length,
                loadingBuilder: (context, event) => Center(
                  child: SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                    ),
                  ),
                ),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                pageController: PageController(initialPage: index),
              ),
              // Kapatma butonu
              Positioned(
                top: 40,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Paylaş butonu
              Positioned(
                top: 40,
                right: 60,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 25),
                  onPressed: () => _shareImage(widget.advertisement.imageUrls[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    Widget errorWidget = Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Görsel yüklenemedi',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            if (!imageUrl.startsWith('assets/'))
              Text(
                'Dosya bulunamadı',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
      ),
    );

    try {
      if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Asset yükleme hatası: $imageUrl - $error');
            return Image.asset(
              Advertisement.getDefaultImageForCategory(widget.advertisement.category),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Varsayılan asset yükleme hatası: $error');
                return errorWidget;
              },
            );
          },
        );
      } else {
        final file = File(imageUrl);
        if (!file.existsSync()) {
          print('Dosya bulunamadı: $imageUrl');
          return Image.asset(
            Advertisement.getDefaultImageForCategory(widget.advertisement.category),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Varsayılan asset yükleme hatası: $error');
              return errorWidget;
            },
          );
        }
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Dosya yükleme hatası: $imageUrl - $error');
            return Image.asset(
              Advertisement.getDefaultImageForCategory(widget.advertisement.category),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Varsayılan asset yükleme hatası: $error');
                return errorWidget;
              },
            );
          },
        );
      }
    } catch (e) {
      print('Görsel yükleme hatası: $imageUrl - $e');
      return errorWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_advertOwner == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              if (widget.advertisement.imageUrls.isNotEmpty) {
                _shareImage(widget.advertisement.imageUrls[_currentImageIndex]);
              }
            },
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
                        return GestureDetector(
                          onTap: () => _openGallery(index),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: _buildImage(widget.advertisement.imageUrls[index]),
                              ),
                              // Paylaş butonu
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  onPressed: () => _shareImage(widget.advertisement.imageUrls[index]),
                                ),
                              ),
                            ],
                          ),
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
                        children: widget.advertisement.imageUrls.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _pageController.animateToPage(
                              entry.key,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == entry.key
                                    ? Theme.of(context).primaryColor
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          );
                        }).toList(),
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
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Üst kısım - Temel bilgiler
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Profil fotoğrafı veya avatar
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _advertOwner!.name.isNotEmpty 
                                          ? _advertOwner!.name.substring(0, 1).toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // İsim ve durum
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _advertOwner!.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _advertOwner!.profile!.isActive ? Colors.green : Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _advertOwner!.profile!.isActive ? 'Aktif' : 'Pasif',
                                            style: TextStyle(
                                              color: _advertOwner!.profile!.isActive ? Colors.grey : Colors.grey[400],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Değerlendirme
                                if (_advertOwner!.profile != null) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            (_advertOwner!.profile!.rating).toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_advertOwner!.profile!.ratingCount} değerlendirme',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          // Alt kısım - İstatistikler
                          if (_advertOwner!.profile != null) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.shopping_bag_outlined,
                                    value: '${_advertOwner!.profile!.totalAdverts}',
                                    label: 'Toplam İlan',
                                  ),
                                  _buildStatItem(
                                    icon: Icons.access_time,
                                    value: _advertOwner!.profile!.getMembershipDuration(),
                                    label: 'Üyelik',
                                  ),
                                  _buildStatItem(
                                    icon: Icons.location_on_outlined,
                                    value: _advertOwner!.profile!.city,
                                    label: 'Konum',
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Divider(height: 1),
                          // İletişim butonları
                          if (_advertOwner!.id != _currentUser?.id) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  if (_advertOwner!.profile != null && _advertOwner!.profile!.phoneNumber.isNotEmpty)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          // Telefon araması işlevi
                                        },
                                        icon: const Icon(Icons.phone_outlined),
                                        label: const Text('Ara'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  if (_advertOwner!.profile != null && _advertOwner!.profile!.phoneNumber.isNotEmpty)
                                    const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _sendMessage,
                                      icon: const Icon(Icons.message_outlined),
                                      label: const Text('Mesaj Gönder'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _advertOwner?.id != _currentUser?.id && _advertOwner != null ? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${widget.advertisement.price.toStringAsFixed(2)} ₺/${widget.advertisement.unit.displayName}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _currentUser != null ? _sendMessage : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mesaj göndermek için giriş yapmalısınız')),
                );
              },
              icon: const Icon(Icons.message),
              label: const Text('Mesaj Gönder'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ) : null,
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 