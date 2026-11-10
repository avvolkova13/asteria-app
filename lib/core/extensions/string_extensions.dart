extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  int get getPercentage {
    final cleanString = this.replaceAll('%', '').trim();
    return int.parse(cleanString);
  }

  double get getPercentageDouble {
    final cleanString = this.replaceAll('%', '').trim();
    return double.parse(cleanString);
  }

  /// Конвертирует строку в формате "dd-MM-yyyy" в DateTime
  /// Пример: "13-05-2025" -> DateTime(2025, 5, 13)
  DateTime toDateTimeFromShortDate() {
    final parts = split('-');
    if (parts.length != 3) {
      throw FormatException('Неверный формат даты. Ожидается формат: dd-MM-yyyy (например, "13-05-2025")');
    }

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      throw FormatException('Не удалось распарсить дату: $this. Ошибка: $e');
    }
  }

  /// Конвертирует строку в формате "dd-MM-yyyy" в строку в формате "dd.MM.yyyy"
  String get toFormattedDateString {
    final date = toDateTimeFromShortDate();
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  DateTime fromRussianShortDate() {
    final parts = this.split('.');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }
}
