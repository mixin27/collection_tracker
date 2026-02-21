import 'package:domain/domain.dart';
import 'package:collection_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';

IconData collectionTypeIcon(CollectionType type) {
  return switch (type) {
    CollectionType.book => Icons.library_books_rounded,
    CollectionType.game => Icons.sports_esports_rounded,
    CollectionType.movie => Icons.movie_creation_rounded,
    CollectionType.comic => Icons.menu_book_rounded,
    CollectionType.music => Icons.album_rounded,
    CollectionType.custom => Icons.category_rounded,
  };
}

String collectionTypeLabel(BuildContext context, CollectionType type) {
  final l10n = context.l10n;
  return switch (type) {
    CollectionType.book => l10n.collectionTypeBooks,
    CollectionType.game => l10n.collectionTypeGames,
    CollectionType.movie => l10n.collectionTypeMovies,
    CollectionType.comic => l10n.collectionTypeComics,
    CollectionType.music => l10n.collectionTypeMusic,
    CollectionType.custom => l10n.collectionTypeCustom,
  };
}

Color collectionTypeColor(BuildContext context, CollectionType type) {
  final scheme = Theme.of(context).colorScheme;
  return switch (type) {
    CollectionType.book => const Color(0xFF2D6CDF),
    CollectionType.game => const Color(0xFF17A673),
    CollectionType.movie => const Color(0xFFD96B12),
    CollectionType.comic => const Color(0xFF7F56D9),
    CollectionType.music => const Color(0xFF0097A7),
    CollectionType.custom => scheme.primary,
  };
}
