import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory('lib/data/reference');
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.json')) continue;
    final raw = entity.readAsStringSync();
    try {
      jsonDecode(raw);
      stdout.writeln('OK ${entity.path}');
    } catch (e) {
      stdout.writeln('BAD ${entity.path}: $e');
    }
  }
}
