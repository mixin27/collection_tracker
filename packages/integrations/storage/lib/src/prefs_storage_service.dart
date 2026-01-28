import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/src/exceptions/storage_exception.dart';

/// Service for local storage operations using shared_preferences
class PrefsStorageService {
  PrefsStorageService._();

  static PrefsStorageService? _instance;
  SharedPreferences? _prefs;

  /// Get singleton instance
  static PrefsStorageService get instance {
    _instance ??= PrefsStorageService._();
    return _instance!;
  }

  /// Initialize the storage service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  /// Save a value with optional TTL (time-to-live in seconds)
  Future<void> save<T>(String key, T value, {int? ttl}) async {
    try {
      final prefs = await _preferences;

      if (ttl != null) {
        final expiryKey = '${key}_expiry';
        final expiryTime = DateTime.now().add(Duration(seconds: ttl));
        await prefs.setString(expiryKey, expiryTime.toIso8601String());
      }

      if (value == null) {
        await prefs.remove(key);
        return;
      }

      switch (T) {
        case const (String):
          await prefs.setString(key, value as String);
        case const (int):
          await prefs.setInt(key, value as int);
        case const (double):
          await prefs.setDouble(key, value as double);
        case const (bool):
          await prefs.setBool(key, value as bool);
        default:
          // Handle List<String>, List<int>, Map, and custom objects
          if (value is List<String>) {
            await prefs.setStringList(key, value);
          } else if (value is List<int>) {
            await prefs.setStringList(
              key,
              value.map((e) => e.toString()).toList(),
            );
            await prefs.setString('${key}_type', 'List<int>');
          } else if (value is List) {
            // Generic list - serialize as JSON
            final jsonString = jsonEncode(value);
            await prefs.setString(key, jsonString);
            await prefs.setString('${key}_type', 'List');
          } else if (value is Map) {
            final jsonString = jsonEncode(value);
            await prefs.setString(key, jsonString);
            await prefs.setString('${key}_type', 'Map');
          } else {
            // Try to serialize as JSON for custom objects
            try {
              final jsonString = jsonEncode(value);
              await prefs.setString(key, jsonString);
              await prefs.setString('${key}_type', 'Object');
            } catch (e) {
              throw SerializationException(
                'Cannot serialize value of type ${value.runtimeType}',
                key: key,
                originalError: e,
              );
            }
          }
      }
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        'Failed to save value',
        key: key,
        originalError: e,
      );
    }
  }

  /// Check if a key has expired (for TTL support)
  Future<bool> _isExpired(String key) async {
    final prefs = await _preferences;
    final expiryKey = '${key}_expiry';
    final expiryString = prefs.getString(expiryKey);

    if (expiryString == null) return false;

    final expiryTime = DateTime.parse(expiryString);
    final isExpired = DateTime.now().isAfter(expiryTime);

    if (isExpired) {
      await delete(key);
      await prefs.remove(expiryKey);
    }

    return isExpired;
  }

  /// Retrieve a value by key
  Future<T?> get<T>(String key) async {
    try {
      final prefs = await _preferences;

      // Check if expired
      if (await _isExpired(key)) {
        return null;
      }

      return _readFromPrefs<T>(prefs, key);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
        'Failed to retrieve value',
        key: key,
        originalError: e,
      );
    }
  }

  /// Retrieve a value synchronously (only works if init() was called and completed)
  T? readSync<T>(String key) {
    if (_prefs == null) {
      throw StorageException(
        'PrefsStorageService is not initialized. Call init() first.',
        key: key,
      );
    }

    return _readFromPrefs<T>(_prefs!, key);
  }

  T? _readFromPrefs<T>(SharedPreferences prefs, String key) {
    final typeMarker = prefs.getString('${key}_type');

    switch (T) {
      case const (String):
        return prefs.getString(key) as T?;
      case const (int):
        return prefs.getInt(key) as T?;
      case const (double):
        return prefs.getDouble(key) as T?;
      case const (bool):
        return prefs.getBool(key) as T?;
      default:
        // Handle complex types
        if (T.toString().startsWith('List<String>')) {
          return prefs.getStringList(key) as T?;
        } else if (T.toString().startsWith('List<int>') ||
            typeMarker == 'List<int>') {
          final stringList = prefs.getStringList(key);
          if (stringList == null) return null;
          return stringList.map(int.parse).toList() as T?;
        } else if (typeMarker == 'List') {
          final jsonString = prefs.getString(key);
          if (jsonString == null) return null;
          return jsonDecode(jsonString) as T?;
        } else if (typeMarker == 'Map' || T.toString().contains('Map')) {
          final jsonString = prefs.getString(key);
          if (jsonString == null) return null;
          return jsonDecode(jsonString) as T?;
        } else if (typeMarker == 'Object') {
          final jsonString = prefs.getString(key);
          if (jsonString == null) return null;
          return jsonDecode(jsonString) as T?;
        }

        // Try to get as string and decode
        final jsonString = prefs.getString(key);
        if (jsonString == null) return null;

        try {
          return jsonDecode(jsonString) as T?;
        } catch (e) {
          throw SerializationException(
            'Cannot deserialize value to type $T',
            key: key,
            originalError: e,
          );
        }
    }
  }

  /// Delete a value by key
  Future<void> delete(String key) async {
    try {
      final prefs = await _preferences;
      await prefs.remove(key);
      await prefs.remove('${key}_type');
      await prefs.remove('${key}_expiry');
    } catch (e) {
      throw StorageException(
        'Failed to delete value',
        key: key,
        originalError: e,
      );
    }
  }

  /// Clear all stored values
  Future<void> clear() async {
    try {
      final prefs = await _preferences;
      await prefs.clear();
    } catch (e) {
      throw StorageException('Failed to clear storage', originalError: e);
    }
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _preferences;

      // Check if expired
      if (await _isExpired(key)) {
        return false;
      }

      return prefs.containsKey(key);
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
      final prefs = await _preferences;
      final allKeys = prefs.getKeys();

      // Filter out type markers and expiry keys
      return allKeys
          .where((key) => !key.endsWith('_type') && !key.endsWith('_expiry'))
          .toList();
    } catch (e) {
      throw StorageException('Failed to retrieve keys', originalError: e);
    }
  }

  /// Get all key-value pairs as a map
  Future<Map<String, dynamic>> getAll() async {
    try {
      final prefs = await _preferences;
      final keys = await getKeys();
      final result = <String, dynamic>{};

      for (final key in keys) {
        // Check if expired
        if (await _isExpired(key)) {
          continue;
        }

        final typeMarker = prefs.getString('${key}_type');

        // Get the raw value based on type
        dynamic value;

        if (typeMarker == null) {
          // Try to get as primitive types
          if (prefs.get(key) is String) {
            value = prefs.getString(key);
          } else if (prefs.get(key) is int) {
            value = prefs.getInt(key);
          } else if (prefs.get(key) is double) {
            value = prefs.getDouble(key);
          } else if (prefs.get(key) is bool) {
            value = prefs.getBool(key);
          } else if (prefs.get(key) is List) {
            value = prefs.getStringList(key);
          } else {
            value = prefs.get(key);
          }
        } else {
          // Handle complex types
          if (typeMarker == 'List<int>') {
            final stringList = prefs.getStringList(key);
            value = stringList?.map(int.parse).toList();
          } else if (typeMarker == 'List' ||
              typeMarker == 'Map' ||
              typeMarker == 'Object') {
            final jsonString = prefs.getString(key);
            if (jsonString != null) {
              value = jsonDecode(jsonString);
            }
          } else {
            value = prefs.get(key);
          }
        }

        result[key] = value;
      }

      return result;
    } catch (e) {
      throw StorageException('Failed to retrieve all values', originalError: e);
    }
  }
}
