# Collection Tracker App - Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Core Features](#core-features)
5. [Pagination Strategy](#pagination-strategy)
6. [State Management](#state-management)
7. [Error Handling](#error-handling)
8. [Database Schema](#database-schema)
9. [API Integration](#api-integration)
10. [Development Guidelines](#development-guidelines)

---

## 1. Project Overview

### Description
A universal collection tracking app built with Flutter that allows users to catalog and manage various types of collections (books, video games, movies, comics, etc.) with barcode scanning, metadata fetching, and cloud synchronization.

### Tech Stack
- **Framework:** Flutter 3.x
- **State Management:** Riverpod + riverpod_generator
- **Architecture:** Clean Architecture + MVVM
- **Local Database:** Drift
- **Workspace Management:** Dart Pub Workspace
- **Code Generation:** build_runner, freezed, json_serializable
- **Functional Programming:** fpdart (Either type)

### Key Requirements
- ✅ High performance (60fps animations, fast startup)
- ✅ Excellent UI/UX with smooth animations
- ✅ Offline-first architecture
- ✅ Pagination for large datasets
- ✅ Modular package structure
- ✅ Comprehensive error handling
- ✅ Clean code with best practices

---

## 2. Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, ViewModels, Widgets, State)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          Domain Layer                    │
│  (Entities, Use Cases, Repositories)     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Data Layer                     │
│  (Models, Repository Impl, DataSources)  │
└──────────────────────────────────────────┘
```

### MVVM Pattern per Screen

```
Screen (View)
    ↕
ViewModel (Business Logic + State)
    ↕
Use Cases (Domain Logic)
    ↕
Repository (Data Access)
    ↕
Data Sources (Local/Remote)
```

---

## 3. Project Structure

```
collection_tracker/
├── pubspec.yaml                        # Workspace root configuration
│
├── apps/
│   └── mobile/
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app.dart
│       │   ├── core/
│       │   │   ├── router/
│       │   │   │   ├── app_router.dart
│       │   │   │   └── routes.dart
│       │   │   └── di/
│       │   │       └── injection.dart
│       │   │
│       │   └── features/
│       │       ├── onboarding/
│       │       │   ├── presentation/
│       │       │   │   ├── screens/
│       │       │   │   ├── view_models/
│       │       │   │   └── widgets/
│       │       │   └── domain/
│       │       │
│       │       ├── collections/
│       │       │   ├── data/
│       │       │   │   ├── models/
│       │       │   │   ├── repositories/
│       │       │   │   └── datasources/
│       │       │   ├── domain/
│       │       │   │   ├── entities/
│       │       │   │   ├── repositories/
│       │       │   │   └── usecases/
│       │       │   └── presentation/
│       │       │       ├── screens/
│       │       │       ├── view_models/
│       │       │       └── widgets/
│       │       │
│       │       ├── items/
│       │       │   ├── data/
│       │       │   ├── domain/
│       │       │   └── presentation/
│       │       │
│       │       ├── search/
│       │       ├── scanner/
│       │       ├── statistics/
│       │       └── settings/
│       │
│       └── pubspec.yaml
│
├── packages/
│   ├── core/
│   │   ├── domain/
│   │   │   ├── lib/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── collection.dart
│   │   │   │   │   ├── item.dart
│   │   │   │   │   └── user_preferences.dart
│   │   │   │   │
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── collection_repository.dart
│   │   │   │   │   └── item_repository.dart
│   │   │   │   │
│   │   │   │   ├── usecases/
│   │   │   │   │   └── base_usecase.dart
│   │   │   │   │
│   │   │   │   └── failures/
│   │   │   │       └── app_exception.dart
│   │   │   │
│   │   │   └── pubspec.yaml
│   │   │
│   │   └── data/
│   │       ├── lib/
│   │       │   ├── models/
│   │       │   │   ├── collection_model.dart
│   │       │   │   └── item_model.dart
│   │       │   │
│   │       │   ├── repositories/
│   │       │   │   ├── collection_repository_impl.dart
│   │       │   │   └── item_repository_impl.dart
│   │       │   │
│   │       │   ├── datasources/
│   │       │   │   ├── local/
│   │       │   │   │   ├── collection_local_datasource.dart
│   │       │   │   │   └── item_local_datasource.dart
│   │       │   │   └── remote/
│   │       │   │       ├── metadata_remote_datasource.dart
│   │       │   │       └── sync_remote_datasource.dart
│   │       │   │
│   │       │   └── mappers/
│   │       │       ├── collection_mapper.dart
│   │       │       └── item_mapper.dart
│   │       │
│   │       └── pubspec.yaml
│   │
│   ├── common/
│   │   ├── ui/
│   │   │   ├── lib/
│   │   │   │   ├── theme/
│   │   │   │   │   ├── app_theme.dart
│   │   │   │   │   ├── colors.dart
│   │   │   │   │   └── typography.dart
│   │   │   │   │
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── buttons/
│   │   │   │   │   ├── cards/
│   │   │   │   │   ├── loading/
│   │   │   │   │   ├── empty_state.dart
│   │   │   │   │   └── error_view.dart
│   │   │   │   │
│   │   │   │   ├── animations/
│   │   │   │   │   ├── fade_in.dart
│   │   │   │   │   └── slide_transition.dart
│   │   │   │   │
│   │   │   │   └── styles/
│   │   │   │       └── spacing.dart
│   │   │   │
│   │   │   └── pubspec.yaml
│   │   │
│   │   └── utils/
│   │       ├── lib/
│   │       │   ├── extensions/
│   │       │   │   ├── string_extensions.dart
│   │       │   │   ├── context_extensions.dart
│   │       │   │   └── datetime_extensions.dart
│   │       │   │
│   │       │   ├── helpers/
│   │       │   │   ├── debouncer.dart
│   │       │   │   └── image_helper.dart
│   │       │   │
│   │       │   ├── constants/
│   │       │   │   └── app_constants.dart
│   │       │   │
│   │       │   └── validators/
│   │       │       └── input_validators.dart
│   │       │
│   │       └── pubspec.yaml
│   │
│   └── integrations/
│       ├── database/
│       │   ├── lib/
│       │   │   ├── database.dart
│       │   │   ├── database.g.dart
│       │   │   ├── tables/
│       │   │   │   ├── collections_table.dart
│       │   │   │   ├── items_table.dart
│       │   │   │   └── tags_table.dart
│       │   │   │
│       │   │   ├── daos/
│       │   │   │   ├── collection_dao.dart
│       │   │   │   └── item_dao.dart
│       │   │   │
│       │   │   └── migrations/
│       │   │       └── migration_v1_to_v2.dart
│       │   │
│       │   └── pubspec.yaml
│       │
│       ├── barcode_scanner/
│       │   ├── lib/
│       │   │   ├── barcode_scanner.dart
│       │   │   └── models/
│       │   │       └── scan_result.dart
│       │   └── pubspec.yaml
│       │
│       ├── metadata_api/
│       │   ├── lib/
│       │   │   ├── clients/
│       │   │   │   ├── google_books_client.dart
│       │   │   │   ├── igdb_client.dart
│       │   │   │   └── tmdb_client.dart
│       │   │   │
│       │   │   ├── models/
│       │   │   │   ├── book_metadata.dart
│       │   │   │   ├── game_metadata.dart
│       │   │   │   └── movie_metadata.dart
│       │   │   │
│       │   │   └── pagination/
│       │   │       ├── paginated_response.dart
│       │   │       └── page_info.dart
│       │   │
│       │   └── pubspec.yaml
│       │
│       ├── analytics/
│       │   ├── lib/
│       │   │   ├── analytics_service.dart
│       │   │   └── events/
│       │   └── pubspec.yaml
│       │
│       ├── logging/
│       │   ├── lib/
│       │   │   └── logger.dart
│       │   └── pubspec.yaml
│       │
│       ├── storage/
│       │   ├── lib/
│       │   │   ├── file_storage_service.dart
│       │   │   └── image_storage_service.dart
│       │   └── pubspec.yaml
│       │
│       └── payment/
│           ├── lib/
│           │   └── payment_service.dart
│           └── pubspec.yaml
```

---

## 4. Core Features

### Feature List

#### MVP (Version 1.0)
1. **Onboarding**
   - Welcome screens
   - Permission requests (camera, storage)
   - Quick tutorial

2. **Collection Management**
   - Create collections (Books, Games, Movies)
   - View all collections
   - Edit/delete collections
   - Collection statistics

3. **Item Management**
   - Add items via barcode scan
   - Add items manually
   - Auto-fetch metadata from APIs
   - View item details
   - Edit/delete items
   - Upload photos
   - Add notes and custom fields

4. **Search & Filter**
   - Search within collections
   - Filter by type, condition, tags
   - Sort options

5. **Barcode Scanner**
   - Quick scan to add
   - Support ISBN, UPC codes

6. **Settings**
   - Dark/light mode
   - Export data (CSV)
   - About page

#### Future Features (v1.1+)
- Cloud sync
- Sharing collections
- Price tracking
- Loan tracking
- Advanced statistics
- Premium subscription
- Multiple photos per item
- Duplicate detection

---

## 5. Pagination Strategy

### Overview
Pagination is critical for:
- **Network data sources** (API calls to Google Books, IGDB, TMDB)
- **Local database** (when collections have 1000+ items)

### Implementation Approach

#### 5.1 Pagination Models

```dart
// packages/integrations/metadata_api/lib/pagination/page_info.dart
@freezed
class PageInfo with _$PageInfo {
  const factory PageInfo({
    required int currentPage,
    required int pageSize,
    required int totalItems,
    required int totalPages,
    required bool hasNextPage,
    required bool hasPreviousPage,
  }) = _PageInfo;

  factory PageInfo.fromJson(Map<String, dynamic> json) =>
      _$PageInfoFromJson(json);
}

// packages/integrations/metadata_api/lib/pagination/paginated_response.dart
@freezed
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> items,
    required PageInfo pageInfo,
  }) = _PaginatedResponse<T>;
}
```

#### 5.2 Pagination State

```dart
// Pagination state for ViewModels
@freezed
class PaginatedState<T> with _$PaginatedState<T> {
  const factory PaginatedState.initial() = _Initial;

  const factory PaginatedState.loading({
    @Default([]) List<T> currentItems,
    @Default(false) bool isLoadingMore,
  }) = _Loading;

  const factory PaginatedState.loaded({
    required List<T> items,
    required PageInfo pageInfo,
    @Default(false) bool isLoadingMore,
  }) = _Loaded;

  const factory PaginatedState.error({
    required AppException exception,
    @Default([]) List<T> currentItems,
  }) = _Error;
}
```

#### 5.3 Paginated Repository Pattern

```dart
// packages/core/domain/lib/repositories/item_repository.dart
abstract class ItemRepository {
  // Local pagination (offset-based)
  Future<Either<AppException, PaginatedResponse<Item>>> getItems({
    required String collectionId,
    required int page,
    required int pageSize,
  });

  // Network search with pagination (cursor or page-based)
  Future<Either<AppException, PaginatedResponse<Item>>> searchItems({
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  });
}
```

#### 5.4 Local Database Pagination (Drift)

```dart
// packages/integrations/database/lib/daos/item_dao.dart
@DriftAccessor(tables: [Items])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(AppDatabase db) : super(db);

  // Offset-based pagination for local data
  Future<PaginatedResponse<ItemData>> getItemsPaginated({
    required String collectionId,
    required int page,
    required int pageSize,
  }) async {
    final offset = (page - 1) * pageSize;

    // Get total count
    final totalQuery = select(items)
      ..where((tbl) => tbl.collectionId.equals(collectionId));
    final totalCount = await totalQuery.get().then((rows) => rows.length);

    // Get paginated items
    final query = select(items)
      ..where((tbl) => tbl.collectionId.equals(collectionId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(pageSize, offset: offset);

    final itemsList = await query.get();

    final pageInfo = PageInfo(
      currentPage: page,
      pageSize: pageSize,
      totalItems: totalCount,
      totalPages: (totalCount / pageSize).ceil(),
      hasNextPage: offset + pageSize < totalCount,
      hasPreviousPage: page > 1,
    );

    return PaginatedResponse(
      items: itemsList,
      pageInfo: pageInfo,
    );
  }
}
```

#### 5.5 Network Pagination (API Clients)

```dart
// packages/integrations/metadata_api/lib/clients/google_books_client.dart
class GoogleBooksClient {
  final Dio _dio;

  GoogleBooksClient(this._dio);

  // Page-based pagination (Google Books uses startIndex)
  Future<PaginatedResponse<BookMetadata>> searchBooks({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final startIndex = (page - 1) * pageSize;

      final response = await _dio.get(
        '/volumes',
        queryParameters: {
          'q': query,
          'startIndex': startIndex,
          'maxResults': pageSize,
        },
      );

      final totalItems = response.data['totalItems'] as int;
      final items = (response.data['items'] as List?)
          ?.map((json) => BookMetadata.fromJson(json))
          .toList() ?? [];

      final pageInfo = PageInfo(
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalItems,
        totalPages: (totalItems / pageSize).ceil(),
        hasNextPage: startIndex + pageSize < totalItems,
        hasPreviousPage: page > 1,
      );

      return PaginatedResponse(items: items, pageInfo: pageInfo);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
}

// packages/integrations/metadata_api/lib/clients/igdb_client.dart
class IGDBClient {
  final Dio _dio;

  IGDBClient(this._dio);

  // Cursor-based pagination (if API supports it)
  Future<PaginatedResponse<GameMetadata>> searchGames({
    required String query,
    String? cursor,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.post(
        '/games',
        data: {
          'search': query,
          'limit': pageSize,
          if (cursor != null) 'cursor': cursor,
        },
      );

      final items = (response.data['items'] as List)
          .map((json) => GameMetadata.fromJson(json))
          .toList();

      final nextCursor = response.data['next_cursor'] as String?;

      // For cursor-based, we estimate page info
      final pageInfo = PageInfo(
        currentPage: cursor == null ? 1 : -1, // Unknown for cursor
        pageSize: pageSize,
        totalItems: -1, // Unknown for cursor-based
        totalPages: -1,
        hasNextPage: nextCursor != null,
        hasPreviousPage: cursor != null,
      );

      return PaginatedResponse(items: items, pageInfo: pageInfo);
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }
}
```

#### 5.6 Paginated ViewModel

```dart
// features/items/presentation/view_models/items_view_model.dart
@riverpod
class ItemsViewModel extends _$ItemsViewModel {
  @override
  PaginatedState<Item> build(String collectionId) {
    _loadFirstPage();
    return const PaginatedState.initial();
  }

  Future<void> _loadFirstPage() async {
    state = const PaginatedState.loading();

    final repository = ref.read(itemRepositoryProvider);
    final result = await repository.getItems(
      collectionId: collectionId,
      page: 1,
      pageSize: 20,
    );

    result.fold(
      (exception) => state = PaginatedState.error(exception: exception),
      (response) => state = PaginatedState.loaded(
        items: response.items,
        pageInfo: response.pageInfo,
      ),
    );
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! _Loaded<Item>) return;
    if (!currentState.pageInfo.hasNextPage) return;
    if (currentState.isLoadingMore) return;

    // Set loading more flag
    state = currentState.copyWith(isLoadingMore: true);

    final repository = ref.read(itemRepositoryProvider);
    final result = await repository.getItems(
      collectionId: collectionId,
      page: currentState.pageInfo.currentPage + 1,
      pageSize: currentState.pageInfo.pageSize,
    );

    result.fold(
      (exception) => state = PaginatedState.error(
        exception: exception,
        currentItems: currentState.items,
      ),
      (response) => state = PaginatedState.loaded(
        items: [...currentState.items, ...response.items],
        pageInfo: response.pageInfo,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> refresh() async {
    await _loadFirstPage();
  }
}
```

#### 5.7 Paginated UI (Infinite Scroll)

```dart
// features/items/presentation/screens/items_screen.dart
class ItemsScreen extends ConsumerWidget {
  final String collectionId;

  const ItemsScreen({required this.collectionId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(itemsViewModelProvider(collectionId));
    final viewModel = ref.read(itemsViewModelProvider(collectionId).notifier);

    return Scaffold(
      body: state.when(
        initial: () => const LoadingView(),
        loading: (currentItems, isLoadingMore) {
          if (currentItems.isEmpty) {
            return const LoadingView();
          }
          return _buildList(currentItems, isLoadingMore, viewModel);
        },
        loaded: (items, pageInfo, isLoadingMore) {
          if (items.isEmpty) {
            return const EmptyStateView();
          }
          return _buildList(items, isLoadingMore, viewModel);
        },
        error: (exception, currentItems) {
          if (currentItems.isEmpty) {
            return ErrorView(
              exception: exception,
              onRetry: viewModel.refresh,
            );
          }
          return _buildList(currentItems, false, viewModel);
        },
      ),
    );
  }

  Widget _buildList(
    List<Item> items,
    bool isLoadingMore,
    ItemsViewModel viewModel,
  ) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        itemCount: items.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Load more when reaching end
          if (index == items.length - 3) {
            viewModel.loadNextPage();
          }

          if (index == items.length) {
            return const LoadingMoreIndicator();
          }

          return ItemCard(item: items[index]);
        },
      ),
    );
  }
}
```

### Pagination Best Practices

1. **Choose the right strategy:**
   - **Offset-based**: For local database, small datasets
   - **Page-based**: For APIs that support page numbers
   - **Cursor-based**: For large datasets, real-time data

2. **Performance optimizations:**
   - Cache paginated results
   - Prefetch next page when user reaches 80% of current page
   - Use `ListView.builder` for efficient rendering
   - Implement pull-to-refresh

3. **Error handling:**
   - Keep current items on error
   - Show retry option
   - Handle network timeouts gracefully

4. **User experience:**
   - Show skeleton loaders for first page
   - Show subtle loading indicator for next pages
   - Implement pull-to-refresh
   - Handle empty states

---

## 6. State Management

### Riverpod Patterns

#### 6.1 Provider Types

```dart
// Simple value provider
@riverpod
AppTheme appTheme(AppThemeRef ref) {
  return AppTheme.light();
}

// Async provider
@riverpod
Future<UserPreferences> userPreferences(UserPreferencesRef ref) async {
  final repository = ref.watch(preferencesRepositoryProvider);
  return repository.getPreferences();
}

// Stream provider
@riverpod
Stream<List<Collection>> collectionsStream(CollectionsStreamRef ref) {
  final dao = ref.watch(collectionDaoProvider);
  return dao.watchAllCollections();
}

// Stateful provider (ViewModel)
@riverpod
class CollectionsViewModel extends _$CollectionsViewModel {
  @override
  Future<CollectionsState> build() async {
    return _loadCollections();
  }

  // Methods...
}
```

#### 6.2 ViewModel Pattern

```dart
// Base state for features
@freezed
class FeatureState<T> with _$FeatureState<T> {
  const factory FeatureState.initial() = _Initial;
  const factory FeatureState.loading() = _Loading;
  const factory FeatureState.loaded(T data) = _Loaded;
  const factory FeatureState.error(AppException exception) = _Error;
}

// ViewModel with loading, success, error states
@riverpod
class ItemDetailViewModel extends _$ItemDetailViewModel {
  @override
  Future<FeatureState<Item>> build(String itemId) async {
    return _loadItem();
  }

  Future<FeatureState<Item>> _loadItem() async {
    try {
      final useCase = ref.read(getItemUseCaseProvider);
      final item = await useCase.execute(itemId);
      return FeatureState.loaded(item);
    } on AppException catch (e) {
      return FeatureState.error(e);
    }
  }

  Future<void> updateItem(Item updatedItem) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(updateItemUseCaseProvider);
      await useCase.execute(updatedItem);
      return FeatureState.loaded(updatedItem);
    });
  }

  Future<void> deleteItem() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(deleteItemUseCaseProvider);
      await useCase.execute(itemId);
      return const FeatureState.initial();
    });
  }
}
```

---

## 7. Error Handling

### Exception Hierarchy

```dart
// packages/core/domain/lib/failures/app_exception.dart
@freezed
class AppException with _$AppException implements Exception {
  // Network errors
  const factory AppException.network({
    required String message,
    @Default('') String details,
    StackTrace? stackTrace,
  }) = NetworkException;

  const factory AppException.timeout({
    required String message,
  }) = TimeoutException;

  // Database errors
  const factory AppException.database({
    required String message,
    StackTrace? stackTrace,
  }) = DatabaseException;

  // Validation errors
  const factory AppException.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationException;

  // Not found errors
  const factory AppException.notFound({
    required String message,
    String? resourceType,
    String? resourceId,
  }) = NotFoundException;

  // Permission errors
  const factory AppException.permission({
    required String message,
    required String permissionType,
  }) = PermissionException;

  // Business logic errors
  const factory AppException.business({
    required String message,
    String? code,
  }) = BusinessException;

  // Unknown errors
  const factory AppException.unknown({
    required String message,
    StackTrace? stackTrace,
  }) = UnknownException;
}

// Extension for user-friendly messages
extension AppExceptionX on AppException {
  String get userMessage => when(
    network: (msg, _, __) => 'Network error: Please check your connection',
    timeout: (msg) => 'Request timed out. Please try again',
    database: (msg, _) => 'Database error occurred',
    validation: (msg, _) => msg,
    notFound: (msg, _, __) => msg,
    permission: (msg, _) => msg,
    business: (msg, _) => msg,
    unknown: (msg, _) => 'An unexpected error occurred',
  );
}
```

### Error Handling in Repository

```dart
class ItemRepositoryImpl implements ItemRepository {
  final ItemLocalDataSource _localDataSource;
  final MetadataRemoteDataSource _remoteDataSource;
  final Logger _logger;

  @override
  Future<Either<AppException, Item>> getItemById(String id) async {
    try {
      final model = await _localDataSource.getById(id);
      if (model == null) {
        return const Left(AppException.notFound(
          message: 'Item not found',
          resourceType: 'Item',
        ));
      }
      return Right(model.toEntity());
    } on DriftException catch (e, stack) {
      _logger.error('Database error getting item', e, stack);
      return Left(AppException.database(
        message: 'Failed to retrieve item',
        stackTrace: stack,
      ));
    } catch (e, stack) {
      _logger.error('Unknown error getting item', e, stack);
      return Left(AppException.unknown(
        message: e.toString(),
        stackTrace: stack,
      ));
    }
  }

  @override
  Future<Either<AppException, ItemMetadata>> fetchMetadata(
    String barcode,
  ) async {
    try {
      final metadata = await _remoteDataSource.fetchByBarcode(barcode);
      return Right(metadata);
    } on DioException catch (e, stack) {
      _logger.error('Network error fetching metadata', e, stack);

      if (e.type == DioExceptionType.connectionTimeout) {
        return const Left(AppException.timeout(
          message: 'Connection timeout',
        ));
      }

      return Left(AppException.network(
        message: 'Failed to fetch metadata',
        details: e.message ?? '',
        stackTrace: stack,
      ));
    } catch (e, stack) {
      _logger.error('Unknown error fetching metadata', e, stack);
      return Left(AppException.unknown(
        message: e.toString(),
        stackTrace: stack,
      ));
    }
  }
}
```

### Error Handling in UI

```dart
// Common error view widget
class ErrorView extends StatelessWidget {
  final AppException exception;
  final VoidCallback? onRetry;

  const ErrorView({
    required this.exception,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForException(),
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              exception.userMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForException() {
    return exception.when(
      network: (_, __, ___) => Icons.wifi_off,
      timeout: (_) => Icons.timer_off,
      database: (_, __) => Icons.storage,
      validation: (_, __) => Icons.error_outline,
      notFound: (_, __, ___) => Icons.search_off,
      permission: (_, __) => Icons.lock,
      business: (_, __) => Icons.warning,
      unknown: (_, __) => Icons.error,
    );
  }
}

// Usage in screen
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(itemDetailViewModelProvider(itemId));

  return state.when(
    data: (featureState) => featureState.when(
      initial: () => const SizedBox(),
      loading: () => const LoadingView(),
      loaded: (item) => ItemDetailContent(item: item),
      error: (exception) => ErrorView(
        exception: exception,
        onRetry: () => ref.invalidate(
          itemDetailViewModelProvider(itemId),
        ),
      ),
    ),
    loading: () => const LoadingView(),
    error: (error, stack) => ErrorView(
      exception: AppException.unknown(
        message: error.toString(),
        stackTrace: stack,
      ),
      onRetry: () => ref.invalidate(
        itemDetailViewModelProvider(itemId),
      ),
    ),
  );
}
```

---

## 8. Database Schema

### Drift Tables

```dart
// packages/integrations/database/lib/tables/collections_table.dart
@DataClassName('CollectionData')
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // 'book', 'game', 'movie', 'custom'
  TextColumn get description => text().nullable()();
  TextColumn get coverImagePath => text().nullable()();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// packages/integrations/database/lib/tables/items_table.dart
@DataClassName('ItemData')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId => text().references(Collections, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get barcode => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get coverImagePath => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();

  // Collection-specific fields stored as JSON
  TextColumn get metadata => text().nullable()(); // JSON string

  // Common fields
  TextColumn get condition => text().nullable()(); // 'mint', 'good', 'fair', 'poor'
  RealColumn get purchasePrice => real().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  RealColumn get currentValue => real().nullable()();
  TextColumn get location => text().nullable()(); // shelf, box, etc.
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get quantity => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, barcode}, // Unique barcode per collection
  ];
}

// packages/integrations/database/lib/tables/tags_table.dart
@DataClassName('TagData')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer()(); // Color value
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// packages/integrations/database/lib/tables/item_tags_table.dart
@DataClassName('ItemTagData')
class ItemTags extends Table {
  TextColumn get itemId => text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId => text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {itemId, tagId};
}
```

### Database Class

```dart
// packages/integrations/database/lib/database.dart
@DriftDatabase(
  tables: [Collections, Items, Tags, ItemTags],
  daos: [CollectionDao, ItemDao, TagDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations
        if (from < 2) {
          // Example migration for v2
          // await m.addColumn(items, items.newColumn);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');

        if (details.wasCreated) {
          // Seed initial data if needed
        }
      },
    );
  }
}

// Provider
@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase(
    NativeDatabase.createInBackground(
      File(path.join(
        // Get app documents directory
        documentsPath,
        'collection_tracker.db',
      )),
    ),
  );
}
```

### DAOs (Data Access Objects)

```dart
// packages/integrations/database/lib/daos/item_dao.dart
@DriftAccessor(tables: [Items, ItemTags, Tags])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(AppDatabase db) : super(db);

  // Get all items in a collection with pagination
  Future<PaginatedResponse<ItemData>> getItemsPaginated({
    required String collectionId,
    required int page,
    required int pageSize,
    String? searchQuery,
    String? condition,
    List<String>? tagIds,
  }) async {
    final offset = (page - 1) * pageSize;

    // Build base query
    var query = select(items)
      ..where((tbl) => tbl.collectionId.equals(collectionId));

    // Apply filters
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((tbl) => tbl.title.like('%$searchQuery%'));
    }

    if (condition != null) {
      query.where((tbl) => tbl.condition.equals(condition));
    }

    // Get total count
    final totalCount = await query.get().then((rows) => rows.length);

    // Apply pagination
    query
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
      ..limit(pageSize, offset: offset);

    final itemsList = await query.get();

    // Filter by tags if needed (requires join)
    List<ItemData> filteredItems = itemsList;
    if (tagIds != null && tagIds.isNotEmpty) {
      filteredItems = [];
      for (final item in itemsList) {
        final itemTagsList = await (select(itemTags)
              ..where((tbl) => tbl.itemId.equals(item.id)))
            .get();

        final hasAllTags = tagIds.every(
          (tagId) => itemTagsList.any((it) => it.tagId == tagId),
        );

        if (hasAllTags) {
          filteredItems.add(item);
        }
      }
    }

    final pageInfo = PageInfo(
      currentPage: page,
      pageSize: pageSize,
      totalItems: totalCount,
      totalPages: (totalCount / pageSize).ceil(),
      hasNextPage: offset + pageSize < totalCount,
      hasPreviousPage: page > 1,
    );

    return PaginatedResponse(
      items: filteredItems,
      pageInfo: pageInfo,
    );
  }

  // Watch items for real-time updates
  Stream<List<ItemData>> watchItems(String collectionId) {
    return (select(items)
          ..where((tbl) => tbl.collectionId.equals(collectionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  // Get single item
  Future<ItemData?> getById(String id) {
    return (select(items)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  // Insert item
  Future<void> insertItem(ItemsCompanion item) {
    return into(items).insert(item);
  }

  // Update item
  Future<void> updateItem(ItemsCompanion item) {
    return (update(items)..where((tbl) => tbl.id.equals(item.id.value)))
        .write(item);
  }

  // Delete item
  Future<void> deleteItem(String id) {
    return (delete(items)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get item with tags
  Future<ItemWithTags> getItemWithTags(String id) async {
    final item = await getById(id);
    if (item == null) throw NotFoundException(message: 'Item not found');

    final tagsList = await (select(itemTags)
          ..where((tbl) => tbl.itemId.equals(id)))
        .join([
          innerJoin(tags, tags.id.equalsExp(itemTags.tagId)),
        ])
        .map((row) => row.readTable(tags))
        .get();

    return ItemWithTags(item: item, tags: tagsList);
  }
}

// Helper class
class ItemWithTags {
  final ItemData item;
  final List<TagData> tags;

  ItemWithTags({required this.item, required this.tags});
}
```

---

## 9. API Integration

### Metadata API Clients

```dart
// packages/integrations/metadata_api/lib/clients/google_books_client.dart
class GoogleBooksClient {
  static const _baseUrl = 'https://www.googleapis.com/books/v1';
  final Dio _dio;

  GoogleBooksClient({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  Future<PaginatedResponse<BookMetadata>> searchBooks({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final startIndex = (page - 1) * pageSize;

      final response = await _dio.get(
        '/volumes',
        queryParameters: {
          'q': query,
          'startIndex': startIndex,
          'maxResults': pageSize,
          'printType': 'books',
        },
      );

      final totalItems = response.data['totalItems'] as int? ?? 0;
      final items = (response.data['items'] as List?)
          ?.map((json) => BookMetadata.fromJson(json))
          .toList() ?? [];

      return PaginatedResponse(
        items: items,
        pageInfo: PageInfo(
          currentPage: page,
          pageSize: pageSize,
          totalItems: totalItems,
          totalPages: totalItems > 0 ? (totalItems / pageSize).ceil() : 0,
          hasNextPage: startIndex + pageSize < totalItems,
          hasPreviousPage: page > 1,
        ),
      );
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to search books',
        details: e.message ?? '',
      );
    }
  }

  Future<BookMetadata?> getBookByISBN(String isbn) async {
    try {
      final response = await _dio.get(
        '/volumes',
        queryParameters: {
          'q': 'isbn:$isbn',
        },
      );

      final items = response.data['items'] as List?;
      if (items == null || items.isEmpty) return null;

      return BookMetadata.fromJson(items.first);
    } on DioException catch (e) {
      throw NetworkException(
        message: 'Failed to fetch book by ISBN',
        details: e.message ?? '',
      );
    }
  }
}

// Metadata model
@freezed
class BookMetadata with _$BookMetadata {
  const factory BookMetadata({
    required String id,
    required String title,
    List<String>? authors,
    String? publisher,
    String? publishedDate,
    String? description,
    List<String>? isbn,
    int? pageCount,
    List<String>? categories,
    String? thumbnailUrl,
    String? language,
  }) = _BookMetadata;

  factory BookMetadata.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>;

    return BookMetadata(
      id: json['id'] as String,
      title: volumeInfo['title'] as String,
      authors: (volumeInfo['authors'] as List?)?.cast<String>(),
      publisher: volumeInfo['publisher'] as String?,
      publishedDate: volumeInfo['publishedDate'] as String?,
      description: volumeInfo['description'] as String?,
      isbn: (volumeInfo['industryIdentifiers'] as List?)
          ?.map((e) => e['identifier'] as String)
          .toList(),
      pageCount: volumeInfo['pageCount'] as int?,
      categories: (volumeInfo['categories'] as List?)?.cast<String>(),
      thumbnailUrl: volumeInfo['imageLinks']?['thumbnail'] as String?,
      language: volumeInfo['language'] as String?,
    );
  }
}
```

### Provider Setup

```dart
// packages/integrations/metadata_api/lib/providers.dart
@riverpod
Dio apiDio(ApiDioRef ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Add interceptors
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
}

@riverpod
GoogleBooksClient googleBooksClient(GoogleBooksClientRef ref) {
  return GoogleBooksClient(dio: ref.watch(apiDioProvider));
}

@riverpod
IGDBClient igdbClient(IgdbClientRef ref) {
  return IGDBClient(dio: ref.watch(apiDioProvider));
}

@riverpod
TMDBClient tmdbClient(TmdbClientRef ref) {
  return TMDBClient(dio: ref.watch(apiDioProvider));
}
```

---

## 10. Development Guidelines

### Code Style

1. **Follow Effective Dart guidelines**
2. **Use meaningful names**: `getUserCollections` not `get`
3. **Keep functions small**: Single responsibility
4. **Use const constructors** where possible
5. **Prefer composition over inheritance**
6. **Use extensions** for utility methods

### Git Workflow

```bash
# Branch naming
feature/collection-management
fix/barcode-scanner-crash
refactor/item-repository
docs/api-integration

# Commit messages
feat: Add pagination to items list
fix: Resolve null check error in scanner
refactor: Extract metadata fetching logic
docs: Update README with setup instructions
```

### Testing Strategy

```dart
// Unit tests for use cases
test('GetItemsUseCase should return items on success', () async {
  // Arrange
  final mockRepo = MockItemRepository();
  final useCase = GetItemsUseCase(repository: mockRepo);
  final expectedItems = [/* test data */];

  when(() => mockRepo.getItems(any()))
      .thenAnswer((_) async => Right(expectedItems));

  // Act
  final result = await useCase.execute('collection-id');

  // Assert
  expect(result, equals(expectedItems));
});

// Widget tests
testWidgets('ItemCard shows item title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ItemCard(
        item: Item(id: '1', title: 'Test Book'),
      ),
    ),
  );

  expect(find.text('Test Book'), findsOneWidget);
});

// Integration tests for repository
test('ItemRepository should save and retrieve item', () async {
  final database = /* test database */;
  final repository = ItemRepositoryImpl(/* dependencies */);

  final item = Item(/* test data */);
  await repository.createItem(item);

  final result = await repository.getItemById(item.id);

  expect(result.isRight(), true);
  result.fold(
    (l) => fail('Should not fail'),
    (r) => expect(r, equals(item)),
  );
});
```

### Performance Checklist

- [ ] Use `const` constructors
- [ ] Implement `ListView.builder` for lists
- [ ] Cache network images
- [ ] Optimize database queries (indexes)
- [ ] Use code splitting for large apps
- [ ] Profile with DevTools
- [ ] Implement pagination
- [ ] Use isolates for heavy computations
- [ ] Minimize rebuilds with Riverpod selectors

### Security Best Practices

1. **Never store API keys in code**: Use environment variables
2. **Validate all user inputs**: Use validators
3. **Sanitize data before database insertion**
4. **Use HTTPS for all network requests**
5. **Implement proper permission handling**
6. **Encrypt sensitive local data** if needed

---

## Appendix

### Workspace Configuration

#### Root pubspec.yaml

```yaml
name: collection_tracker_workspace
description: A workspace for the Collection Tracker app
version: 1.0.0
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

# Workspace configuration
workspace:
  - apps/mobile
  - packages/core/domain
  - packages/core/data
  - packages/common/ui
  - packages/common/utils
  - packages/integrations/database
  - packages/integrations/barcode_scanner
  - packages/integrations/metadata_api
  - packages/integrations/analytics
  - packages/integrations/logging
  - packages/integrations/storage
  - packages/integrations/payment
```

#### Package pubspec.yaml Example

```yaml
# packages/core/domain/pubspec.yaml
name: core_domain
description: Domain layer - entities, repositories, use cases
version: 1.0.0
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  freezed_annotation: ^2.4.1
  fpdart: ^1.1.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.4.6
  test: ^1.24.0

# packages/core/data/pubspec.yaml
name: core_data
description: Data layer - models, repositories, data sources
version: 1.0.0
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  # Local packages
  core_domain:
    path: ../domain

  # External packages
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  fpdart: ^1.1.0
  dio: ^5.4.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  test: ^1.24.0
  mockito: ^5.4.0

# apps/mobile/pubspec.yaml
name: collection_tracker
description: Collection tracking mobile app
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Routing
  go_router: ^13.0.0

  # UI
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.0

  # Utilities
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  fpdart: ^1.1.0

  # Local workspace packages
  core_domain:
    path: ../../packages/core/domain
  core_data:
    path: ../../packages/core/data
  common_ui:
    path: ../../packages/common/ui
  common_utils:
    path: ../../packages/common/utils
  integration_database:
    path: ../../packages/integrations/database
  integration_barcode_scanner:
    path: ../../packages/integrations/barcode_scanner
  integration_metadata_api:
    path: ../../packages/integrations/metadata_api
  integration_analytics:
    path: ../../packages/integrations/analytics
  integration_logging:
    path: ../../packages/integrations/logging
  integration_storage:
    path: ../../packages/integrations/storage

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  riverpod_lint: ^2.3.0
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0
```

### Dart Pub Workspace Commands

```bash
# Get dependencies for all packages in workspace
dart pub get

# Run from root - automatically resolves workspace dependencies
cd collection_tracker
dart pub get

# Run tests for specific package
cd packages/core/domain
dart pub run test

# Run tests for all packages (you need to script this)
# Create a script: scripts/test_all.sh
#!/bin/bash
for dir in packages/*/; do
  echo "Testing $dir"
  cd "$dir"
  dart pub run test
  cd ../..
done

# Run build_runner for specific package
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch --delete-conflicting-outputs

# Run for all packages that need code generation
# Create script: scripts/build_all.sh
#!/bin/bash
echo "Building core/domain..."
cd packages/core/domain
dart run build_runner build --delete-conflicting-outputs

echo "Building core/data..."
cd ../data
dart run build_runner build --delete-conflicting-outputs

echo "Building integrations/metadata_api..."
cd ../../integrations/metadata_api
dart run build_runner build --delete-conflicting-outputs

echo "Building apps/mobile..."
cd ../../../apps/mobile
flutter pub run build_runner build --delete-conflicting-outputs

echo "Build completed!"

# Analyze code
cd apps/mobile
flutter analyze

# Format code
dart format .

# Run app
cd apps/mobile
flutter run
```

### Helper Scripts

Create a `scripts/` directory in your workspace root:

```bash
collection_tracker/
├── scripts/
│   ├── setup.sh
│   ├── build_all.sh
│   ├── test_all.sh
│   ├── analyze_all.sh
│   └── clean_all.sh
```

**scripts/setup.sh**
```bash
#!/bin/bash
echo "Setting up Collection Tracker workspace..."

# Get dependencies for all packages
echo "Getting dependencies..."
dart pub get

# Run build_runner for packages that need it
echo "Running code generation..."
./scripts/build_all.sh

echo "Setup complete!"
```

**scripts/clean_all.sh**
```bash
#!/bin/bash
echo "Cleaning all packages..."

# Clean Flutter app
cd apps/mobile
flutter clean
cd ../..

# Clean all packages
for dir in packages/core/*/; do
  echo "Cleaning $dir"
  cd "$dir"
  dart pub get --offline
  rm -rf .dart_tool
  cd ../../..
done

for dir in packages/common/*/; do
  echo "Cleaning $dir"
  cd "$dir"
  rm -rf .dart_tool
  cd ../../..
done

for dir in packages/integrations/*/; do
  echo "Cleaning $dir"
  cd "$dir"
  rm -rf .dart_tool
  cd ../../..
done

echo "Clean complete! Run 'dart pub get' to restore."
```

**scripts/analyze_all.sh**
```bash
#!/bin/bash
echo "Analyzing all packages..."

errors=0

# Analyze Flutter app
echo "Analyzing apps/mobile..."
cd apps/mobile
flutter analyze
if [ $? -ne 0 ]; then
  errors=$((errors+1))
fi
cd ../..

# Analyze all packages
for dir in packages/core/*/; do
  echo "Analyzing $dir"
  cd "$dir"
  dart analyze
  if [ $? -ne 0 ]; then
    errors=$((errors+1))
  fi
  cd ../../..
done

for dir in packages/common/*/; do
  echo "Analyzing $dir"
  cd "$dir"
  dart analyze
  if [ $? -ne 0 ]; then
    errors=$((errors+1))
  fi
  cd ../../..
done

for dir in packages/integrations/*/; do
  echo "Analyzing $dir"
  cd "$dir"
  dart analyze
  if [ $? -ne 0 ]; then
    errors=$((errors+1))
  fi
  cd ../../..
done

if [ $errors -eq 0 ]; then
  echo "✓ All packages analyzed successfully!"
else
  echo "✗ $errors package(s) have analysis errors"
  exit 1
fi
```

### VS Code Workspace Configuration

Create `.vscode/collection_tracker.code-workspace`:

```json
{
  "folders": [
    {
      "name": "Root",
      "path": "."
    },
    {
      "name": "Mobile App",
      "path": "apps/mobile"
    },
    {
      "name": "Core Domain",
      "path": "packages/core/domain"
    },
    {
      "name": "Core Data",
      "path": "packages/core/data"
    },
    {
      "name": "Common UI",
      "path": "packages/common/ui"
    },
    {
      "name": "Common Utils",
      "path": "packages/common/utils"
    },
    {
      "name": "Database Integration",
      "path": "packages/integrations/database"
    },
    {
      "name": "Metadata API",
      "path": "packages/integrations/metadata_api"
    }
  ],
  "settings": {
    "dart.lineLength": 80,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": true
    },
    "dart.analysisExcludedFolders": [
      "**/build/**",
      "**/.dart_tool/**"
    ]
  },
  "extensions": {
    "recommendations": [
      "dart-code.dart-code",
      "dart-code.flutter",
      "usernamehw.errorlens"
    ]
  }
}
```

### Makefile (Alternative to shell scripts)

Create a `Makefile` in the workspace root:

```makefile
.PHONY: setup clean build test analyze run help

help:
    @echo "Collection Tracker - Available commands:"
    @echo "  make setup    - Setup workspace and get dependencies"
    @echo "  make clean    - Clean all packages"
    @echo "  make build    - Run code generation for all packages"
    @echo "  make test     - Run tests for all packages"
    @echo "  make analyze  - Analyze all packages"
    @echo "  make run      - Run the mobile app"

setup:
    @echo "Setting up workspace..."
    dart pub get
    @$(MAKE) build

clean:
    @echo "Cleaning workspace..."
    cd apps/mobile && flutter clean
    find packages -name ".dart_tool" -type d -exec rm -rf {} +
    @echo "Clean complete!"

build:
    @echo "Running code generation..."
    cd packages/core/domain && dart run build_runner build --delete-conflicting-outputs
    cd packages/core/data && dart run build_runner build --delete-conflicting-outputs
    cd packages/integrations/metadata_api && dart run build_runner build --delete-conflicting-outputs
    cd apps/mobile && flutter pub run build_runner build --delete-conflicting-outputs
    @echo "Build complete!"

test:
    @echo "Running tests..."
    cd packages/core/domain && dart test
    cd packages/core/data && dart test
    cd apps/mobile && flutter test
    @echo "Tests complete!"

analyze:
    @echo "Analyzing code..."
    cd apps/mobile && flutter analyze
    cd packages/core/domain && dart analyze
    cd packages/core/data && dart analyze
    @echo "Analysis complete!"

run:
    cd apps/mobile && flutter run

watch:
    cd apps/mobile && flutter pub run build_runner watch --delete-conflicting-outputs
```

Usage:
```bash
make setup    # Initial setup
make build    # Generate code
make test     # Run all tests
make analyze  # Analyze all code
make run      # Run the app
make clean    # Clean everything
```

### Git Ignore

Create `.gitignore` in workspace root:

```gitignore
# Dart & Flutter
.dart_tool/
.packages
.pub-cache/
.pub/
build/
*.g.dart
*.freezed.dart

# IDE
.idea/
.vscode/
*.iml
*.ipr
*.iws

# OS
.DS_Store
Thumbs.db

# Test coverage
coverage/

# Generated files
*.lock
pubspec.lock

# Logs
*.log
```

### Build Runner Commands

```bash
# Generate code once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

### Useful Extensions

```dart
// packages/common/utils/lib/extensions/context_extensions.dart
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.error,
      ),
    );
  }
}

// packages/common/utils/lib/extensions/string_extensions.dart
extension StringX on String {
  bool get isValidISBN {
    final isbn = replaceAll(RegExp(r'[^0-9X]'), '');
    return isbn.length == 10 || isbn.length == 13;
  }

  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
```

---

## Next Steps

1. **Setup project structure** with Melos workspace
2. **Configure dependencies** in all packages
3. **Implement database schema** with Drift
4. **Create domain entities and repositories**
5. **Implement first feature** (Collections management)
6. **Add barcode scanner integration**
7. **Integrate metadata APIs**
8. **Build UI with animations**
9. **Add pagination** for items list
10. **Implement settings and preferences**
11. **Add cloud sync** (future feature)
12. **Testing and optimization**
13. **Release MVP**

---

**Document Version:** 1.0
**Last Updated:** January 2026
**Author:** Project Team
