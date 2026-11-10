import 'package:asteria_app/core/analytics/event_params.dart';

/// Snapshot of marketing attribution data for a user.
///
/// Maps AppsFlyer conversion / re-attribution payload to a stable, normalized
/// shape that survives across SDK versions and platforms.
///
/// Fields are intentionally optional (except [schemaVersion]) — organic
/// installs and partial payloads are valid states.
class AttributionSnapshot {
  static const int currentSchemaVersion = 1;

  final String? trafficSource;
  final String? campaignId;
  final String? campaignName;
  final String? audienceSegment;
  final String? appsflyerId;
  final String? customerUserId;
  final bool? isOrganic;
  final DateTime? firstTouchAt;
  final DateTime? lastTouchAt;

  // Optional / future-friendly fields. Reserved so that adding more
  // dimensions later (creative, placement, blogger, experiment) does
  // not require a migration of stored snapshots.
  final String? publisher;
  final String? placement;
  final String? creativeId;
  final String? deepLinkValue;
  final Map<String, dynamic>? rawPayload;

  final int schemaVersion;

  const AttributionSnapshot({
    this.trafficSource,
    this.campaignId,
    this.campaignName,
    this.audienceSegment,
    this.appsflyerId,
    this.customerUserId,
    this.isOrganic,
    this.firstTouchAt,
    this.lastTouchAt,
    this.publisher,
    this.placement,
    this.creativeId,
    this.deepLinkValue,
    this.rawPayload,
    this.schemaVersion = currentSchemaVersion,
  });

  bool get isEmpty =>
      trafficSource == null &&
      campaignId == null &&
      campaignName == null &&
      audienceSegment == null &&
      appsflyerId == null &&
      isOrganic == null &&
      firstTouchAt == null &&
      lastTouchAt == null;

  /// Build a snapshot from the raw `data` payload returned by AppsFlyer
  /// conversion / app-open / deep-link callbacks.
  ///
  /// The mapping reflects the OneLink convention used in marketing links:
  ///   pid       → traffic_source
  ///   c         → campaign_name
  ///   af_c_id   → campaign_id
  ///   af_adset  → audience_segment
  ///   af_siteid → publisher
  ///   af_sub_siteid → placement
  ///   af_ad     → creative_id
  static AttributionSnapshot fromAppsFlyerPayload(
    Map<String, dynamic> payload, {
    DateTime? touchAt,
    String? appsflyerId,
    String? customerUserId,
  }) {
    final now = touchAt ?? DateTime.now();
    final afStatus = (payload['af_status'] as String?)?.toLowerCase();
    final isOrganic = afStatus == null ? null : afStatus == 'organic';

    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = payload[key];
        if (value is String && value.isNotEmpty) return value;
      }
      return null;
    }

    final trafficSource = isOrganic == true
        ? 'organic'
        : pickString(['pid', 'media_source']);

    return AttributionSnapshot(
      trafficSource: trafficSource,
      campaignName: pickString(['c', 'campaign']),
      campaignId: pickString(['af_c_id', 'campaign_id']),
      audienceSegment: pickString(['af_adset', 'adset']),
      publisher: pickString(['af_siteid']),
      placement: pickString(['af_sub_siteid']),
      creativeId: pickString(['af_ad']),
      deepLinkValue: pickString(['deep_link_value']),
      isOrganic: isOrganic,
      appsflyerId: appsflyerId,
      customerUserId: customerUserId,
      firstTouchAt: now,
      lastTouchAt: now,
      rawPayload: Map<String, dynamic>.from(payload),
    );
  }

  /// Returns a copy preserving [firstTouchAt] from this snapshot but
  /// taking everything else (including [lastTouchAt]) from [other].
  ///
  /// Used when re-attribution arrives: first_touch is immutable.
  AttributionSnapshot mergeLastTouch(AttributionSnapshot other) {
    return other.copyWith(
      firstTouchAt: firstTouchAt ?? other.firstTouchAt,
    );
  }

  AttributionSnapshot copyWith({
    String? trafficSource,
    String? campaignId,
    String? campaignName,
    String? audienceSegment,
    String? appsflyerId,
    String? customerUserId,
    bool? isOrganic,
    DateTime? firstTouchAt,
    DateTime? lastTouchAt,
    String? publisher,
    String? placement,
    String? creativeId,
    String? deepLinkValue,
    Map<String, dynamic>? rawPayload,
    int? schemaVersion,
  }) {
    return AttributionSnapshot(
      trafficSource: trafficSource ?? this.trafficSource,
      campaignId: campaignId ?? this.campaignId,
      campaignName: campaignName ?? this.campaignName,
      audienceSegment: audienceSegment ?? this.audienceSegment,
      appsflyerId: appsflyerId ?? this.appsflyerId,
      customerUserId: customerUserId ?? this.customerUserId,
      isOrganic: isOrganic ?? this.isOrganic,
      firstTouchAt: firstTouchAt ?? this.firstTouchAt,
      lastTouchAt: lastTouchAt ?? this.lastTouchAt,
      publisher: publisher ?? this.publisher,
      placement: placement ?? this.placement,
      creativeId: creativeId ?? this.creativeId,
      deepLinkValue: deepLinkValue ?? this.deepLinkValue,
      rawPayload: rawPayload ?? this.rawPayload,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schema_version': schemaVersion,
      'traffic_source': trafficSource,
      'campaign_id': campaignId,
      'campaign_name': campaignName,
      'audience_segment': audienceSegment,
      'appsflyer_id': appsflyerId,
      'customer_user_id': customerUserId,
      'is_organic': isOrganic,
      'first_touch_at': firstTouchAt?.toIso8601String(),
      'last_touch_at': lastTouchAt?.toIso8601String(),
      'publisher': publisher,
      'placement': placement,
      'creative_id': creativeId,
      'deep_link_value': deepLinkValue,
      'raw_payload': rawPayload,
    };
  }

  factory AttributionSnapshot.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return AttributionSnapshot(
      schemaVersion: (json['schema_version'] as int?) ?? currentSchemaVersion,
      trafficSource: json['traffic_source'] as String?,
      campaignId: json['campaign_id'] as String?,
      campaignName: json['campaign_name'] as String?,
      audienceSegment: json['audience_segment'] as String?,
      appsflyerId: json['appsflyer_id'] as String?,
      customerUserId: json['customer_user_id'] as String?,
      isOrganic: json['is_organic'] as bool?,
      firstTouchAt: parseDate(json['first_touch_at']),
      lastTouchAt: parseDate(json['last_touch_at']),
      publisher: json['publisher'] as String?,
      placement: json['placement'] as String?,
      creativeId: json['creative_id'] as String?,
      deepLinkValue: json['deep_link_value'] as String?,
      rawPayload: (json['raw_payload'] as Map?)?.cast<String, dynamic>(),
    );
  }

  /// Flattens this snapshot into the parameter map used by
  /// [AnalyticsFacade.trackEvent]. Null fields are omitted so the
  /// AppsFlyer payload stays tidy.
  Map<String, dynamic> toAnalyticsParams() {
    final params = <String, dynamic>{};
    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      params[key] = value;
    }

    put(EventParams.trafficSource, trafficSource);
    put(EventParams.campaignId, campaignId);
    put(EventParams.campaignName, campaignName);
    put(EventParams.audienceSegment, audienceSegment);
    put(EventParams.appsflyerId, appsflyerId);
    put(EventParams.isOrganic, isOrganic);
    put(EventParams.firstTouchAt, firstTouchAt?.toIso8601String());
    put(EventParams.lastTouchAt, lastTouchAt?.toIso8601String());
    put(EventParams.publisher, publisher);
    put(EventParams.placement, placement);
    put(EventParams.creativeId, creativeId);
    return params;
  }
}
