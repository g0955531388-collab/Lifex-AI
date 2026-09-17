/// =============================================================
/// Lifex-AI — واجهات التطبيق
/// الملف: system_search_screen.dart
/// بحث في الوحدات والمرجع المحلي. ليس تشخيصاً.
/// =============================================================
library lifex_ai.screens.system_search_screen;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/lasting_search_index.dart';
import '../core/local_knowledge.dart';
import '../core/network_canon.dart';
import '../features/network_box/box_unit_catalog.dart';
import 'blood_request_screen.dart';
import 'box_unit_screen.dart';
import 'project_box_hub_screen.dart';

class SystemSearchScreen extends StatefulWidget {
  const SystemSearchScreen({super.key});

  @override
  State<SystemSearchScreen> createState() => _SystemSearchScreenState();
}

class _SystemSearchScreenState extends State<SystemSearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final knowledge = context.read<LocalKnowledge>();
    LastingSearchIndex lasting;
    try {
      lasting = context.read<LastingSearchIndex>();
    } catch (_) {
      lasting = LastingSearchIndex();
    }
    final aliasSeat =
        _query.isEmpty ? null : NetworkCanon.match(_query);
    final units = BoxUnitCatalog.recordUnits
        .where((unit) =>
            _query.isEmpty ||
            unit.titleAr.contains(_query) ||
            unit.subtitleAr.contains(_query) ||
            (aliasSeat != null && aliasSeat.unitId == unit.id))
        .toList();
    final hits = InternalSearchEngine(knowledge: knowledge, lasting: lasting)
        .search(_query);
    return Scaffold(
      appBar: AppBar(title: const Text('بحث المنظومة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'وحدة أو مرض أو دواء أو عرض',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('صندوق المشروع'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectBoxHubScreen()),
            ),
          ),
          if (aliasSeat?.openBlood == true)
            ListTile(
              leading: const Icon(Icons.bloodtype_outlined),
              title: const Text('شبكة الدم'),
              subtitle: const Text('فرع التبرعات. التنبيه للموافقين على هذا الجهاز فقط'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BloodRequestScreen()),
              ),
            ),
          for (final unit in units)
            ListTile(
              title: Text(unit.titleAr),
              subtitle: Text(unit.subtitleAr),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BoxUnitScreen(unit: unit)),
              ),
            ),
          if (hits.isNotEmpty) ...[
            const Divider(),
            Text(knowledge.disclaimerAr),
            for (final hit in hits)
              ListTile(
                title: Text(hit.titleAr),
                subtitle: Text('${hit.kindAr} — ${hit.detailAr}'),
              ),
          ],
        ],
      ),
    );
  }
}
