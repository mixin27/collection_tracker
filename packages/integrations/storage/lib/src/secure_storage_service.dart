import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storage/src/exceptions/storage_exception.dart';

/// Service for secure local storage operations using flutter_secure_storage
class SecureStorageService {
  SecureStorageService._() {
    _storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  static SecureStorageService? _instance;
  late FlutterSecureStorage _storage;

  /// Get singleton instance
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._();
    return _instance!;
  }

  /// Save a value securely with optional TTL (time-to-live in seconds)
  Future<void> save<T>(String key, T value, {int? ttl}) async {
    try {
      if (ttl != null) {
        final expiryKey = '${key}_expiry';
        final expiryTime = DateTime.now().add(Duration(seconds: ttl));
        await _storage.write(
          key: expiryKey,
          value: expiryTime.toIso8601String(),
        );
      }

      if (value == null) {
        await _storage.delete(key: key);
        return;
      }

      String stringValue;
      String? typeMarker;

      if (value is String) {
        stringValue = value;
        typeMarker = 'String';
      } else if (value is int) {
        stringValue = value.toString();
        typeMarker = 'int';
      } else if (value is double) {
        stringValue = value.toString();
        typeMarker = 'double';
      } else if (value is bool) {
        stringValue = value.toString();
        typeMarker = 'bool';
      } else if (value is List<String>) {
        stringValue = jsonEncode(value);
        typeMarker = 'List<String>';
      } else if (value is List<int>) {
        stringValue = jsonEncode(value);
        typeMarker = 'List<int>';
      } else if (value is List) {
        stringValue = jsonEncode(value);
        typeMarker = 'List';
      } else if (value is Map) {
        stringValue = jsonEncode(value);
        typeMarker = 'Map';
      } else {
        // Try to serialize as JSON for custom objects
        try {
          stringValue = jsonEncode(value);
          typeMarker = 'Object';
        } catch (e) {
          throw SerializationException(
            'Cannot serialize value of type ${value.runtimeType}',
            key: key,
            originalError: e,
          );
        }
      }

      await _storage.write(key: key, value: stringValue);
      if (typeMarker.isNotEmpty) {
        await _storage.write(key: '${key}_type', value: typeMarker);
      }
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        'Failed to save secure value',
        key: key,
        originalError: e,
      );
    }
  }

  /// Check if a key has expired (for TTL support)
  Future<bool> _isExpired(String key) async {
    final expiryKey = '${key}_expiry';
    final expiryString = await _storage.read(key: expiryKey);

    if (expiryString == null) return false;

    final expiryTime = DateTime.parse(expiryString);
    final isExpired = DateTime.now().isAfter(expiryTime);

    if (isExpired) {
      await delete(key);
      await _storage.delete(key: expiryKey);
    }

    return isExpired;
  }

  /// Retrieve a value by key
  Future<T?> get<T>(String key) async {
    try {
      // Check if expired
      if (await _isExpired(key)) {
        return null;
      }

      final stringValue = await _storage.read(key: key);
      if (stringValue == null) return null;

      final typeMarker = await _storage.read(key: '${key}_type');

      // Handle primitive types
      if (typeMarker == 'String' || T == String) {
        return stringValue as T;
      } else if (typeMarker == 'int' || T == int) {
        return int.parse(stringValue) as T;
      } else if (typeMarker == 'double' || T == double) {
        return double.parse(stringValue) as T;
      } else if (typeMarker == 'bool' || T == bool) {
        return (stringValue.toLowerCase() == 'true') as T;
      }

      // Handle complex types
      try {
        final decoded = jsonDecode(stringValue);

        if (typeMarker == 'List<String>' ||
            T.toString().startsWith('List<String>')) {
          return (decoded as List).cast<String>() as T;
        } else if (typeMarker == 'List<int>' ||
            T.toString().startsWith('List<int>')) {
          return (decoded as List).cast<int>() as T;
        } else if (typeMarker == 'List' || T.toString().startsWith('List')) {
          return decoded as T;
        } else if (typeMarker == 'Map' || T.toString().contains('Map')) {
          return decoded as T;
        } else if (typeMarker == 'Object') {
          return decoded as T;
        }

        return decoded as T;
      } catch (e) {
        throw SerializationException(
          'Cannot deserialize value to type $T',
          key: key,
          originalError: e,
        );
      }
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        'Failed to retrieve secure value',
        key: key,
        originalError: e,
      );
    }
  }

  /// Delete a value by key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      await _storage.delete(key: '${key}_type');
      await _storage.delete(key: '${key}_expiry');
    } catch (e) {
      throw StorageException(
        'Failed to delete secure value',
        key: key,
        originalError: e,
      );
    }
  }

  /// Clear all stored values
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException(
        'Failed to clear secure storage',
        originalError: e,
      );
    }
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      // Check if expired
      if (await _isExpired(key)) {
        return false;
      }

      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      throw StorageException(
        'Failed to check key existence',
        key: key,
        originalError: e,
      );
    }
  }

  /// Get all keys (excluding internal type markers and expiry keys)
  Future<List<String>> getKeys() async {
    try {
      final allData = await _storage.readAll();
      return allData.keys
          .where((key) => !key.endsWith('_type') && !key.endsWith('_expiry'))
          .toList();
    } catch (e) {
      throw StorageException('Failed to retrieve keys', originalError: e);
    }
  }

  /// Get all key-value pairs as a map
  Future<Map<String, dynamic>> getAll() async {
    try {
      final keys = await getKeys();
      final result = <String, dynamic>{};

      for (final key in keys) {
        // Check if expired
        if (await _isExpired(key)) {
          continue;
        }

        final stringValue = await _storage.read(key: key);
        if (stringValue == null) continue;

        final typeMarker = await _storage.read(key: '${key}_type');

        // Parse based on type marker
        dynamic value;

        if (typeMarker == 'String') {
          value = stringValue;
        } else if (typeMarker == 'int') {
          value = int.tryParse(stringValue);
        } else if (typeMarker == 'double') {
          value = double.tryParse(stringValue);
        } else if (typeMarker == 'bool') {
          value = stringValue.toLowerCase() == 'true';
        } else if (typeMarker == 'List<String>' ||
            typeMarker == 'List<int>' ||
            typeMarker == 'List' ||
            typeMarker == 'Map' ||
            typeMarker == 'Object') {
          try {
            value = jsonDecode(stringValue);
          } on Exception catch (_) {
            value = stringValue;
          }
        } else {
          // No type marker, try to parse as JSON, fallback to string
          try {
            value = jsonDecode(stringValue);
          } on Exception catch (_) {
            value = stringValue;
          }
        }

        result[key] = value;
      }

      return result;
    } catch (e) {
      throw StorageException(
        'Failed to retrieve all secure values',
        originalError: e,
      );
    }
  }
}
