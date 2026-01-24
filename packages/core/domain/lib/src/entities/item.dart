import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

enum ItemCondition { mint, good, fair, poor }

@freezed
abstract class Item with _$Item {
  const factory Item({
    required String id,
    required String collectionId,
    required String title,
    String? barcode,
    String? coverImageUrl,
    String? coverImagePath,
    String? description,
    String? notes,
    Map<String, dynamic>? metadata,
    ItemCondition? condition,
    double? purchasePrice,
    DateTime? purchaseDate,
    double? currentValue,
    String? location,
    @Default(false) bool isFavorite,
    @Default(1) int quantity,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
