import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_api/metadata_api.dart';
import 'package:domain/domain.dart';
import 'package:collection_tracker/core/providers/metadata_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ui/ui.dart';

class MetadataSearchDelegate extends SearchDelegate<MetadataBase?> {
  final WidgetRef ref;
  final CollectionType collectionType;

  MetadataSearchDelegate({required this.ref, required this.collectionType})
    : super(searchFieldLabel: 'Search ${collectionType.name} by title');

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
    if (query.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'Search metadata',
        message: 'Enter a title to search.',
      );
    }

    return FutureBuilder(
      future: _performSearch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView(message: 'Searching metadata...');
        }

        if (snapshot.hasError) {
          return ErrorView(message: 'Error: ${snapshot.error}');
        }

        final results = snapshot.data;

        if (results == null || results.isEmpty) {
          return const EmptyState(
            icon: Icons.search_off,
            title: 'No results',
            message: 'No metadata found for this title.',
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
    return const EmptyState(
      icon: Icons.search,
      title: 'Search by title',
      message: 'Start typing to look up metadata.',
    );
  }

  Future<List<MetadataBase>> _performSearch() async {
    final service = await ref.read(unifiedMetadataServiceProvider.future);
    final result = await service.search(
      query: query,
      collectionType: collectionType,
    );

    return result.fold((exception) => throw exception, (items) => items);
  }
}
