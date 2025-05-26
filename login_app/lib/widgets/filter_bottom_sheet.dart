import 'package:flutter/material.dart';
import '../models/advertisement.dart';
import '../models/advert_filter.dart';
import '../utils/turkish_locations.dart';

class FilterBottomSheet extends StatefulWidget {
  final AdvertFilter currentFilter;
  final Function(AdvertFilter) onFilterChanged;

  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late AdvertFilter _filter;
  final _priceRangeValues = RangeValues(0, 1000);
  final _quantityRangeValues = RangeValues(0, 10000);

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtreleme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filter = const AdvertFilter();
                  });
                  widget.onFilterChanged(_filter);
                },
                child: const Text('Filtreleri Temizle'),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fiyat Aralığı
                  const Text(
                    'Fiyat Aralığı',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: _filter.priceRange ?? _priceRangeValues,
                    min: _priceRangeValues.start,
                    max: _priceRangeValues.end,
                    divisions: 100,
                    labels: RangeLabels(
                      '${(_filter.priceRange?.start ?? _priceRangeValues.start).toStringAsFixed(2)}₺',
                      '${(_filter.priceRange?.end ?? _priceRangeValues.end).toStringAsFixed(2)}₺',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _filter = _filter.copyWith(priceRange: values);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Miktar Aralığı
                  const Text(
                    'Miktar Aralığı',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: _filter.quantityRange ?? _quantityRangeValues,
                    min: _quantityRangeValues.start,
                    max: _quantityRangeValues.end,
                    divisions: 100,
                    labels: RangeLabels(
                      (_filter.quantityRange?.start ?? _quantityRangeValues.start).toString(),
                      (_filter.quantityRange?.end ?? _quantityRangeValues.end).toString(),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _filter = _filter.copyWith(quantityRange: values);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Kategoriler
                  const Text(
                    'Kategoriler',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: ProductCategory.values.map((category) {
                      final isSelected = _filter.categories?.contains(category) ?? false;
                      return FilterChip(
                        label: Text(category.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            final categories = List<ProductCategory>.from(
                              _filter.categories ?? [],
                            );
                            if (selected) {
                              categories.add(category);
                            } else {
                              categories.remove(category);
                            }
                            _filter = _filter.copyWith(categories: categories);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Birim Tipleri
                  const Text(
                    'Birim Tipleri',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: UnitType.values.map((unit) {
                      final isSelected = _filter.units?.contains(unit) ?? false;
                      return FilterChip(
                        label: Text(unit.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            final units = List<UnitType>.from(
                              _filter.units ?? [],
                            );
                            if (selected) {
                              units.add(unit);
                            } else {
                              units.remove(unit);
                            }
                            _filter = _filter.copyWith(units: units);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Şehir Seçimi
                  const Text(
                    'Şehirler',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    value: _filter.cities?.isNotEmpty == true ? _filter.cities!.first : null,
                    decoration: const InputDecoration(
                      hintText: 'Şehir seçin',
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
                          _filter = _filter.copyWith(
                            cities: [value],
                            district: null,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // İlçe Seçimi
                  if (_filter.cities?.isNotEmpty == true)
                    DropdownButtonFormField<String>(
                      value: _filter.district,
                      decoration: const InputDecoration(
                        hintText: 'İlçe seçin',
                      ),
                      items: TurkishLocations.getDistricts(_filter.cities!.first)
                          .map((district) => DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(district: value);
                        });
                      },
                    ),
                  const SizedBox(height: 16),

                  // Organik Ürün Filtresi
                  SwitchListTile(
                    title: const Text('Sadece Organik Ürünler'),
                    value: _filter.isOrganic ?? false,
                    onChanged: (value) {
                      setState(() {
                        _filter = _filter.copyWith(isOrganic: value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sıralama Seçenekleri
                  const Text(
                    'Sıralama',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<SortOption>(
                    value: _filter.sortOption,
                    items: SortOption.values
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _filter = _filter.copyWith(sortOption: value);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onFilterChanged(_filter);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Filtreleri Uygula'),
          ),
        ],
      ),
    );
  }
} 