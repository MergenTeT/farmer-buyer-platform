import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  final _messageController = TextEditingController();
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
    if (_messageController.text.isNotEmpty &&
        _currentUser != null &&
        _advertOwner != null) {
      MessageRepository.sendMessage(
        senderId: _currentUser!.id,
        receiverId: _advertOwner!.id,
        advertId: widget.advertisement.id,
        content: _messageController.text,
      );
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesajınız gönderildi')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
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
            // Fotoğraf galerisi
            if (widget.advertisement.imageUrls.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                ),
                items: widget.advertisement.imageUrls.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.asset(
                        imageUrl,
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
                  );
                }).toList(),
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
                          widget.advertisement.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Kategori ve miktar
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.advertisement.category.displayName),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                            '${widget.advertisement.quantity} ${widget.advertisement.unit.displayName}'),
                        backgroundColor: Colors.grey[200],
                      ),
                      if (widget.advertisement.isOrganic) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('Organik'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lokasyon
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(widget.advertisement.location),
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Satış tarihi
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      'Satış Tarihi: ${widget.advertisement.availableFrom.day}/${widget.advertisement.availableFrom.month}/${widget.advertisement.availableFrom.year} - '
                      '${widget.advertisement.availableTo.day}/${widget.advertisement.availableTo.month}/${widget.advertisement.availableTo.year}',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),

                  const Divider(),

                  // Açıklama
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.advertisement.description),
                  const SizedBox(height: 16),

                  if (widget.advertisement.isOrganic &&
                      widget.advertisement.certificateUrl != null) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.verified),
                      title: const Text('Organik Sertifika'),
                      trailing: const Icon(Icons.download),
                      onTap: () {
                        // TODO: Sertifika indirme/görüntüleme
                      },
                    ),
                  ],

                  const Divider(),

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
                      leading: CircleAvatar(
                        child: Text(_advertOwner!.name[0].toUpperCase()),
                      ),
                      title: Text(_advertOwner!.name),
                      subtitle: Text(_advertOwner!.profile?.phoneNumber ?? ''),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Mesaj gönderme
                  if (_currentUser?.id != widget.advertisement.userId) ...[
                    const Text(
                      'Satıcıya Mesaj Gönder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Mesajınızı yazın...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 