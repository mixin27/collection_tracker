// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'Collection Tracker';

  @override
  String get navHome => 'ပင်မ';

  @override
  String get navFavorites => 'အကြိုက်';

  @override
  String get navWishlist => 'ဆန္ဒ';

  @override
  String get navSettings => 'ဆက်တင်';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'မလုပ်တော့';

  @override
  String get actionDelete => 'ဖျက်မည်';

  @override
  String get actionDismiss => 'ပိတ်မည်';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionImport => 'ထည့်သွင်း';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSwitchToGrid => 'Grid သို့ ပြောင်းရန်';

  @override
  String get actionSwitchToList => 'List သို့ ပြောင်းရန်';

  @override
  String get actionUpdate => 'Update';

  @override
  String get settingsTitle => 'ဆက်တင်';

  @override
  String get settingsSectionGeneral => 'အထွေထွေ';

  @override
  String get settingsSectionData => 'ဒေတာ';

  @override
  String get settingsSectionAbout => 'အကြောင်းအရာ';

  @override
  String get settingsThemeTitle => 'အပြင်အဆင်';

  @override
  String get settingsLanguageTitle => 'ဘာသာစကား';

  @override
  String get settingsExportJsonTitle => 'JSON သို့ Export';

  @override
  String get settingsExportJsonSubtitle => 'ဒေတာအားလုံးကို JSON ဖိုင်အဖြစ် ထုတ်ယူမည်';

  @override
  String get settingsExportCsvTitle => 'CSV သို့ Export';

  @override
  String get settingsExportCsvSubtitle => 'ပစ္စည်းများကို CSV စာရင်းဇယားအဖြစ် ထုတ်ယူမည်';

  @override
  String get settingsImportJsonTitle => 'JSON မှ Import';

  @override
  String get settingsImportJsonSubtitle => 'JSON ဖိုင်မှ ဒေတာ ထည့်သွင်းမည်';

  @override
  String get settingsCloudSyncTitle => 'Cloud Sync';

  @override
  String get settingsCloudSyncSubtitle => 'မသတ်မှတ်ရသေး';

  @override
  String get settingsManageTagsTitle => 'Tag များ စီမံရန်';

  @override
  String get settingsManageTagsSubtitle => 'Tag အမည်ပြောင်း၊ ပေါင်းစည်း၊ ဖျက်နိုင်သည်';

  @override
  String get settingsVersionTitle => 'ဗားရှင်း';

  @override
  String get settingsPrivacyPolicyTitle => 'ကိုယ်ရေးကိုယ်တာ မူဝါဒ';

  @override
  String get settingsTermsTitle => 'အသုံးပြုမှု စည်းမျဉ်းများ';

  @override
  String get settingsExportingData => 'ဒေတာ ထုတ်ယူနေသည်...';

  @override
  String get settingsDataExportSuccess => 'ဒေတာ ထုတ်ယူမှု အောင်မြင်သည်!';

  @override
  String settingsExportFailed(String error) {
    return 'ထုတ်ယူမှု မအောင်မြင်ပါ: $error';
  }

  @override
  String get settingsImportDataTitle => 'ဒေတာ ထည့်သွင်းရန်';

  @override
  String get settingsImportDataMessage => 'ဤလုပ်ဆောင်မှုသည် JSON ဖိုင်မှ collection များနှင့် item များကို ထည့်သွင်းမည်ဖြစ်သည်။ ရှိပြီးသားဒေတာ မဖျက်ပါ။\\n\\nဆက်လုပ်မလား?';

  @override
  String get settingsImportingData => 'ဒေတာ ထည့်သွင်းနေသည်...';

  @override
  String get settingsDataImportSuccess => 'ဒေတာ ထည့်သွင်းမှု အောင်မြင်သည်!';

  @override
  String settingsImportFailed(String error) {
    return 'ထည့်သွင်းမှု မအောင်မြင်ပါ: $error';
  }

  @override
  String get settingsThemeModeTitle => 'Theme Mode';

  @override
  String get settingsThemeColorVariantTitle => 'အရောင် အမျိုးအစား';

  @override
  String get settingsAmoledTitle => 'Amoled Mode (အနက်စင်)';

  @override
  String get settingsAmoledSubtitle => 'OLED မျက်နှာပြင်တွင် ဘက်ထရီသုံးစွဲမှု လျှော့ချပေးသည်';

  @override
  String get themeModeSystem => 'စနစ်အတိုင်း';

  @override
  String get themeModeLight => 'အလင်း';

  @override
  String get themeModeDark => 'အမှောင်';

  @override
  String get languageSystem => 'စနစ်ပုံမှန်';

  @override
  String get languageEnglish => 'အင်္ဂလိပ်';

  @override
  String get languageSpanish => 'စပိန်';

  @override
  String get languageIndonesian => 'အင်ဒိုနီးရှား';

  @override
  String get languageJapanese => 'ဂျပန်';

  @override
  String get languageKorean => 'ကိုရီးယား';

  @override
  String get languageChineseSimplified => 'တရုတ် (ရိုးရှင်း)';

  @override
  String get languageBurmese => 'မြန်မာ';

  @override
  String get collectionsTitle => 'ကျွန်ုပ်၏ Collection များ';

  @override
  String get collectionsCountLabel => 'Collections';

  @override
  String get collectionsNewButton => 'Collection အသစ်';

  @override
  String get collectionsActionsTooltip => 'Collection လုပ်ဆောင်ချက်များ';

  @override
  String get collectionsOpenAction => 'Collection ဖွင့်မည်';

  @override
  String get collectionsEditAction => 'Collection ပြင်မည်';

  @override
  String get collectionsDeleteTitle => 'Collection ဖျက်ရန်';

  @override
  String collectionsDeleteMessage(String name, int itemCount) {
    return '\"$name\" နှင့် ဤ collection အတွင်းရှိ items $itemCount ခုကို ဖျက်မလား?';
  }

  @override
  String collectionsDeleted(String name) {
    return '$name ကို ဖျက်ပြီး';
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
  String get statisticsTitle => 'စာရင်းအင်း';

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
  String get collectionDetailsNotFoundTitle => 'Collection မတွေ့ပါ';

  @override
  String get collectionDetailsNotFoundMessage => 'ရွေးချယ်ထားသော collection ကို မရနိုင်ပါ။';

  @override
  String get collectionDetailsCreatedLabel => 'ဖန်တီးသည့်ရက်';

  @override
  String get collectionDetailsUpdatedLabel => 'နောက်ဆုံးပြင်ဆင်ချိန်';

  @override
  String get collectionDetailsLoading => 'Collection တင်နေသည်...';

  @override
  String get collectionTypeBooks => 'စာအုပ်များ';

  @override
  String get collectionTypeGames => 'ဂိမ်းများ';

  @override
  String get collectionTypeMovies => 'ရုပ်ရှင်များ';

  @override
  String get collectionTypeComics => 'ကွန်မစ်များ';

  @override
  String get collectionTypeMusic => 'ဂီတ';

  @override
  String get collectionTypeCustom => 'စိတ်ကြိုက်';
}
