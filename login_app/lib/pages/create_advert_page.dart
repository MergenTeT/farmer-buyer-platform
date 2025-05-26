import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/advertisement.dart';
import '../models/user_model.dart';

class CreateAdvertPage extends StatefulWidget {
  final String userEmail;

  const CreateAdvertPage({super.key, required this.userEmail});

  @override
  State<CreateAdvertPage> createState() => _CreateAdvertPageState();
}

class _CreateAdvertPageState extends State<CreateAdvertPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.vegetable;
  UnitType _selectedUnit = UnitType.kg;
  String _selectedCity = '';
  String _selectedDistrict = '';
  List<String> _districts = [];
  List<File> _selectedImages = [];
  bool _isOrganic = false;
  File? _certificateFile;

  DateTime _availableFrom = DateTime.now();
  DateTime _availableTo = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    final user = UserRepository.findUserByEmail(widget.userEmail);
    if (user?.profile != null) {
      _selectedCity = user!.profile!.city;
      _districts = TurkishLocations.getDistricts(_selectedCity);
      _selectedDistrict = user.profile!.district;
    } else {
      _selectedCity = TurkishLocations.getAllCities().first;
      _updateDistricts();
    }
  }

  void _updateDistricts() {
    setState(() {
      _districts = TurkishLocations.getDistricts(_selectedCity);
      _selectedDistrict = _districts.first;
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _pickCertificate() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _certificateFile = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _availableFrom : _availableTo,
      firstDate: isStartDate ? DateTime.now() : _availableFrom,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _availableFrom = picked;
          if (_availableTo.isBefore(_availableFrom)) {
            _availableTo = _availableFrom.add(const Duration(days: 1));
          }
        } else {
          _availableTo = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = UserRepository.findUserByEmail(widget.userEmail);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı bulunamadı!')),
        );
        return;
      }

      final advert = Advertisement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        title: _titleController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        unit: _selectedUnit,
        quantity: double.parse(_quantityController.text),
        city: _selectedCity,
        district: _selectedDistrict,
        description: _descriptionController.text,
        imageUrls: _selectedImages.map((file) => file.path).toList(),
        createdAt: DateTime.now(),
        availableFrom: _availableFrom,
        availableTo: _availableTo,
        isOrganic: _isOrganic,
        certificateUrl: _certificateFile?.path,
      );

      try {
        AdvertRepository.addAdvert(advert);
        // Debug çıktısı
        AdvertRepository.debugPrintAllAdverts();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlan başarıyla eklendi!')),
        );

        // Ana sayfaya dönüş
        if (context.mounted) {
          // Bottom navigation bar'ı 0 (ana sayfa) indexine ayarla
          if (Navigator.canPop(context)) {
            // HomePage widget'ına dön ve bottom navigation bar'ı ana sayfaya ayarla
            Navigator.of(context).pop({'selectedIndex': 0});
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('İlan eklenirken hata oluştu: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Ekle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'İlan Başlığı',
                  hintText: 'Örn: Taze Domates',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Başlık gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori seçimi
              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
                items: ProductCategory.values
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Fiyat ve birim
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Birim Fiyat',
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: '₺',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Fiyat gerekli';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Geçerli bir fiyat girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<UnitType>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Birim',
                      ),
                      items: UnitType.values
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit.displayName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Miktar
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Toplam Miktar',
                  prefixIcon: const Icon(Icons.scale),
                  suffixText: _selectedUnit.displayName,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Miktar gerekli';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir miktar girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Lokasyon
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: const InputDecoration(
                        labelText: 'İl',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: TurkishLocations.getAllCities()
                          .map((city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCity = value;
                            _updateDistricts();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      decoration: const InputDecoration(
                        labelText: 'İlçe',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: _districts
                          .map((district) => DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDistrict = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Satış tarihi aralığı
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Başlangıç'),
                      subtitle: Text(
                        '${_availableFrom.day}/${_availableFrom.month}/${_availableFrom.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Bitiş'),
                      subtitle: Text(
                        '${_availableTo.day}/${_availableTo.month}/${_availableTo.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Organik ürün
              SwitchListTile(
                title: const Text('Organik Ürün'),
                subtitle: const Text('Bu ürün organik sertifikaya sahip'),
                value: _isOrganic,
                onChanged: (bool value) {
                  setState(() {
                    _isOrganic = value;
                    if (!value) {
                      _certificateFile = null;
                    }
                  });
                },
              ),

              // Organik sertifika
              if (_isOrganic) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickCertificate,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_certificateFile != null
                      ? 'Sertifika Seçildi'
                      : 'Organik Sertifika Yükle'),
                ),
              ],
              const SizedBox(height: 16),

              // Fotoğraf ekleme
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Fotoğraf Ekle'),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImages[index],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Kaydet butonu
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'İlanı Yayınla',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 