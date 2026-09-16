import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('مراجع Android Studio تُحمَّل كـ JSON صالح', () async {
    final camera =
        jsonDecode(await rootBundle.loadString('lib/data/reference/SmartCameraSigns.json'));
    final growth =
        jsonDecode(await rootBundle.loadString('lib/data/reference/Height_Weight.json'));
    final drugs =
        jsonDecode(await rootBundle.loadString('lib/data/reference/drugs/Antibiotics.json'));

    expect(camera, isA<List>());
    expect((camera as List).length, greaterThan(50));
    expect(growth, isA<List>());
    expect(drugs, isA<List>());
    expect((drugs as List).first['name'], isNotNull);
  });
}
