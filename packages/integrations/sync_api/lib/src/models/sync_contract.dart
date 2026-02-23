class SyncChangesPayload {
  const SyncChangesPayload({
    this.collections = const [],
    this.items = const [],
    this.tags = const [],
  });

  final List<Map<String, dynamic>> collections;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> tags;

  bool get isEmpty => collections.isEmpty && items.isEmpty && tags.isEmpty;

  int get totalCount => collections.length + items.length + tags.length;

  Map<String, dynamic> toJson() {
    return {'collections': collections, 'items': items, 'tags': tags};
  }
}

class SyncRequestPayload {
  const SyncRequestPayload({
    required this.deviceId,
    this.schemaVersion = 'v1',
    this.clientRequestId,
    this.lastSyncAt,
    this.changes,
  });

  final String schemaVersion;
  final String? clientRequestId;
  final String deviceId;
  final DateTime? lastSyncAt;
  final SyncChangesPayload? changes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'deviceId': deviceId,
    };
    if (clientRequestId != null) {
      map['clientRequestId'] = clientRequestId;
    }
    if (lastSyncAt != null) {
      map['lastSyncAt'] = lastSyncAt!.toUtc().toIso8601String();
    }
    if (changes != null && !changes!.isEmpty) {
      map['changes'] = changes!.toJson();
    }
    return map;
  }
}

class SyncCapabilities {
  const SyncCapabilities({
    required this.apiVersion,
    required this.supportedModes,
    required this.maxBatchSize,
    required this.conflictStrategy,
    required this.acceptedSchemaVersions,
  });

  final String apiVersion;
  final List<String> supportedModes;
  final int maxBatchSize;
  final String conflictStrategy;
  final List<String> acceptedSchemaVersions;

  factory SyncCapabilities.fromJson(Map<String, dynamic> json) {
    return SyncCapabilities(
      apiVersion: json['apiVersion'] as String? ?? 'v1',
      supportedModes: _toStringList(json['supportedModes']),
      maxBatchSize: (json['maxBatchSize'] as num?)?.toInt() ?? 1000,
      conflictStrategy:
          json['conflictStrategy'] as String? ?? 'last_write_wins',
      acceptedSchemaVersions: _toStringList(json['acceptedSchemaVersions']),
    );
  }

  static List<String> _toStringList(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList(growable: false);
  }
}

class SyncResponsePayload {
  const SyncResponsePayload({
    required this.lastSyncAt,
    required this.serverChanges,
    required this.conflicts,
    required this.syncedCollections,
    required this.syncedItems,
    required this.syncedTags,
    required this.conflictsResolved,
  });

  final DateTime lastSyncAt;
  final SyncChangesPayload serverChanges;
  final List<Map<String, dynamic>> conflicts;
  final int syncedCollections;
  final int syncedItems;
  final int syncedTags;
  final int conflictsResolved;

  factory SyncResponsePayload.fromJson(Map<String, dynamic> json) {
    final serverChangesJson =
        (json['serverChanges'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return SyncResponsePayload(
      lastSyncAt:
          DateTime.tryParse(json['lastSyncAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      serverChanges: SyncChangesPayload(
        collections: _toJsonMapList(serverChangesJson['collections']),
        items: _toJsonMapList(serverChangesJson['items']),
        tags: _toJsonMapList(serverChangesJson['tags']),
      ),
      conflicts: _toJsonMapList(json['conflicts']),
      syncedCollections: (json['syncedCollections'] as num?)?.toInt() ?? 0,
      syncedItems: (json['syncedItems'] as num?)?.toInt() ?? 0,
      syncedTags: (json['syncedTags'] as num?)?.toInt() ?? 0,
      conflictsResolved: (json['conflictsResolved'] as num?)?.toInt() ?? 0,
    );
  }

  static List<Map<String, dynamic>> _toJsonMapList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => entry.cast<String, dynamic>())
        .toList(growable: false);
  }
}
