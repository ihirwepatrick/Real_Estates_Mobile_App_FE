import 'package:flutter_test/flutter_test.dart';
import 'package:easy_homes_fe/models/property.dart';

void main() {
  test('Property formats RWF rent price', () {
    const p = Property(
      id: '1',
      title: 'Test',
      propertyType: 'apartment',
      listingType: 'rent',
      price: 250000,
    );
    expect(p.formattedPrice.contains('RWF'), isTrue);
    expect(p.formattedPrice.contains('/month'), isTrue);
    expect(p.type, 'Apartment');
  });
}
