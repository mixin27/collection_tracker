import 'package:domain/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_model.freezed.dart';
part 'collection_model.g.dart';

@freezed
abstract class CollectionModel with _$CollectionModel {
  const CollectionModel._();

  const factory CollectionModel({
    required String id,
    required String name,
    required String type,
    String? description,
    String? coverImagePath,
    @Default(0) int itemCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CollectionModel;

  factory CollectionModel.fromJson(Map<String, dynamic> json) =>
      _$CollectionModelFromJson(json);

  factory CollectionModel.fromEntity(Collection entity) {
    return CollectionModel(
      id: entity.id,
      name: entity.name,
      type: entity.type.name,
      description: entity.description,
      coverImagePath: entity.coverImagePath,
      itemCount: entity.itemCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Collection toEntity() {
    return Collection(
      id: id,
      name: name,
      type: CollectionType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => CollectionType.custom,
      ),
      description: description,
      coverImagePath: coverImagePath,
      itemCount: itemCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
