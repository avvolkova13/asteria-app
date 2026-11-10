import 'package:asteria_app/features/home/presentation/models/year_animal_asset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps calendar year to animal asset', () {
    expect(YearAnimalAsset.forYear(2020), endsWith('/rat.webp'));
    expect(YearAnimalAsset.forYear(2021), endsWith('/ox.webp'));
    expect(YearAnimalAsset.forYear(2022), endsWith('/tiger.webp'));
    expect(YearAnimalAsset.forYear(2023), endsWith('/rabbit.webp'));
    expect(YearAnimalAsset.forYear(2024), endsWith('/dragon.webp'));
    expect(YearAnimalAsset.forYear(2025), endsWith('/snake.webp'));
    expect(YearAnimalAsset.forYear(2026), endsWith('/horse.webp'));
    expect(YearAnimalAsset.forYear(2027), endsWith('/goat.webp'));
    expect(YearAnimalAsset.forYear(2028), endsWith('/monkey.webp'));
    expect(YearAnimalAsset.forYear(2029), endsWith('/rooster.webp'));
    expect(YearAnimalAsset.forYear(2030), endsWith('/dog.webp'));
    expect(YearAnimalAsset.forYear(2031), endsWith('/pig.webp'));
  });

  test('cycles every twelve years', () {
    expect(YearAnimalAsset.forYear(1996), YearAnimalAsset.forYear(2008));
  });
}
