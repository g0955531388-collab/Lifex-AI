/// =============================================================
/// Lifex-AI — الأطباء
/// الملف: doctor_directory.dart
/// اختصاصات وترتيب حسب مسافة يدخلها المستخدم، بلا GPS مزيف.
/// =============================================================
library lifex_ai.features.doctors.doctor_directory;

class DoctorDirectory {
  static const specialtiesAr = [
    'طب أسرة',
    'باطنة',
    'قلب',
    'أطفال',
    'نساء وتوليد',
    'جراحة',
    'عظام',
    'أذن أنف حنجرة',
    'عيون',
    'جلدية',
    'نفسية',
    'أسنان',
    'طوارئ',
  ];

  List<Map<String, dynamic>> nearestFirst(
    List<Map<String, dynamic>> doctors, {
    String? specialty,
  }) {
    final filtered = specialty == null || specialty.isEmpty
        ? [...doctors]
        : doctors
            .where((doctor) => doctor['detail']?.toString().contains(specialty) == true)
            .toList();
    filtered.sort((a, b) {
      final ka = double.tryParse(a['km']?.toString() ?? '') ?? 9999;
      final kb = double.tryParse(b['km']?.toString() ?? '') ?? 9999;
      return ka.compareTo(kb);
    });
    return filtered;
  }
}
