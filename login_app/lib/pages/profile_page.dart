import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/advertisement.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String userEmail;

  const ProfilePage({
    super.key,
    required this.userEmail,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _user;
  List<Advertisement> _userAdverts = [];
  List<Advertisement> _favoriteAdverts = [];
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Form kontrolleri
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    _companyController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = UserRepository.findUserByEmail(widget.userEmail);
    if (user != null) {
      setState(() {
        _user = user;
        _userAdverts = AdvertRepository.getUserAdverts(user.id);
        _favoriteAdverts = AdvertRepository.getAdvertsByIds(
          UserRepository.getUserFavorites(widget.userEmail),
        );
        
        // Form kontrollerini doldur
        _nameController.text = user.name;
        if (user.profile != null) {
          _phoneController.text = user.profile!.phoneNumber;
          _cityController.text = user.profile!.city;
          _districtController.text = user.profile!.district;
          _addressController.text = user.profile!.detailedAddress;
          _aboutController.text = user.profile!.about ?? '';
          _companyController.text = user.profile!.companyName ?? '';
          _taxController.text = user.profile!.taxNumber ?? '';
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        final user = _user;
        if (user == null) return;

        // Mevcut profil bilgilerini al veya yeni profil oluştur
        final currentProfile = user.profile;
        final updatedProfile = UserProfile(
          phoneNumber: _phoneController.text,
          city: _cityController.text,
          district: _districtController.text,
          detailedAddress: _addressController.text,
          about: currentProfile?.about,
          companyName: currentProfile?.companyName,
          taxNumber: currentProfile?.taxNumber,
          createdAt: currentProfile?.createdAt ?? DateTime.now(),
          profileImage: image.path,
          favorites: currentProfile?.favorites ?? [],
          rating: currentProfile?.rating ?? 0.0,
          ratingCount: currentProfile?.ratingCount ?? 0,
          totalAdverts: currentProfile?.totalAdverts ?? 0,
          isActive: currentProfile?.isActive ?? true,
        );

        // Kullanıcı bilgilerini güncelle
        final updatedUser = User(
          id: user.id,
          name: user.name,
          email: user.email,
          password: user.password,
          userType: user.userType,
          profile: updatedProfile,
        );

        // Veritabanında güncelle
        UserRepository.updateUser(updatedUser);

        setState(() {
          _user = updatedUser;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellendi')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf seçilirken bir hata oluştu')),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _user;
        if (user == null) return;

        // Mevcut profil bilgilerini al veya yeni profil oluştur
        final currentProfile = user.profile;
        final updatedProfile = UserProfile(
          phoneNumber: _phoneController.text,
          city: _cityController.text,
          district: _districtController.text,
          detailedAddress: _addressController.text,
          about: _aboutController.text.isNotEmpty ? _aboutController.text : null,
          companyName: _companyController.text.isNotEmpty ? _companyController.text : null,
          taxNumber: _taxController.text.isNotEmpty ? _taxController.text : null,
          createdAt: currentProfile?.createdAt ?? DateTime.now(),
          profileImage: currentProfile?.profileImage,
          favorites: currentProfile?.favorites ?? [],
          rating: currentProfile?.rating ?? 0.0,
          ratingCount: currentProfile?.ratingCount ?? 0,
          totalAdverts: currentProfile?.totalAdverts ?? 0,
          isActive: currentProfile?.isActive ?? true,
        );

        // Kullanıcı bilgilerini güncelle
        final updatedUser = User(
          id: user.id,
          name: _nameController.text,
          email: user.email,
          password: user.password,
          userType: user.userType,
          profile: updatedProfile,
        );

        // Veritabanında güncelle
        UserRepository.updateUser(updatedUser);

        setState(() {
          _user = updatedUser;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil güncellenirken hata oluştu: $e')),
        );
      }
    }
  }

  // Şehir seçimi için dialog
  Future<void> _showCityPicker() async {
    final cities = TurkishLocations.getAllCities();
    final selectedCity = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şehir Seçin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                title: Text(city),
                onTap: () => Navigator.pop(context, city),
              );
            },
          ),
        ),
      ),
    );

    if (selectedCity != null) {
      setState(() {
        _cityController.text = selectedCity;
        _districtController.text = ''; // İlçeyi sıfırla
      });
    }
  }

  // İlçe seçimi için dialog
  Future<void> _showDistrictPicker() async {
    if (_cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce şehir seçmelisiniz')),
      );
      return;
    }

    final districts = TurkishLocations.getDistricts(_cityController.text);
    final selectedDistrict = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlçe Seçin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: districts.length,
            itemBuilder: (context, index) {
              final district = districts[index];
              return ListTile(
                title: Text(district),
                onTap: () => Navigator.pop(context, district),
              );
            },
          ),
        ),
      ),
    );

    if (selectedDistrict != null) {
      setState(() {
        _districtController.text = selectedDistrict;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : _toggleEditMode,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'İlanlarım'),
            Tab(text: 'Favoriler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildAdvertsTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil fotoğrafı
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    backgroundImage: _user?.profile?.profileImage != null
                        ? FileImage(File(_user!.profile!.profileImage!))
                        : null,
                    child: _user?.profile?.profileImage == null
                        ? Text(
                            _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 36,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kullanıcı türü
            Center(
              child: Chip(
                label: Text(_user!.userType.displayName),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 24),

            // İstatistikler
            if (_user?.profile != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    icon: Icons.shopping_bag_outlined,
                    value: _user!.profile!.totalAdverts.toString(),
                    label: 'İlan',
                  ),
                  _buildStatCard(
                    icon: Icons.star_outline,
                    value: _user!.profile!.rating.toStringAsFixed(1),
                    label: 'Puan',
                  ),
                  _buildStatCard(
                    icon: Icons.access_time,
                    value: _user!.profile!.getMembershipDuration(),
                    label: 'Üyelik',
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Form alanları
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person_outline),
              ),
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ad Soyad gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '+90...',
              ),
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Telefon numarası gerekli';
                }
                if (!UserProfile.isValidPhoneNumber(value)) {
                  return 'Geçerli bir telefon numarası girin (+90...)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Şehir seçimi
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Şehir',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              enabled: _isEditing,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şehir gerekli';
                }
                return null;
              },
              onTap: _isEditing ? _showCityPicker : null,
            ),
            const SizedBox(height: 16),

            // İlçe seçimi
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'İlçe',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              enabled: _isEditing,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'İlçe gerekli';
                }
                return null;
              },
              onTap: _isEditing ? _showDistrictPicker : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Detaylı Adres',
                prefixIcon: Icon(Icons.home_outlined),
              ),
              enabled: _isEditing,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Adres gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _aboutController,
              decoration: const InputDecoration(
                labelText: 'Hakkımda',
                prefixIcon: Icon(Icons.info_outline),
              ),
              enabled: _isEditing,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            if (_user!.userType == UserType.buyer) ...[
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Firma Adı',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _taxController,
                decoration: const InputDecoration(
                  labelText: 'Vergi Numarası',
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                ),
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvertsTab() {
    if (_userAdverts.isEmpty) {
      return const Center(
        child: Text('Henüz ilan eklenmemiş'),
      );
    }

    return ListView.builder(
      itemCount: _userAdverts.length,
      itemBuilder: (context, index) {
        final advert = _userAdverts[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: advert.imageUrls.isNotEmpty
                    ? advert.imageUrls[0].startsWith('assets/')
                        ? AssetImage(advert.imageUrls[0]) as ImageProvider
                        : FileImage(File(advert.imageUrls[0]))
                    : const AssetImage('assets/images/placeholder.jpg') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(advert.title),
          subtitle: Text(
            '${advert.price.toStringAsFixed(2)} ₺/${advert.unit.displayName}',
          ),
          trailing: Chip(
            label: Text(
              advert.isActive ? 'Aktif' : 'Pasif',
              style: TextStyle(
                color: advert.isActive ? Colors.green : Colors.grey,
              ),
            ),
            backgroundColor: (advert.isActive ? Colors.green : Colors.grey).withOpacity(0.1),
          ),
          onTap: () {
            // TODO: Navigate to advert detail
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (_favoriteAdverts.isEmpty) {
      return const Center(
        child: Text('Henüz favori ilan eklenmemiş'),
      );
    }

    return ListView.builder(
      itemCount: _favoriteAdverts.length,
      itemBuilder: (context, index) {
        final advert = _favoriteAdverts[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: advert.imageUrls.isNotEmpty
                    ? advert.imageUrls[0].startsWith('assets/')
                        ? AssetImage(advert.imageUrls[0]) as ImageProvider
                        : FileImage(File(advert.imageUrls[0]))
                    : const AssetImage('assets/images/placeholder.jpg') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(advert.title),
          subtitle: Text(
            '${advert.price.toStringAsFixed(2)} ₺/${advert.unit.displayName}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              // TODO: Implement remove from favorites
            },
          ),
          onTap: () {
            // TODO: Navigate to advert detail
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 