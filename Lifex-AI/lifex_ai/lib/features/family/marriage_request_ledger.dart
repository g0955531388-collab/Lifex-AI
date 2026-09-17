/// =============================================================
/// Lifex-AI — الأسرة والمجتمع
/// الملف: marriage_request_ledger.dart
/// ثلاث خطوات باتجاهين: طلب زواج ↔ موافقة، مؤشر النسبة، طلب السبب ↔ موافقة الكشف.
/// =============================================================
library lifex_ai.features.family.marriage_request_ledger;

import '../network_box/profile_box_store.dart';
import '../profile/health_profile.dart';

enum MarriageRequestStatus { pending, accepted, declined }

class MarriageRequest {
  const MarriageRequest({
    required this.id,
    required this.fromProfileId,
    required this.toProfileId,
    required this.status,
    this.reasonAskFromId = '',
    this.reasonAskStatus = MarriageRequestStatus.declined,
  });

  final String id;
  final String fromProfileId;
  final String toProfileId;
  final MarriageRequestStatus status;
  final String reasonAskFromId;
  final MarriageRequestStatus reasonAskStatus;

  bool involves(String profileId) =>
      fromProfileId == profileId || toProfileId == profileId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromProfileId': fromProfileId,
        'toProfileId': toProfileId,
        'status': status.name,
        'reasonAskFromId': reasonAskFromId,
        'reasonAskStatus': reasonAskStatus.name,
      };

  factory MarriageRequest.fromJson(Map<String, dynamic> json) =>
      MarriageRequest(
        id: json['id'] as String? ?? '',
        fromProfileId: json['fromProfileId'] as String? ?? '',
        toProfileId: json['toProfileId'] as String? ?? '',
        status: MarriageRequestStatus.values.firstWhere(
          (item) => item.name == json['status'],
          orElse: () => MarriageRequestStatus.pending,
        ),
        reasonAskFromId: json['reasonAskFromId'] as String? ?? '',
        reasonAskStatus: MarriageRequestStatus.values.firstWhere(
          (item) => item.name == json['reasonAskStatus'],
          orElse: () => MarriageRequestStatus.declined,
        ),
      );
}

class MarriageRequestLedger {
  MarriageRequest send({
    required HealthProfile from,
    required HealthProfile to,
  }) {
    if (from.profileId == to.profileId) {
      throw ArgumentError('لا يُرسل الطلب إلى نفس الملف.');
    }
    final existing = pairOf(from, to);
    if (existing != null) {
      if (existing.status == MarriageRequestStatus.pending &&
          existing.toProfileId == from.profileId) {
        return setStatus(
              from: to,
              to: from,
              requestId: existing.id,
              status: MarriageRequestStatus.accepted,
            ) ??
            existing;
      }
      return existing;
    }

    final request = MarriageRequest(
      id: 'MR-${DateTime.now().millisecondsSinceEpoch}',
      fromProfileId: from.profileId,
      toProfileId: to.profileId,
      status: MarriageRequestStatus.pending,
    );
    _writeBoth(from, to, request);
    return request;
  }

  MarriageRequest? setStatus({
    required HealthProfile from,
    required HealthProfile to,
    required String requestId,
    required MarriageRequestStatus status,
  }) {
    final current = allFor(to)
        .where((item) =>
            item.id == requestId &&
            item.involves(to.profileId) &&
            item.toProfileId == to.profileId)
        .toList();
    if (current.isEmpty) return null;
    final updated = MarriageRequest(
      id: current.first.id,
      fromProfileId: current.first.fromProfileId,
      toProfileId: current.first.toProfileId,
      status: status,
      reasonAskFromId: current.first.reasonAskFromId,
      reasonAskStatus: current.first.reasonAskStatus,
    );
    _writeBoth(from, to, updated, replaceId: requestId);
    return updated;
  }

  List<MarriageRequest> pendingFor(HealthProfile profile) => allFor(profile)
      .where(
        (item) =>
            item.toProfileId == profile.profileId &&
            item.status == MarriageRequestStatus.pending,
      )
      .toList();

  List<MarriageRequest> acceptedInvolving(HealthProfile profile) =>
      allFor(profile)
          .where((item) =>
              item.involves(profile.profileId) &&
              item.status == MarriageRequestStatus.accepted)
          .toList();

  List<MarriageRequest> pendingReasonFor(HealthProfile profile) =>
      allFor(profile)
          .where(
            (item) =>
                item.status == MarriageRequestStatus.accepted &&
                item.reasonAskStatus == MarriageRequestStatus.pending &&
                item.reasonAskFromId.isNotEmpty &&
                item.reasonAskFromId != profile.profileId &&
                item.involves(profile.profileId),
          )
          .toList();

  MarriageRequest? askReason({
    required HealthProfile from,
    required HealthProfile to,
    required String requestId,
    required String askerId,
  }) {
    final current =
        allFor(from).where((item) => item.id == requestId).toList();
    if (current.isEmpty) return null;
    if (current.first.status != MarriageRequestStatus.accepted) return null;
    final updated = MarriageRequest(
      id: current.first.id,
      fromProfileId: current.first.fromProfileId,
      toProfileId: current.first.toProfileId,
      status: current.first.status,
      reasonAskFromId: askerId,
      reasonAskStatus: MarriageRequestStatus.pending,
    );
    _writeBoth(from, to, updated, replaceId: requestId);
    return updated;
  }

  MarriageRequest? answerReason({
    required HealthProfile from,
    required HealthProfile to,
    required String requestId,
    required bool accept,
  }) {
    final current =
        allFor(to).where((item) => item.id == requestId).toList();
    if (current.isEmpty) return null;
    if (current.first.reasonAskStatus != MarriageRequestStatus.pending) {
      return null;
    }
    if (current.first.reasonAskFromId == to.profileId) return null;
    final updated = MarriageRequest(
      id: current.first.id,
      fromProfileId: current.first.fromProfileId,
      toProfileId: current.first.toProfileId,
      status: current.first.status,
      reasonAskFromId: current.first.reasonAskFromId,
      reasonAskStatus: accept
          ? MarriageRequestStatus.accepted
          : MarriageRequestStatus.declined,
    );
    _writeBoth(from, to, updated, replaceId: requestId);
    return updated;
  }

  MarriageRequest? pairOf(HealthProfile a, HealthProfile b) {
    final open = allFor(a).where(
      (item) =>
          item.involves(a.profileId) &&
          item.involves(b.profileId) &&
          item.status != MarriageRequestStatus.declined,
    );
    return open.isEmpty ? null : open.last;
  }

  List<MarriageRequest> allFor(HealthProfile profile) {
    return ProfileBoxStore(profile)
        .list(BoxKeys.marriageRequests)
        .map(MarriageRequest.fromJson)
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  void _writeBoth(
    HealthProfile a,
    HealthProfile b,
    MarriageRequest request, {
    String? replaceId,
  }) {
    for (final profile in [a, b]) {
      final store = ProfileBoxStore(profile);
      final items = store.list(BoxKeys.marriageRequests);
      final kept = items
          .where((item) => item['id'] != (replaceId ?? request.id))
          .toList();
      kept.add(request.toJson());
      store.setList(BoxKeys.marriageRequests, kept);
    }
  }
}
