class BackendAppUpdateCheckRequest {
  const BackendAppUpdateCheckRequest({
    required this.platform,
    this.currentVersion,
    this.buildNumber,
    this.channel,
    this.locale,
  });

  final String platform;
  final String? currentVersion;
  final String? buildNumber;
  final String? channel;
  final String? locale;

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'currentVersion': currentVersion,
      'buildNumber': buildNumber,
      'channel': channel,
      'locale': locale,
    };
  }
}

class BackendAppUpdateCheckResponse {
  const BackendAppUpdateCheckResponse({
    required this.status,
    this.latestVersion,
    this.minSupportedVersion,
    this.title,
    this.message,
    this.storeUrl,
    this.snoozeHours,
    this.forceAfter,
  });

  final String status;
  final String? latestVersion;
  final String? minSupportedVersion;
  final String? title;
  final String? message;
  final String? storeUrl;
  final int? snoozeHours;
  final DateTime? forceAfter;

  factory BackendAppUpdateCheckResponse.fromJson(Map<String, dynamic> json) {
    String? stringValue(String key) {
      final value = json[key];
      if (value == null) {
        return null;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    int? intValue(String key) {
      final value = json[key];
      if (value == null) {
        return null;
      }
      if (value is int) {
        return value;
      }
      if (value is double) {
        return value.round();
      }
      return int.tryParse(value.toString().trim());
    }

    DateTime? dateValue(String key) {
      final text = stringValue(key);
      if (text == null) {
        return null;
      }
      return DateTime.tryParse(text)?.toUtc();
    }

    return BackendAppUpdateCheckResponse(
      status: stringValue('status') ?? 'none',
      latestVersion:
          stringValue('latestVersion') ?? stringValue('latest_version'),
      minSupportedVersion:
          stringValue('minSupportedVersion') ??
          stringValue('min_supported_version'),
      title: stringValue('title'),
      message: stringValue('message'),
      storeUrl: stringValue('storeUrl') ?? stringValue('store_url'),
      snoozeHours: intValue('snoozeHours') ?? intValue('snooze_hours'),
      forceAfter: dateValue('forceAfter') ?? dateValue('force_after'),
    );
  }
}
