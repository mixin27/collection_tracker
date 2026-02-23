import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_api/metadata_api.dart';
import 'package:domain/domain.dart';
import 'package:collection_tracker/core/providers/metadata_providers.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ui/ui.dart';

class MetadataSearchDelegate extends SearchDelegate<MetadataBase?> {
  final WidgetRef ref;
  final CollectionType collectionType;
  final String searchFieldLabelText;

  MetadataSearchDelegate({
    required this.ref,
    required this.collectionType,
    required this.searchFieldLabelText,
  }) : super(searchFieldLabel: searchFieldLabelText);

  String _lastSearchQuery = '';
  int _lastSearchLimit = 0;
  Future<List<MetadataBase>>? _lastSearchFuture;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final l10n = context.l10n;
    if (query.isEmpty) {
      return EmptyState(
        icon: Icons.search,
        title: l10n.metadataSearchEmptyTitle,
        message: l10n.metadataSearchEmptyMessage,
      );
    }

    return FutureBuilder(
      future: _performSearch(query: query, limit: 12),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingView(message: l10n.metadataSearchLoading);
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: l10n.metadataSearchError('${snapshot.error}'),
          );
        }

        final results = snapshot.data;

        if (results == null || results.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: l10n.metadataSearchNoResultsTitle,
            message: l10n.metadataSearchNoResultsMessage,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return AppReveal(
              delay: AppMotion.stagger * index,
              child: AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: item.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: item.thumbnailUrl!,
                          width: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Icon(Icons.image),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : const Icon(Icons.image),
                  title: Text(item.title),
                  subtitle: item.description != null
                      ? Text(
                          item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onTap: () => close(context, item),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().length < 2) {
      return EmptyState(
        icon: Icons.search,
        title: context.l10n.metadataSearchSuggestionTitle,
        message: context.l10n.metadataSearchSuggestionMessage,
      );
    }

    return FutureBuilder<List<MetadataBase>>(
      future: _performSearch(query: query, limit: 6),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingView(message: context.l10n.metadataSearchLoading);
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: context.l10n.metadataSearchError('${snapshot.error}'),
          );
        }

        final results = snapshot.data ?? const <MetadataBase>[];
        if (results.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: context.l10n.metadataSearchNoResultsTitle,
            message: context.l10n.metadataSearchNoResultsMessage,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return ListTile(
              leading: item.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.thumbnailUrl!,
                      width: 42,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Icon(Icons.image),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : const Icon(Icons.image),
              title: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                query = item.title;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }

  Future<List<MetadataBase>> _performSearch({
    required String query,
    int limit = 10,
  }) {
    final normalized = query.trim();
    if (_lastSearchFuture != null &&
        _lastSearchQuery == normalized &&
        _lastSearchLimit == limit) {
      return _lastSearchFuture!;
    }

    _lastSearchQuery = normalized;
    _lastSearchLimit = limit;
    _lastSearchFuture = _search(normalized, limit);
    return _lastSearchFuture!;
  }

  Future<List<MetadataBase>> _search(String query, int limit) async {
    if (query.isEmpty) {
      return const [];
    }

    final service = ref.read(metadataLookupServiceProvider);
    return service.search(
      query: query,
      collectionType: collectionType,
      limit: limit,
    );
  }
}
