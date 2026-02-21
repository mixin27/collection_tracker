// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Collection Tracker';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navWishlist => 'Wishlist';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionImport => 'Import';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSwitchToGrid => 'Switch to grid';

  @override
  String get actionSwitchToList => 'Switch to list';

  @override
  String get actionUpdate => 'Update';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsSectionDeveloper => 'Developer';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsExportJsonTitle => 'Export to JSON';

  @override
  String get settingsExportJsonSubtitle => 'Export all data as JSON file';

  @override
  String get settingsExportCsvTitle => 'Export to CSV';

  @override
  String get settingsExportCsvSubtitle => 'Export items as CSV spreadsheet';

  @override
  String get settingsImportJsonTitle => 'Import from JSON';

  @override
  String get settingsImportJsonSubtitle => 'Import data from JSON file';

  @override
  String get settingsCloudSyncTitle => 'Cloud Sync';

  @override
  String get settingsCloudSyncSubtitle => 'Not configured';

  @override
  String get settingsManageTagsTitle => 'Manage Tags';

  @override
  String get settingsManageTagsSubtitle => 'Rename, merge, and delete tags';

  @override
  String get settingsVersionTitle => 'Version';

  @override
  String get settingsPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get settingsTermsTitle => 'Terms of Service';

  @override
  String get settingsCrashlyticsTestTitle => 'Test Crashlytics';

  @override
  String get settingsCrashlyticsTestSubtitle => 'Intentionally crash the app to verify crash reporting';

  @override
  String get settingsCrashlyticsTestConfirmTitle => 'Trigger test crash?';

  @override
  String get settingsCrashlyticsTestConfirmMessage => 'The app will crash immediately. Re-open the app to verify the crash in Firebase Crashlytics.';

  @override
  String get settingsCrashlyticsTestConfirmAction => 'Crash Now';

  @override
  String get settingsCrashlyticsTestTriggered => 'Triggering test crash...';

  @override
  String settingsCrashlyticsTestFailed(String error) {
    return 'Failed to trigger crash test: $error';
  }

  @override
  String get settingsExportingData => 'Exporting data...';

  @override
  String get settingsDataExportSuccess => 'Data exported successfully!';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get settingsImportDataTitle => 'Import Data';

  @override
  String get settingsImportDataMessage => 'This will import collections and items from a JSON file. Existing data will not be deleted.\\n\\nContinue?';

  @override
  String get settingsImportingData => 'Importing data...';

  @override
  String get settingsDataImportSuccess => 'Data imported successfully!';

  @override
  String settingsImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get settingsThemeModeTitle => 'Theme Mode';

  @override
  String get settingsThemeColorVariantTitle => 'Color Variant';

  @override
  String get settingsAmoledTitle => 'Amoled Mode (Pure Black)';

  @override
  String get settingsAmoledSubtitle => 'Reduces battery consumption on OLED screens';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageBurmese => 'မြန်မာ';

  @override
  String get collectionsTitle => 'My Collections';

  @override
  String get collectionsCountLabel => 'Collections';

  @override
  String get collectionsNewButton => 'New Collection';

  @override
  String get collectionsActionsTooltip => 'Collection actions';

  @override
  String get collectionsOpenAction => 'Open Collection';

  @override
  String get collectionsEditAction => 'Edit Collection';

  @override
  String get collectionsDeleteTitle => 'Delete Collection';

  @override
  String collectionsDeleteMessage(String name, int itemCount) {
    return 'Delete \"$name\" and $itemCount items in this collection?';
  }

  @override
  String collectionsDeleted(String name) {
    return '$name deleted';
  }

  @override
  String collectionsErrorLoading(String error) {
    return 'Error loading collections: $error';
  }

  @override
  String get itemsTitle => 'Items';

  @override
  String get itemsCountLabel => 'Items';

  @override
  String itemsCountWithValue(int count) {
    return '$count items';
  }

  @override
  String get itemsSearchHint => 'Search items...';

  @override
  String get itemsNoMatchesTitle => 'No matches found';

  @override
  String get itemsNoMatchesMessage => 'Try changing filters or keywords.';

  @override
  String get itemsNoItemsTitle => 'No items yet';

  @override
  String get itemsNoItemsMessage => 'Start by adding your first item.';

  @override
  String get itemsAddButton => 'Add Item';

  @override
  String get itemsLoadingMessage => 'Loading items...';

  @override
  String itemsErrorLoading(String error) {
    return 'Error loading items: $error';
  }

  @override
  String get itemsDeleteTitle => 'Delete Item';

  @override
  String itemsDeleteMessage(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String itemsDeleted(String name) {
    return '$name deleted';
  }

  @override
  String itemsOverviewCount(int count) {
    return '$count items';
  }

  @override
  String itemsSortedBy(String sortLabel) {
    return 'Sorted by $sortLabel';
  }

  @override
  String get itemsCollectionDetailsTooltip => 'Collection details';

  @override
  String get itemsFiltersTooltip => 'Filters';

  @override
  String get itemsFilterTitle => 'Filter Items';

  @override
  String get itemsSortByTitle => 'Sort by';

  @override
  String get itemsFilterFavoritesOnly => 'Favorites only';

  @override
  String get itemsFilterWishlistOnly => 'Wishlist only';

  @override
  String get itemsFilterConditionsTitle => 'Condition';

  @override
  String get itemsTagsTitle => 'Tags';

  @override
  String itemsQuantityLabel(int quantity) {
    return 'Qty: $quantity';
  }

  @override
  String itemsQuantityShort(int quantity) {
    return 'x$quantity';
  }

  @override
  String get itemSortCustom => 'Custom order';

  @override
  String get itemSortTitle => 'Title';

  @override
  String get itemSortCreatedAt => 'Date added';

  @override
  String get itemSortPurchaseDate => 'Purchase date';

  @override
  String get itemSortCurrentValue => 'Current value';

  @override
  String get itemSortQuantity => 'Quantity';

  @override
  String get itemConditionMint => 'Mint';

  @override
  String get itemConditionGood => 'Good';

  @override
  String get itemConditionFair => 'Fair';

  @override
  String get itemConditionPoor => 'Poor';

  @override
  String get itemDetailNotFoundTitle => 'Item not found';

  @override
  String get itemDetailNotFoundMessage => 'This item no longer exists.';

  @override
  String get itemDetailFavorited => 'Favorited';

  @override
  String get itemDetailFavorite => 'Favorite';

  @override
  String get itemDetailInWishlist => 'In Wishlist';

  @override
  String get itemDetailPriceTrackingTitle => 'Price tracking';

  @override
  String get itemDetailNoValueMessage => 'No current value available';

  @override
  String get itemDetailNoHistoryMessage => 'No price history yet';

  @override
  String get itemDetailPriceHistoryError => 'Unable to load price history';

  @override
  String get itemDetailDetailsTitle => 'Details';

  @override
  String get itemDetailBarcodeLabel => 'Barcode';

  @override
  String get itemDetailConditionLabel => 'Condition';

  @override
  String get itemDetailQuantityLabel => 'Quantity';

  @override
  String get itemDetailLocationLabel => 'Location';

  @override
  String get itemDetailPurchasePriceLabel => 'Purchase price';

  @override
  String get itemDetailCurrentValueLabel => 'Current value';

  @override
  String get itemDetailPurchaseDateLabel => 'Purchase date';

  @override
  String get itemDetailNotesTitle => 'Notes';

  @override
  String get itemDetailLoadingMessage => 'Loading item details...';

  @override
  String itemDetailErrorLoading(String error) {
    return 'Error loading item details: $error';
  }

  @override
  String get itemDetailUpdateValueTitle => 'Update current value';

  @override
  String get itemDetailCurrentValueUpdated => 'Current value updated';

  @override
  String itemDetailUpdateValueFailed(String error) {
    return 'Failed to update value: $error';
  }

  @override
  String get addItemTitle => 'Add Item';

  @override
  String get addItemSubmit => 'Add Item';

  @override
  String get addItemTitleHint => 'e.g., The Lord of the Rings';

  @override
  String get addItemFetchingMetadata => 'Fetching metadata...';

  @override
  String addItemMatchedMetadata(String source) {
    return 'Matched $source metadata';
  }

  @override
  String get addItemTagsHint => 'e.g., Rare, Completed Set';

  @override
  String get addItemSuccess => 'Item added successfully';

  @override
  String addItemError(String error) {
    return 'Error adding item: $error';
  }

  @override
  String get editItemTitle => 'Edit Item';

  @override
  String get editItemLoading => 'Loading item...';

  @override
  String editItemError(String error) {
    return 'Error: $error';
  }

  @override
  String get editItemSaveChanges => 'Save Changes';

  @override
  String get editItemTagsHint => 'e.g., Signed, First Edition';

  @override
  String get editItemSuccess => 'Item updated successfully';

  @override
  String editItemUpdateError(String error) {
    return 'Error updating item: $error';
  }

  @override
  String get itemFormTitleLabel => 'Title';

  @override
  String get itemFormTitleRequired => 'Please enter a title';

  @override
  String get itemFormBarcodeLabelOptional => 'Barcode (optional)';

  @override
  String get itemFormBarcodeHint => 'ISBN, UPC, etc.';

  @override
  String get itemFormDescriptionLabelOptional => 'Description (optional)';

  @override
  String get itemFormDescriptionHint => 'Add a description';

  @override
  String get itemFormTagsLabelOptional => 'Tags (optional)';

  @override
  String get itemFormPurchaseDateLabelOptional => 'Purchase Date (optional)';

  @override
  String get itemFormConditionLabelOptional => 'Condition (optional)';

  @override
  String get itemFormQuantityRequired => 'Please enter quantity';

  @override
  String get itemFormQuantityInvalid => 'Please enter a valid quantity';

  @override
  String get itemFormLocationLabelOptional => 'Location (optional)';

  @override
  String get itemFormLocationHint => 'e.g., Shelf A, Box 3';

  @override
  String get itemFormNotesLabelOptional => 'Notes (optional)';

  @override
  String get itemFormInvalidPrice => 'Invalid price';

  @override
  String get itemFormMustBePositive => 'Must be positive';

  @override
  String get itemTagsEditorHint => 'Add a tag';

  @override
  String get itemTagsEditorAddTooltip => 'Add tag';

  @override
  String get itemTagsEditorEmptyMessage => 'No tags yet. Add tags to organize items faster.';

  @override
  String get itemTagsEditorTooLong => 'Tags must be 50 characters or less';

  @override
  String get globalItemsLoading => 'Loading items...';

  @override
  String globalItemsErrorLoading(String error) {
    return 'Error: $error';
  }

  @override
  String get globalItemsNoFavoritesTitle => 'No favorite items yet';

  @override
  String get globalItemsNoFavoritesMessage => 'Mark items as favorite to see them here.';

  @override
  String get globalItemsNoWishlistTitle => 'Your wishlist is empty';

  @override
  String get globalItemsNoWishlistMessage => 'Save items to wishlist and access them here.';

  @override
  String metadataSearchFieldLabel(String collectionType) {
    return 'Search $collectionType by title';
  }

  @override
  String get metadataSearchEmptyTitle => 'Search metadata';

  @override
  String get metadataSearchEmptyMessage => 'Enter a title to search.';

  @override
  String get metadataSearchLoading => 'Searching metadata...';

  @override
  String metadataSearchError(String error) {
    return 'Error: $error';
  }

  @override
  String get metadataSearchNoResultsTitle => 'No results';

  @override
  String get metadataSearchNoResultsMessage => 'No metadata found for this title.';

  @override
  String get metadataSearchSuggestionTitle => 'Search by title';

  @override
  String get metadataSearchSuggestionMessage => 'Start typing to look up metadata.';

  @override
  String tagItemsTitle(String tag) {
    return 'Tag: $tag';
  }

  @override
  String get tagItemsSortTooltip => 'Sort';

  @override
  String get tagItemsSortNewest => 'Sort: Newest';

  @override
  String get tagItemsSortOldest => 'Sort: Oldest';

  @override
  String get tagItemsSortTitle => 'Sort: Title';

  @override
  String get tagItemsLoadingCollections => 'Loading collections...';

  @override
  String get tagItemsLoadingItems => 'Loading tagged items...';

  @override
  String tagItemsError(String error) {
    return 'Error: $error';
  }

  @override
  String get tagItemsEmptyTitle => 'No items found';

  @override
  String get tagItemsEmptyMessage => 'No collection items currently use this tag.';

  @override
  String get tagItemsUnknownCollection => 'Unknown';

  @override
  String get tagItemsOpenCollectionTooltip => 'Open collection';

  @override
  String tagItemsDeleteFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get tagManagementTitle => 'Manage Tags';

  @override
  String tagManagementSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get tagManagementCancelSelectionTooltip => 'Cancel selection';

  @override
  String get tagManagementSelectTagsTooltip => 'Select tags';

  @override
  String get tagManagementSearchHint => 'Search tags...';

  @override
  String get tagManagementEmptyTitle => 'No tags created yet';

  @override
  String tagManagementNoMatch(String query) {
    return 'No tags match \"$query\"';
  }

  @override
  String get tagManagementSelectVisible => 'Select visible';

  @override
  String get tagManagementSelectAllMatches => 'Select all matches';

  @override
  String get tagManagementClearSelection => 'Clear selection';

  @override
  String tagManagementScrollMore(int remaining) {
    return 'Scroll to load $remaining more tags';
  }

  @override
  String get tagManagementUsedInOne => 'Used in 1 item';

  @override
  String tagManagementUsedInMany(int count) {
    return 'Used in $count items';
  }

  @override
  String get tagManagementRenameAction => 'Rename';

  @override
  String get tagManagementMergeAction => 'Merge';

  @override
  String get tagManagementMergeIntoAction => 'Merge Into...';

  @override
  String tagManagementLoadError(String error) {
    return 'Failed to load tags: $error';
  }

  @override
  String get tagManagementRenameTitle => 'Rename Tag';

  @override
  String get tagManagementNewNameLabel => 'New name';

  @override
  String tagManagementRenameSuccess(String oldName, String newName) {
    return '\"$oldName\" renamed to \"$newName\"';
  }

  @override
  String get tagManagementMergeSelectedTitle => 'Merge Selected Tags';

  @override
  String get tagManagementChooseDestination => 'Choose destination tag:';

  @override
  String tagManagementMergeSelectedSuccess(int count, String destination) {
    return 'Merged $count tags into \"$destination\"';
  }

  @override
  String get tagManagementDeleteSelectedTitle => 'Delete Selected Tags';

  @override
  String tagManagementDeleteSelectedMessage(int count) {
    return 'Delete $count selected tags from all items?\\n\\nThis cannot be undone.';
  }

  @override
  String tagManagementDeleteSelectedSuccess(int count) {
    return 'Deleted $count tags';
  }

  @override
  String get tagManagementMergeIntoTitle => 'Merge Into';

  @override
  String tagManagementMergeSuccess(String source, String target) {
    return '\"$source\" merged into \"$target\"';
  }

  @override
  String get tagManagementDeleteTitle => 'Delete Tag';

  @override
  String tagManagementDeleteMessage(String tagName) {
    return 'Delete \"$tagName\" from all items?\\n\\nThis cannot be undone.';
  }

  @override
  String tagManagementDeleteSuccess(String tagName) {
    return '\"$tagName\" deleted';
  }

  @override
  String tagManagementMutationError(String error) {
    return 'Tag update failed: $error';
  }

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsEmptyTitle => 'No statistics yet';

  @override
  String get statisticsEmptyMessage => 'Add collections and items to see insights.';

  @override
  String get statisticsLoadingMessage => 'Loading statistics...';

  @override
  String statisticsErrorLoading(String error) {
    return 'Error loading statistics: $error';
  }

  @override
  String get statisticsPortfolioValueTitle => 'Portfolio value';

  @override
  String statisticsAveragePricedItem(String value) {
    return 'Avg priced item: $value';
  }

  @override
  String statisticsPricedItemsBadge(int priced, int total) {
    return 'Priced items: $priced/$total';
  }

  @override
  String get statisticsQuantityTitle => 'Total quantity';

  @override
  String get statisticsFavoritesTitle => 'Favorites';

  @override
  String statisticsPercentOfItems(String percent) {
    return '$percent% of items';
  }

  @override
  String get statisticsInventoryHealthTitle => 'Inventory health';

  @override
  String get statisticsValuationCoverageLabel => 'Valuation coverage';

  @override
  String statisticsPricedCaption(int priced, int total) {
    return '$priced of $total items have prices';
  }

  @override
  String get statisticsFavoritesCoverageLabel => 'Favorites coverage';

  @override
  String statisticsFavoritesCaption(int favorites, int total) {
    return '$favorites of $total items are favorites';
  }

  @override
  String get statisticsWishlistCoverageLabel => 'Wishlist coverage';

  @override
  String statisticsWishlistCaption(int wishlist, int total) {
    return '$wishlist of $total items are on wishlist';
  }

  @override
  String get statisticsItemsByTypeTitle => 'Items by type';

  @override
  String get statisticsItemsByConditionTitle => 'Items by condition';

  @override
  String get statisticsTopValuedTitle => 'Top valued collections';

  @override
  String get statisticsLargestCollectionTitle => 'Largest collection';

  @override
  String get statisticsRecentlyCreatedTitle => 'Recently created';

  @override
  String statisticsRecentCollectionSubtitle(int itemCount, String createdAt) {
    return '$itemCount items • $createdAt';
  }

  @override
  String get statisticsNoChartData => 'No chart data available';

  @override
  String get statisticsTotalLabel => 'Total';

  @override
  String get relativeToday => 'Today';

  @override
  String get relativeYesterday => 'Yesterday';

  @override
  String relativeDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String relativeWeeksAgo(int weeks) {
    return '$weeks weeks ago';
  }

  @override
  String relativeMonthsAgo(int months) {
    return '$months months ago';
  }

  @override
  String relativeYearsAgo(int years) {
    return '$years years ago';
  }

  @override
  String get collectionDetailsNotFoundTitle => 'Collection not found';

  @override
  String get collectionDetailsNotFoundMessage => 'The selected collection is not available.';

  @override
  String get collectionDetailsCreatedLabel => 'Created';

  @override
  String get collectionDetailsUpdatedLabel => 'Last Updated';

  @override
  String get collectionDetailsLoading => 'Loading collection...';

  @override
  String get collectionTypeBooks => 'Books';

  @override
  String get collectionTypeGames => 'Games';

  @override
  String get collectionTypeMovies => 'Movies';

  @override
  String get collectionTypeComics => 'Comics';

  @override
  String get collectionTypeMusic => 'Music';

  @override
  String get collectionTypeCustom => 'Custom';
}
