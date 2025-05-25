import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../home_page.dart';

class CreateProfilePage extends StatefulWidget {
  final String userEmail;

  const CreateProfilePage({super.key, required this.userEmail});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _taxController = TextEditingController();
  final _aboutController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCity = '';
  String _selectedDistrict = '';
  List<String> _districts = [];

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+90';
    _selectedCity = TurkishLocations.getAllCities().first;
    _updateDistricts();
  }

  void _updateDistricts() {
    setState(() {
      _districts = TurkishLocations.getDistricts(_selectedCity);
      _selectedDistrict = _districts.first;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _companyController.dispose();
    _taxController.dispose();
    _aboutController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        phoneNumber: _phoneController.text,
        city: _selectedCity,
        district: _selectedDistrict,
        detailedAddress: _addressController.text,
        companyName: _companyController.text.isEmpty ? null : _companyController.text,
        taxNumber: _taxController.text.isEmpty ? null : _taxController.text,
        about: _aboutController.text.isEmpty ? null : _aboutController.text,
        createdAt: DateTime.now(),
      );

      // Profili kaydet
      UserRepository.updateUserProfile(widget.userEmail, profile);
      
      // Başarı mesajını göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil başarıyla oluşturuldu'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Ana sayfaya yönlendir
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: widget.userEmail,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Oluştur'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Telefon numarası
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                  hintText: '+905xxxxxxxxx',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Telefon numarası gerekli';
                  }
                  if (!value.startsWith('+90')) {
                    return 'Telefon numarası +90 ile başlamalı';
                  }
                  if (!UserProfile.isValidPhoneNumber(value)) {
                    return 'Geçerli bir telefon numarası girin (+90 ile başlamalı)';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (!value.startsWith('+90')) {
                    _phoneController.text = '+90${value.replaceAll('+90', '')}';
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _phoneController.text.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // İl seçimi
              DropdownButtonFormField<String>(
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
              const SizedBox(height: 16),

              // İlçe seçimi
              DropdownButtonFormField<String>(
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
              const SizedBox(height: 16),

              // Detaylı adres
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Detaylı Adres',
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Adres gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Şirket adı (opsiyonel)
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Şirket Adı (Opsiyonel)',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),

              // Vergi numarası (opsiyonel)
              TextFormField(
                controller: _taxController,
                decoration: const InputDecoration(
                  labelText: 'Vergi Numarası (Opsiyonel)',
                  prefixIcon: Icon(Icons.receipt),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Hakkında (opsiyonel)
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(
                  labelText: 'Hakkında (Opsiyonel)',
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Kaydet butonu
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Profili Oluştur',
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