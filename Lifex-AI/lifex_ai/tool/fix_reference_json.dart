import 'dart:convert';
import 'dart:io';

void main() {
  final files = Directory('lib/data/reference')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'));
  for (final file in files) {
    final raw = file.readAsStringSync();
    try {
      jsonDecode(raw);
      continue;
    } catch (_) {}
    final joined = raw.replaceAll(RegExp(r'\]\s*\['), ',');
    try {
      jsonDecode(joined);
      file.writeAsStringSync(joined);
      stdout.writeln('joined-arrays ${file.path}');
      continue;
    } catch (_) {}
    final objects = _extractObjects(raw);
    if (objects.isEmpty) {
      stdout.writeln('FAILED ${file.path}');
      continue;
    }
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(objects));
    stdout.writeln('extracted ${objects.length} ${file.path}');
  }
}

List<Map<String, dynamic>> _extractObjects(String raw) {
  final items = <Map<String, dynamic>>[];
  var depth = 0;
  var start = -1;
  var inString = false;
  var escape = false;
  for (var i = 0; i < raw.length; i++) {
    final ch = raw[i];
    if (inString) {
      if (escape) {
        escape = false;
      } else if (ch == r'\') {
        escape = true;
      } else if (ch == '"') {
        inString = false;
      }
      continue;
    }
    if (ch == '"') {
      inString = true;
      continue;
    }
    if (ch == '{') {
      if (depth == 0) start = i;
      depth++;
    } else if (ch == '}') {
      depth--;
      if (depth == 0 && start >= 0) {
        final slice = raw.substring(start, i + 1);
        try {
          items.add(jsonDecode(slice) as Map<String, dynamic>);
        } catch (_) {}
        start = -1;
      }
    }
  }
  return items;
}
