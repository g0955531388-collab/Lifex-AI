import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('lib/data/reference/SmartCameraSigns.json');
  final raw = file.readAsStringSync();
  final matches = RegExp(r'\{[^{}]+\}').allMatches(raw);
  final items = <Map<String, dynamic>>[];
  for (final match in matches) {
    try {
      items.add(jsonDecode(match.group(0)!) as Map<String, dynamic>);
    } catch (_) {}
  }
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(items));
  stdout.writeln('rewrote ${items.length} camera signs');
}
