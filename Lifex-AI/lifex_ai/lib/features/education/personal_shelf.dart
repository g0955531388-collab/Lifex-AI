/// =============================================================
/// Lifex-AI — التأهيل
/// الملف: personal_shelf.dart
/// رفّ التحميل الشخصي: رابط https يُنزَّل نصاً إلى الجهاز أو يُحذف بطلبك.
/// =============================================================
library lifex_ai.features.education.personal_shelf;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../network_box/profile_box_store.dart';
import '../profile/health_profile.dart';

class ShelfHint {
  const ShelfHint({
    required this.titleAr,
    required this.url,
    required this.noteAr,
  });

  final String titleAr;
  final String url;
  final String noteAr;
}

class ShelfVolumeRecord {
  const ShelfVolumeRecord({
    required this.id,
    required this.titleAr,
    required this.sourceUrl,
    required this.keptAt,
    this.relativeName,
    this.previewAr = '',
    this.bytes = 0,
  });

  final String id;
  final String titleAr;
  final String sourceUrl;
  final DateTime keptAt;
  final String? relativeName;
  final String previewAr;
  final int bytes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'titleAr': titleAr,
        'sourceUrl': sourceUrl,
        'keptAt': keptAt.toIso8601String(),
        'relativeName': relativeName,
        'previewAr': previewAr,
        'bytes': bytes,
      };

  factory ShelfVolumeRecord.fromMap(Map<String, dynamic> map) {
    return ShelfVolumeRecord(
      id: map['id'] as String? ?? '',
      titleAr: map['titleAr'] as String? ?? 'كتاب بلا عنوان',
      sourceUrl: map['sourceUrl'] as String? ?? '',
      keptAt: DateTime.tryParse(map['keptAt'] as String? ?? '') ?? DateTime.now(),
      relativeName: map['relativeName'] as String?,
      previewAr: map['previewAr'] as String? ?? '',
      bytes: map['bytes'] as int? ?? 0,
    );
  }
}

class ShelfFetchResult {
  const ShelfFetchResult.ok({
    required this.titleAr,
    required this.body,
    required this.bytes,
  })  : success = true,
        errorAr = null;

  const ShelfFetchResult.fail(this.errorAr)
      : success = false,
        titleAr = '',
        body = '',
        bytes = 0;

  final bool success;
  final String? errorAr;
  final String titleAr;
  final String body;
  final int bytes;
}

class ShelfDownloadPolicy {
  const ShelfDownloadPolicy();

  static const maxBytes = 2 * 1024 * 1024;
  static const webInlineMaxChars = 40000;

  static const hints = [
    ShelfHint(
      titleAr: 'أليس في بلاد العجائب (نص ملكية عامة)',
      url: 'https://www.gutenberg.org/cache/epub/11/pg11.txt',
      noteAr: 'تجربة تنزيل من مشروع غوتنبرغ. ليست كتاباً طبياً لليفكس.',
    ),
    ShelfHint(
      titleAr: 'كبرياء وتحامل (نص ملكية عامة)',
      url: 'https://www.gutenberg.org/files/1342/1342-0.txt',
      noteAr: 'ملكية عامة للتجربة. احذف إن لم تعد بحاجة إليه.',
    ),
  ];

  String? rejectUri(Uri uri) {
    if (uri.scheme != 'https') {
      return 'يُقبل رابط https فقط.';
    }
    if (uri.host.isEmpty) {
      return 'الرابط بلا مضيف.';
    }
    return null;
  }

  bool acceptContentType(String? raw) {
    final type = (raw ?? '').toLowerCase();
    if (type.isEmpty) return true;
    if (type.contains('text/')) return true;
    if (type.contains('json') || type.contains('xml')) return true;
    if (type.contains('javascript')) return false;
    if (type.contains('octet-stream')) return true;
    if (type.contains('pdf') || type.contains('image/') || type.contains('audio/')) {
      return false;
    }
    return false;
  }

  String readableTitle(Uri uri, String body) {
    final first = body
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.length > 3, orElse: () => '');
    if (first.length >= 4 && first.length <= 80) return first;
    final host = uri.host.replaceAll('www.', '');
    return 'كتاب من $host';
  }

  String peelMarkup(String raw) {
    var text = raw;
    text = text.replaceAll(
      RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
      ' ',
    );
    text = text.replaceAll(
      RegExp(r'<style[\s\S]*?</style>', caseSensitive: false),
      ' ',
    );
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  String prepareBody(String raw, String? contentType) {
    final type = (contentType ?? '').toLowerCase();
    if (type.contains('html')) return peelMarkup(raw);
    return raw.trim();
  }
}

class PersonalShelfDownloader {
  PersonalShelfDownloader({
    http.Client? client,
    this.policy = const ShelfDownloadPolicy(),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final ShelfDownloadPolicy policy;

  Future<ShelfFetchResult> fetch(Uri uri) async {
    final blocked = policy.rejectUri(uri);
    if (blocked != null) return ShelfFetchResult.fail(blocked);
    try {
      final response = await _client.get(
        uri,
        headers: const {
          'Accept': 'text/plain, text/html;q=0.8, */*;q=0.1',
          'User-Agent': 'Lifex-AI personal-shelf',
        },
      ).timeout(const Duration(seconds: 25));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ShelfFetchResult.fail(
          'الخادم ردّ برمز ${response.statusCode}. لم يُحفظ شيء.',
        );
      }
      if (!policy.acceptContentType(response.headers['content-type'])) {
        return const ShelfFetchResult.fail(
          'هذا الملف ليس نصاً مقروءاً هنا (مثل PDF أو صورة). اطلب صفحة نصية.',
        );
      }
      if (response.bodyBytes.length > ShelfDownloadPolicy.maxBytes) {
        return const ShelfFetchResult.fail(
          'الملف أكبر من حدّ الرواق (٢ ميغابايت). لم يُحفظ.',
        );
      }
      final decoded = utf8.decode(response.bodyBytes, allowMalformed: true);
      final body = policy.prepareBody(decoded, response.headers['content-type']);
      if (body.isEmpty) {
        return const ShelfFetchResult.fail('الصفحة وصلت فارغة بعد التنظيف.');
      }
      return ShelfFetchResult.ok(
        titleAr: policy.readableTitle(uri, body),
        body: body,
        bytes: utf8.encode(body).length,
      );
    } on SocketException {
      return const ShelfFetchResult.fail(
        'لا اتصال. التنزيل يحتاج إنترنت حقيقياً.',
      );
    } catch (_) {
      return const ShelfFetchResult.fail(
        'تعذّر التنزيل. لم يُحفظ كتاب.',
      );
    }
  }
}

class PersonalShelfStore {
  PersonalShelfStore(
    this.profile, {
    Directory? documentsOverride,
  }) : _documentsOverride = documentsOverride;

  final HealthProfile profile;
  final Directory? _documentsOverride;

  List<ShelfVolumeRecord> kept() {
    return ProfileBoxStore(profile)
        .list(BoxKeys.personalShelf)
        .map(ShelfVolumeRecord.fromMap)
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<Directory> _root() async {
    if (_documentsOverride != null) return _documentsOverride!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/lifex_knowledge_arcade');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> readBody(ShelfVolumeRecord record) async {
    if (!kIsWeb && record.relativeName != null) {
      final root = await _root();
      final file = File('${root.path}/${record.relativeName}');
      if (await file.exists()) {
        return file.readAsString();
      }
    }
    return record.previewAr;
  }

  Future<ShelfVolumeRecord> keep({
    required String sourceUrl,
    required String titleAr,
    required String body,
    required int bytes,
  }) async {
    final id = 'SHELF-${DateTime.now().millisecondsSinceEpoch}';
    String preview;
    String? relativeName;
    if (kIsWeb) {
      if (body.length > ShelfDownloadPolicy.webInlineMaxChars) {
        throw StateError('الملف أكبر من حد المتصفح. استخدم التطبيق على الجهاز.');
      }
      preview = body;
    } else {
      final root = await _root();
      relativeName = '$id.txt';
      await File('${root.path}/$relativeName').writeAsString(body);
      preview = body.length <= 400 ? body : '${body.substring(0, 400)}…';
    }
    final record = ShelfVolumeRecord(
      id: id,
      titleAr: titleAr,
      sourceUrl: sourceUrl,
      keptAt: DateTime.now(),
      relativeName: relativeName,
      previewAr: preview,
      bytes: bytes,
    );
    ProfileBoxStore(profile).add(BoxKeys.personalShelf, record.toMap());
    return record;
  }

  Future<void> drop(String id) async {
    final items = kept();
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final record = items[index];
    if (!kIsWeb && record.relativeName != null) {
      final root = await _root();
      final file = File('${root.path}/${record.relativeName}');
      if (await file.exists()) {
        await file.delete();
      }
    }
    ProfileBoxStore(profile).removeAt(BoxKeys.personalShelf, index);
  }
}
