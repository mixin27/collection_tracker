/// Custom exception for storage operations
class StorageException implements Exception {
  StorageException(this.message, {this.key, this.originalError});

  final String message;
  final String? key;
  final dynamic originalError;

  @override
  String toString() {
    final buffer = StringBuffer('StorageException: $message');
    if (key != null) {
      buffer.write(' (key: $key)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// Exception for type mismatch errors
class TypeMismatchException extends StorageException {
  TypeMismatchException(this.expectedType, this.actualType, {String? key})
    : super(
        'Type mismatch: expected $expectedType but got $actualType',
        key: key,
      );

  final Type expectedType;
  final Type actualType;
}

/// Exception for serialization errors
class SerializationException extends StorageException {
  SerializationException(super.message, {super.key, super.originalError});
}
