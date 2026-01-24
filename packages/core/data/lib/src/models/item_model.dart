import 'package:domain/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

@freezed
abstract class ItemModel with _$ItemModel {
  const ItemModel._();

  const factory ItemModel({
    required String id,
    required String collectionId,
    required String title,
    String? barcode,
    String? coverImageUrl,
    String? coverImagePath,
    String? description,
    String? notes,
    Map<String, dynamic>? metadata,
    String? condition,
    double? purchasePrice,
    DateTime? purchaseDate,
    double? currentValue,
    String? location,
    @Default(false) bool isFavorite,
    @Default(1) int quantity,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ItemModel;

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  factory ItemModel.fromEntity(Item entity) {
    return ItemModel(
      id: entity.id,
      collectionId: entity.collectionId,
      title: entity.title,
      barcode: entity.barcode,
      coverImageUrl: entity.coverImageUrl,
      coverImagePath: entity.coverImagePath,
      description: entity.description,
      notes: entity.notes,
      metadata: entity.metadata,
      condition: entity.condition?.name,
      purchasePrice: entity.purchasePrice,
      purchaseDate: entity.purchaseDate,
      currentValue: entity.currentValue,
      location: entity.location,
      isFavorite: entity.isFavorite,
      quantity: entity.quantity,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Item toEntity() {
    return Item(
      id: id,
      collectionId: collectionId,
      title: title,
      barcode: barcode,
      coverImageUrl: coverImageUrl,
      coverImagePath: coverImagePath,
      description: description,
      notes: notes,
      metadata: metadata,
      condition: condition != null
          ? ItemCondition.values.firstWhere(
              (e) => e.name == condition,
              orElse: () => ItemCondition.good,
            )
          : null,
      purchasePrice: purchasePrice,
      purchaseDate: purchaseDate,
      currentValue: currentValue,
      location: location,
      isFavorite: isFavorite,
      quantity: quantity,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
