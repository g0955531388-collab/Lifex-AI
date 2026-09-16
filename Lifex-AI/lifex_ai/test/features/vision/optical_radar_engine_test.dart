import 'package:flutter_test/flutter_test.dart';
import 'package:lifex_ai/features/vision/optical_radar_engine.dart';

void main() {
  test('بدون موافقة الكاميرا لا يدّعي مسافة', () {
    final result = OpticalRadarEngine.instance.probe();
    expect(result.success, isFalse);
    expect(result.distanceMeters, isNull);
    expect(result.messageAr, contains('موافقة'));
  });
}
