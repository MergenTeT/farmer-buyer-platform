import 'package:flutter/material.dart';
import 'advertisement.dart';

class AdvertFilter {
  final RangeValues? priceRange;
  final RangeValues? quantityRange;
  final List<ProductCategory>? categories;
  final List<String>? cities;
  final String? district;
  final bool? isOrganic;
  final List<UnitType>? units;
  final DateTimeRange? availabilityRange;
  final String? searchQuery;
  final SortOption sortOption;

  const AdvertFilter({
    this.priceRange,
    this.quantityRange,
    this.categories,
    this.cities,
    this.district,
    this.isOrganic,
    this.units,
    this.availabilityRange,
    this.searchQuery,
    this.sortOption = SortOption.newest,
  });

  AdvertFilter copyWith({
    RangeValues? priceRange,
    RangeValues? quantityRange,
    List<ProductCategory>? categories,
    List<String>? cities,
    String? district,
    bool? isOrganic,
    List<UnitType>? units,
    DateTimeRange? availabilityRange,
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return AdvertFilter(
      priceRange: priceRange ?? this.priceRange,
      quantityRange: quantityRange ?? this.quantityRange,
      categories: categories ?? this.categories,
      cities: cities ?? this.cities,
      district: district ?? this.district,
      isOrganic: isOrganic ?? this.isOrganic,
      units: units ?? this.units,
      availabilityRange: availabilityRange ?? this.availabilityRange,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdvertFilter &&
        other.priceRange == priceRange &&
        other.quantityRange == quantityRange &&
        other.categories == categories &&
        other.cities == cities &&
        other.district == district &&
        other.isOrganic == isOrganic &&
        other.units == units &&
        other.availabilityRange == availabilityRange &&
        other.searchQuery == searchQuery &&
        other.sortOption == sortOption;
  }

  @override
  int get hashCode {
    return priceRange.hashCode ^
        quantityRange.hashCode ^
        categories.hashCode ^
        cities.hashCode ^
        district.hashCode ^
        isOrganic.hashCode ^
        units.hashCode ^
        availabilityRange.hashCode ^
        searchQuery.hashCode ^
        sortOption.hashCode;
  }

  bool matches(Advertisement advert) {
    if (!advert.isActive) return false;

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!advert.title.toLowerCase().contains(query) &&
          !advert.description.toLowerCase().contains(query) &&
          !advert.city.toLowerCase().contains(query) &&
          !advert.district.toLowerCase().contains(query)) {
        return false;
      }
    }

    if (priceRange != null) {
      if (advert.price < priceRange!.start || advert.price > priceRange!.end) {
        return false;
      }
    }

    if (quantityRange != null) {
      if (advert.quantity < quantityRange!.start || 
          advert.quantity > quantityRange!.end) {
        return false;
      }
    }

    if (categories != null && categories!.isNotEmpty) {
      if (!categories!.contains(advert.category)) {
        return false;
      }
    }

    if (cities != null && cities!.isNotEmpty) {
      if (!cities!.contains(advert.city)) {
        return false;
      }
    }

    if (district != null && district!.isNotEmpty) {
      if (advert.district != district) {
        return false;
      }
    }

    if (isOrganic != null) {
      if (advert.isOrganic != isOrganic) {
        return false;
      }
    }

    if (units != null && units!.isNotEmpty) {
      if (!units!.contains(advert.unit)) {
        return false;
      }
    }

    if (availabilityRange != null) {
      if (advert.availableFrom.isAfter(availabilityRange!.end) ||
          advert.availableTo.isBefore(availabilityRange!.start)) {
        return false;
      }
    }

    return true;
  }
}

enum SortOption {
  newest('En Yeni'),
  oldest('En Eski'),
  priceHighToLow('Fiyat: Yüksekten Düşüğe'),
  priceLowToHigh('Fiyat: Düşükten Yükseğe'),
  quantityHighToLow('Miktar: Çoktan Aza'),
  quantityLowToHigh('Miktar: Azdan Çoğa');

  final String displayName;
  const SortOption(this.displayName);
}

extension AdvertSorting on List<Advertisement> {
  List<Advertisement> applySorting(SortOption sortOption) {
    final sorted = List<Advertisement>.from(this);
    switch (sortOption) {
      case SortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOption.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.quantityHighToLow:
        sorted.sort((a, b) => b.quantity.compareTo(a.quantity));
      case SortOption.quantityLowToHigh:
        sorted.sort((a, b) => a.quantity.compareTo(b.quantity));
    }
    return sorted;
  }
} 