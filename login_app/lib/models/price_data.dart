class PriceData {
  final String name;
  final String price;
  final String unit;
  final double change;
  final String lastUpdate;

  PriceData({
    required this.name,
    required this.price,
    required this.unit,
    required this.change,
    required this.lastUpdate,
  });
}

// Örnek gübre fiyatları
final List<PriceData> fertilizers = [
  PriceData(
    name: 'ÜRE Gübresi',
    price: '15.200',
    unit: 'TL/Ton',
    change: 2.3,
    lastUpdate: '21 Mart 2024',
  ),
  PriceData(
    name: 'DAP Gübresi',
    price: '17.800',
    unit: 'TL/Ton',
    change: -1.5,
    lastUpdate: '21 Mart 2024',
  ),
  PriceData(
    name: '20.20.0 Kompoze',
    price: '14.600',
    unit: 'TL/Ton',
    change: 1.8,
    lastUpdate: '21 Mart 2024',
  ),
];

// Örnek akaryakıt fiyatları
final List<PriceData> fuelPrices = [
  PriceData(
    name: 'Mazot',
    price: '41,25',
    unit: 'TL/litre',
    change: -0.5,
    lastUpdate: '21 Mart 2024',
  ),
  PriceData(
    name: 'Benzin',
    price: '43,10',
    unit: 'TL/litre',
    change: 0.8,
    lastUpdate: '21 Mart 2024',
  ),
]; 