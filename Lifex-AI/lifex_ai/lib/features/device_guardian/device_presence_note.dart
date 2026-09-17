/// =============================================================
/// Lifex-AI — حماية الجهاز
/// الملف: device_presence_note.dart
/// آخر حضور محلي. بلا إحداثيات مختلقة وبلا قفل خفي.
/// =============================================================
library lifex_ai.features.device_guardian.device_presence_note;

class DevicePresenceNote {
  const DevicePresenceNote();

  String describe({
    required DateTime? lastLocalHeartbeat,
    required bool lostReported,
    required bool locationReaderBound,
  }) {
    if (lastLocalHeartbeat == null) {
      return 'لا لحظة حضور محفوظة على هذا الجهاز.';
    }
    final stamp = lastLocalHeartbeat.toIso8601String();
    if (lostReported && !locationReaderBound) {
      return 'أُبلِغ عن الفقدان محلياً. آخر نبضة على هذا الهاتف: $stamp. '
          'الموقع الجغرافي غير مربوط، فلن أرسم خريطة.';
    }
    if (!locationReaderBound) {
      return 'آخر نشاط محلي: $stamp. بلا نقطة GPS حتى يُربط قارئ موقع صادق.';
    }
    return 'آخر نشاط محلي: $stamp. الإحداثيات تُقرأ فقط إن أذن المستخدم لمحرك موقع حقيقي.';
  }
}
