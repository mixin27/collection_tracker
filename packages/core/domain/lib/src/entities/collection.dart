import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection.freezed.dart';
part 'collection.g.dart';

enum CollectionType { book, game, movie, comic, music, custom }

@freezed
abstract class Collection with _$Collection {
  const factory Collection({
    required String id,
    required String name,
    required CollectionType type,
    String? description,
    String? coverImagePath,
    @Default(0) int itemCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Collection;

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);
}
