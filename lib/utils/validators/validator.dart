
String? validatePrice(String minPrice, String maxPrice) {
  final minPriceValue = double.tryParse(minPrice);
  final maxPriceValue = double.tryParse(maxPrice);

  if (minPriceValue != null && minPriceValue < 0) {
    return 'Min price cannot be negative';
  }

  if (maxPriceValue != null && maxPriceValue < 0) {
    return 'Max price cannot be negative';
  }

  if (minPriceValue != null && maxPriceValue != null && minPriceValue > maxPriceValue) {
    return 'Invalid value';
  }

  return null;
}
