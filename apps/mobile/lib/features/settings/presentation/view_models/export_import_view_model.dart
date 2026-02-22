import 'package:app_firebase/app_firebase.dart';
import 'package:collection_tracker/core/providers/providers.dart';
import 'package:database/database.dart';
import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storage/storage.dart';

part 'export_import_view_model.g.dart';

@riverpod
class ExportImportViewModel extends _$ExportImportViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed.
  }

  Future<String> exportAllDataToJson() async {
    state = const AsyncValue.loading();
    final performanceService = FirebasePerformanceService.instance;

    final result = await AsyncValue.guard(
      () => performanceService.traceAsync(
        'settings_export_all_data_json',
        () async {
          final collectionRepo = ref.read(collectionRepositoryProvider);
          final itemRepo = ref.read(itemRepositoryProvider);
          final exportService = ExportImportService();

          final collectionsResult = await collectionRepo.getCollections();
          final collections = collectionsResult.fold(
            (exception) => throw exception,
            (data) => data,
          );

          final allItems = <Item>[];
          for (final collection in collections) {
            final itemsResult = await itemRepo.getItems(
              collectionId: collection.id,
            );
            itemsResult.fold(
              (exception) => null,
              (items) => allItems.addAll(items),
            );
          }

          final exportData = {
            'version': '1.0.0',
            'exportDate': DateTime.now().toIso8601String(),
            'collections': collections
                .map(
                  (c) => {
                    'id': c.id,
                    'name': c.name,
                    'type': c.type.name,
                    'description': c.description,
                    'itemCount': c.itemCount,
                    'createdAt': c.createdAt.toIso8601String(),
                    'updatedAt': c.updatedAt.toIso8601String(),
                  },
                )
                .toList(),
            'items': allItems
                .map(
                  (i) => {
                    'id': i.id,
                    'collectionId': i.collectionId,
                    'title': i.title,
                    'barcode': i.barcode,
                    'description': i.description,
                    'condition': i.condition?.name,
                    'quantity': i.quantity,
                    'location': i.location,
                    'notes': i.notes,
                    'isFavorite': i.isFavorite,
                    'purchasePrice': i.purchasePrice,
                    'purchaseDate': i.purchaseDate?.toIso8601String(),
                    'createdAt': i.createdAt.toIso8601String(),
                    'updatedAt': i.updatedAt.toIso8601String(),
                  },
                )
                .toList(),
          };

          return exportService.exportToJson(exportData);
        },
      ),
    );

    _setStateSafely(result);

    if (result.hasError) {
      throw result.error!;
    }

    return result.value!;
  }

  Future<String> exportItemsToCsv() async {
    state = const AsyncValue.loading();
    final performanceService = FirebasePerformanceService.instance;

    final result = await AsyncValue.guard(
      () =>
          performanceService.traceAsync('settings_export_items_csv', () async {
            final collectionRepo = ref.read(collectionRepositoryProvider);
            final itemRepo = ref.read(itemRepositoryProvider);
            final exportService = ExportImportService();

            final collectionsResult = await collectionRepo.getCollections();
            final collections = collectionsResult.fold(
              (exception) => throw exception,
              (data) => data,
            );

            final allItems = <Map<String, dynamic>>[];
            for (final collection in collections) {
              final itemsResult = await itemRepo.getItems(
                collectionId: collection.id,
              );
              itemsResult.fold((exception) => null, (items) {
                for (final item in items) {
                  allItems.add({
                    'Collection': collection.name,
                    'Title': item.title,
                    'Barcode': item.barcode ?? '',
                    'Description': item.description ?? '',
                    'Condition': item.condition?.name ?? '',
                    'Quantity': item.quantity.toString(),
                    'Location': item.location ?? '',
                    'Notes': item.notes ?? '',
                    'Favorite': item.isFavorite ? 'Yes' : 'No',
                    'Purchase Price': item.purchasePrice?.toString() ?? '',
                    'Created': item.createdAt.toString(),
                  });
                }
              });
            }

            return exportService.exportToCsv(allItems);
          }),
    );

    _setStateSafely(result);

    if (result.hasError) {
      throw result.error!;
    }

    return result.value!;
  }

  Future<void> importFromJson() async {
    state = const AsyncValue.loading();
    final performanceService = FirebasePerformanceService.instance;

    final result = await AsyncValue.guard(
      () => performanceService.traceAsync(
        'settings_import_data_json',
        () async {
          final collectionDao = ref.read(collectionDaoProvider);
          final itemDao = ref.read(itemDaoProvider);
          final exportService = ExportImportService();

          final data = await exportService.importFromJson();

          final collections = data['collections'] as List<dynamic>;
          for (final collectionData in collections) {
            final companion = CollectionsCompanion(
              id: Value(collectionData['id'] as String),
              name: Value(collectionData['name'] as String),
              type: Value(collectionData['type'] as String),
              description: Value(collectionData['description'] as String?),
              itemCount: Value(collectionData['itemCount'] as int),
              createdAt: Value(
                DateTime.parse(collectionData['createdAt'] as String),
              ),
              updatedAt: Value(
                DateTime.parse(collectionData['updatedAt'] as String),
              ),
            );
            await collectionDao.insertCollection(companion);
          }

          final items = data['items'] as List<dynamic>;
          for (final itemData in items) {
            final companion = ItemsCompanion(
              id: Value(itemData['id'] as String),
              collectionId: Value(itemData['collectionId'] as String),
              title: Value(itemData['title'] as String),
              barcode: Value(itemData['barcode'] as String?),
              description: Value(itemData['description'] as String?),
              condition: Value(itemData['condition'] as String?),
              quantity: Value(itemData['quantity'] as int),
              location: Value(itemData['location'] as String?),
              notes: Value(itemData['notes'] as String?),
              isFavorite: Value(itemData['isFavorite'] as bool),
              purchasePrice: Value(
                itemData['purchasePrice'] != null
                    ? (itemData['purchasePrice'] as num).toDouble()
                    : null,
              ),
              purchaseDate: Value(
                itemData['purchaseDate'] != null
                    ? DateTime.parse(itemData['purchaseDate'] as String)
                    : null,
              ),
              createdAt: Value(DateTime.parse(itemData['createdAt'] as String)),
              updatedAt: Value(DateTime.parse(itemData['updatedAt'] as String)),
            );
            await itemDao.insertItem(companion);
          }
        },
      ),
    );

    _setStateSafely(result);
  }

  void _setStateSafely(AsyncValue<void> value) {
    try {
      state = value;
    } catch (_) {
      // Ignore if provider was auto-disposed while async work was running.
    }
  }
}
