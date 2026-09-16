/// =============================================================
/// Lifex-AI — الصيدلية
/// الملف: pharmacy_locator.dart
/// أقرب صنف في نفس المدينة من مخزون محلي يدخله المستخدم.
/// =============================================================
library lifex_ai.features.doctors.pharmacy_locator;

class PharmacyLocator {
  List<Map<String, dynamic>> nearestWithDrug({
    required List<Map<String, dynamic>> stock,
    required String query,
    required String city,
  }) {
    final q = query.trim();
    final inCity = stock.where((item) {
      final itemCity = item['city']?.toString() ?? '';
      final sameCity = city.trim().isEmpty ||
          itemCity.trim().isEmpty ||
          itemCity.trim() == city.trim();
      if (!sameCity) return false;
      final qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
      if (qty <= 0) return false;
      if (q.isEmpty) return true;
      final name = item['title']?.toString() ?? '';
      final barcode = item['barcode']?.toString() ?? '';
      return name.contains(q) || barcode == q;
    }).toList()
      ..sort((a, b) {
        final ka = double.tryParse(a['km']?.toString() ?? '') ?? 9999;
        final kb = double.tryParse(b['km']?.toString() ?? '') ?? 9999;
        return ka.compareTo(kb);
      });
    return inCity;
  }
}
