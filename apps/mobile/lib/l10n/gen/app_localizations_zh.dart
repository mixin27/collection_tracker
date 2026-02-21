// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Collection Tracker';

  @override
  String get navHome => '首页';

  @override
  String get navFavorites => '收藏';

  @override
  String get navWishlist => '愿望单';

  @override
  String get navSettings => '设置';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '删除';

  @override
  String get actionDismiss => '关闭';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionImport => '导入';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSwitchToGrid => '切换为网格';

  @override
  String get actionSwitchToList => '切换为列表';

  @override
  String get actionUpdate => 'Update';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionGeneral => '通用';

  @override
  String get settingsSectionData => '数据';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String get settingsSectionDeveloper => '开发者';

  @override
  String get settingsThemeTitle => '主题';

  @override
  String get settingsLanguageTitle => '语言';

  @override
  String get settingsExportJsonTitle => '导出为 JSON';

  @override
  String get settingsExportJsonSubtitle => '将所有数据导出为 JSON 文件';

  @override
  String get settingsExportCsvTitle => '导出为 CSV';

  @override
  String get settingsExportCsvSubtitle => '将项目导出为 CSV 表格';

  @override
  String get settingsImportJsonTitle => '从 JSON 导入';

  @override
  String get settingsImportJsonSubtitle => '从 JSON 文件导入数据';

  @override
  String get settingsCloudSyncTitle => '云同步';

  @override
  String get settingsCloudSyncSubtitle => '未配置';

  @override
  String get settingsManageTagsTitle => '管理标签';

  @override
  String get settingsManageTagsSubtitle => '重命名、合并和删除标签';

  @override
  String get settingsVersionTitle => '版本';

  @override
  String get settingsPrivacyPolicyTitle => '隐私政策';

  @override
  String get settingsTermsTitle => '服务条款';

  @override
  String get settingsCrashlyticsTestTitle => '测试 Crashlytics';

  @override
  String get settingsCrashlyticsTestSubtitle => '故意让应用崩溃以验证崩溃上报';

  @override
  String get settingsCrashlyticsTestConfirmTitle => '触发测试崩溃？';

  @override
  String get settingsCrashlyticsTestConfirmMessage => '应用将立即崩溃。请重新打开应用，并在 Firebase Crashlytics 中确认该崩溃。';

  @override
  String get settingsCrashlyticsTestConfirmAction => '立即崩溃';

  @override
  String get settingsCrashlyticsTestTriggered => '正在触发测试崩溃...';

  @override
  String settingsCrashlyticsTestFailed(String error) {
    return '触发测试崩溃失败：$error';
  }

  @override
  String get settingsExportingData => '正在导出数据...';

  @override
  String get settingsDataExportSuccess => '数据导出成功！';

  @override
  String settingsExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get settingsImportDataTitle => '导入数据';

  @override
  String get settingsImportDataMessage => '这将从 JSON 文件导入集合和条目。现有数据不会被删除。\\n\\n是否继续？';

  @override
  String get settingsImportingData => '正在导入数据...';

  @override
  String get settingsDataImportSuccess => '数据导入成功！';

  @override
  String settingsImportFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get settingsThemeModeTitle => '主题模式';

  @override
  String get settingsThemeColorVariantTitle => '配色';

  @override
  String get settingsAmoledTitle => 'Amoled 模式（纯黑）';

  @override
  String get settingsAmoledSubtitle => '在 OLED 屏幕上可降低电量消耗';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get languageSystem => '系统默认';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageIndonesian => '印尼语';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageBurmese => '缅甸语';

  @override
  String get collectionsTitle => '我的收藏集';

  @override
  String get collectionsCountLabel => '收藏集';

  @override
  String get collectionsNewButton => '新建收藏集';

  @override
  String get collectionsActionsTooltip => '收藏集操作';

  @override
  String get collectionsOpenAction => '打开收藏集';

  @override
  String get collectionsEditAction => '编辑收藏集';

  @override
  String get collectionsDeleteTitle => '删除收藏集';

  @override
  String collectionsDeleteMessage(String name, int itemCount) {
    return '要删除\"$name\"以及此收藏集中的 $itemCount 个条目吗？';
  }

  @override
  String collectionsDeleted(String name) {
    return '已删除 $name';
  }

  @override
  String collectionsErrorLoading(String error) {
    return 'Error loading collections: $error';
  }

  @override
  String get itemsTitle => '条目';

  @override
  String get itemsCountLabel => '条目';

  @override
  String itemsCountWithValue(int count) {
    return '$count个条目';
  }

  @override
  String get itemsSearchHint => '搜索条目...';

  @override
  String get itemsNoMatchesTitle => '未找到匹配项';

  @override
  String get itemsNoMatchesMessage => '请尝试更改筛选条件或关键词。';

  @override
  String get itemsNoItemsTitle => '还没有条目';

  @override
  String get itemsNoItemsMessage => '先添加第一个条目开始。';

  @override
  String get itemsAddButton => '添加条目';

  @override
  String get itemsLoadingMessage => '正在加载条目...';

  @override
  String itemsErrorLoading(String error) {
    return '加载条目失败：$error';
  }

  @override
  String get itemsDeleteTitle => '删除条目';

  @override
  String itemsDeleteMessage(String name) {
    return '要删除“$name”吗？';
  }

  @override
  String itemsDeleted(String name) {
    return '已删除 $name';
  }

  @override
  String itemsOverviewCount(int count) {
    return '$count个条目';
  }

  @override
  String itemsSortedBy(String sortLabel) {
    return '排序方式：$sortLabel';
  }

  @override
  String get itemsCollectionDetailsTooltip => '收藏集详情';

  @override
  String get itemsFiltersTooltip => '筛选';

  @override
  String get itemsFilterTitle => '筛选条目';

  @override
  String get itemsSortByTitle => '排序方式';

  @override
  String get itemsFilterFavoritesOnly => '仅收藏';

  @override
  String get itemsFilterWishlistOnly => '仅愿望单';

  @override
  String get itemsFilterConditionsTitle => '状态';

  @override
  String get itemsTagsTitle => '标签';

  @override
  String itemsQuantityLabel(int quantity) {
    return '数量：$quantity';
  }

  @override
  String itemsQuantityShort(int quantity) {
    return 'x$quantity';
  }

  @override
  String get itemSortCustom => '自定义顺序';

  @override
  String get itemSortTitle => '标题';

  @override
  String get itemSortCreatedAt => '添加日期';

  @override
  String get itemSortPurchaseDate => '购买日期';

  @override
  String get itemSortCurrentValue => '当前价值';

  @override
  String get itemSortQuantity => '数量';

  @override
  String get itemConditionMint => '全新';

  @override
  String get itemConditionGood => '良好';

  @override
  String get itemConditionFair => '一般';

  @override
  String get itemConditionPoor => '较差';

  @override
  String get itemDetailNotFoundTitle => '未找到条目';

  @override
  String get itemDetailNotFoundMessage => '此条目已不存在。';

  @override
  String get itemDetailFavorited => '已收藏';

  @override
  String get itemDetailFavorite => '收藏';

  @override
  String get itemDetailInWishlist => '在愿望单中';

  @override
  String get itemDetailPriceTrackingTitle => '价格追踪';

  @override
  String get itemDetailNoValueMessage => '暂无当前价值';

  @override
  String get itemDetailNoHistoryMessage => '暂无价格历史';

  @override
  String get itemDetailPriceHistoryError => '无法加载价格历史';

  @override
  String get itemDetailDetailsTitle => '详情';

  @override
  String get itemDetailBarcodeLabel => '条形码';

  @override
  String get itemDetailConditionLabel => '状态';

  @override
  String get itemDetailQuantityLabel => '数量';

  @override
  String get itemDetailLocationLabel => '位置';

  @override
  String get itemDetailPurchasePriceLabel => '购买价格';

  @override
  String get itemDetailCurrentValueLabel => '当前价值';

  @override
  String get itemDetailPurchaseDateLabel => '购买日期';

  @override
  String get itemDetailNotesTitle => '备注';

  @override
  String get itemDetailLoadingMessage => '正在加载条目详情...';

  @override
  String itemDetailErrorLoading(String error) {
    return '加载条目详情失败：$error';
  }

  @override
  String get itemDetailUpdateValueTitle => '更新当前价值';

  @override
  String get itemDetailCurrentValueUpdated => '当前价值已更新';

  @override
  String itemDetailUpdateValueFailed(String error) {
    return '更新价值失败：$error';
  }

  @override
  String get addItemTitle => '添加条目';

  @override
  String get addItemSubmit => '添加条目';

  @override
  String get addItemTitleHint => '例如：《指环王》';

  @override
  String get addItemFetchingMetadata => '正在获取元数据...';

  @override
  String addItemMatchedMetadata(String source) {
    return '已匹配 $source 元数据';
  }

  @override
  String get addItemTagsHint => '例如：稀有、完整套装';

  @override
  String get addItemSuccess => '条目添加成功';

  @override
  String addItemError(String error) {
    return '添加条目失败：$error';
  }

  @override
  String get editItemTitle => '编辑条目';

  @override
  String get editItemLoading => '正在加载条目...';

  @override
  String editItemError(String error) {
    return '错误：$error';
  }

  @override
  String get editItemSaveChanges => '保存更改';

  @override
  String get editItemTagsHint => '例如：签名版、初版';

  @override
  String get editItemSuccess => '条目更新成功';

  @override
  String editItemUpdateError(String error) {
    return '更新条目失败：$error';
  }

  @override
  String get itemFormTitleLabel => '标题';

  @override
  String get itemFormTitleRequired => '请输入标题';

  @override
  String get itemFormBarcodeLabelOptional => '条形码（可选）';

  @override
  String get itemFormBarcodeHint => 'ISBN、UPC 等';

  @override
  String get itemFormDescriptionLabelOptional => '描述（可选）';

  @override
  String get itemFormDescriptionHint => '添加描述';

  @override
  String get itemFormTagsLabelOptional => '标签（可选）';

  @override
  String get itemFormPurchaseDateLabelOptional => '购买日期（可选）';

  @override
  String get itemFormConditionLabelOptional => '状态（可选）';

  @override
  String get itemFormQuantityRequired => '请输入数量';

  @override
  String get itemFormQuantityInvalid => '请输入有效数量';

  @override
  String get itemFormLocationLabelOptional => '位置（可选）';

  @override
  String get itemFormLocationHint => '例如：A架，3号箱';

  @override
  String get itemFormNotesLabelOptional => '备注（可选）';

  @override
  String get itemFormInvalidPrice => '价格无效';

  @override
  String get itemFormMustBePositive => '必须为正数';

  @override
  String get itemTagsEditorHint => '添加标签';

  @override
  String get itemTagsEditorAddTooltip => '添加标签';

  @override
  String get itemTagsEditorEmptyMessage => '还没有标签。添加标签可更快整理条目。';

  @override
  String get itemTagsEditorTooLong => '标签最多 50 个字符';

  @override
  String get globalItemsLoading => '正在加载条目...';

  @override
  String globalItemsErrorLoading(String error) {
    return '错误：$error';
  }

  @override
  String get globalItemsNoFavoritesTitle => '还没有收藏条目';

  @override
  String get globalItemsNoFavoritesMessage => '将条目标记为收藏后会显示在这里。';

  @override
  String get globalItemsNoWishlistTitle => '你的愿望单是空的';

  @override
  String get globalItemsNoWishlistMessage => '将条目保存到愿望单后可在这里查看。';

  @override
  String metadataSearchFieldLabel(String collectionType) {
    return '按标题搜索 $collectionType';
  }

  @override
  String get metadataSearchEmptyTitle => '搜索元数据';

  @override
  String get metadataSearchEmptyMessage => '输入标题以搜索。';

  @override
  String get metadataSearchLoading => '正在搜索元数据...';

  @override
  String metadataSearchError(String error) {
    return '错误：$error';
  }

  @override
  String get metadataSearchNoResultsTitle => '无结果';

  @override
  String get metadataSearchNoResultsMessage => '未找到该标题的元数据。';

  @override
  String get metadataSearchSuggestionTitle => '按标题搜索';

  @override
  String get metadataSearchSuggestionMessage => '开始输入以查找元数据。';

  @override
  String tagItemsTitle(String tag) {
    return '标签：$tag';
  }

  @override
  String get tagItemsSortTooltip => '排序';

  @override
  String get tagItemsSortNewest => '排序：最新';

  @override
  String get tagItemsSortOldest => '排序：最早';

  @override
  String get tagItemsSortTitle => '排序：标题';

  @override
  String get tagItemsLoadingCollections => '正在加载收藏集...';

  @override
  String get tagItemsLoadingItems => '正在加载带标签条目...';

  @override
  String tagItemsError(String error) {
    return '错误：$error';
  }

  @override
  String get tagItemsEmptyTitle => '未找到条目';

  @override
  String get tagItemsEmptyMessage => '当前没有条目使用此标签。';

  @override
  String get tagItemsUnknownCollection => '未知';

  @override
  String get tagItemsOpenCollectionTooltip => '打开收藏集';

  @override
  String tagItemsDeleteFailed(String error) {
    return '删除失败：$error';
  }

  @override
  String get tagManagementTitle => '管理标签';

  @override
  String tagManagementSelectedCount(int count) {
    return '已选择 $count 个';
  }

  @override
  String get tagManagementCancelSelectionTooltip => '取消选择';

  @override
  String get tagManagementSelectTagsTooltip => '选择标签';

  @override
  String get tagManagementSearchHint => '搜索标签...';

  @override
  String get tagManagementEmptyTitle => '还没有创建标签';

  @override
  String tagManagementNoMatch(String query) {
    return '没有与“$query”匹配的标签';
  }

  @override
  String get tagManagementSelectVisible => '选择可见项';

  @override
  String get tagManagementSelectAllMatches => '选择全部匹配项';

  @override
  String get tagManagementClearSelection => '清除选择';

  @override
  String tagManagementScrollMore(int remaining) {
    return '滚动以加载另外 $remaining 个标签';
  }

  @override
  String get tagManagementUsedInOne => '用于 1 个条目';

  @override
  String tagManagementUsedInMany(int count) {
    return '用于 $count 个条目';
  }

  @override
  String get tagManagementRenameAction => '重命名';

  @override
  String get tagManagementMergeAction => '合并';

  @override
  String get tagManagementMergeIntoAction => '合并到...';

  @override
  String tagManagementLoadError(String error) {
    return '加载标签失败：$error';
  }

  @override
  String get tagManagementRenameTitle => '重命名标签';

  @override
  String get tagManagementNewNameLabel => '新名称';

  @override
  String tagManagementRenameSuccess(String oldName, String newName) {
    return '“$oldName”已重命名为“$newName”';
  }

  @override
  String get tagManagementMergeSelectedTitle => '合并所选标签';

  @override
  String get tagManagementChooseDestination => '选择目标标签：';

  @override
  String tagManagementMergeSelectedSuccess(int count, String destination) {
    return '已将 $count 个标签合并到“$destination”';
  }

  @override
  String get tagManagementDeleteSelectedTitle => '删除所选标签';

  @override
  String tagManagementDeleteSelectedMessage(int count) {
    return '要从所有条目中删除所选的 $count 个标签吗？\\n\\n此操作无法撤销。';
  }

  @override
  String tagManagementDeleteSelectedSuccess(int count) {
    return '已删除 $count 个标签';
  }

  @override
  String get tagManagementMergeIntoTitle => '合并到';

  @override
  String tagManagementMergeSuccess(String source, String target) {
    return '已将“$source”合并到“$target”';
  }

  @override
  String get tagManagementDeleteTitle => '删除标签';

  @override
  String tagManagementDeleteMessage(String tagName) {
    return '要从所有条目中删除“$tagName”吗？\\n\\n此操作无法撤销。';
  }

  @override
  String tagManagementDeleteSuccess(String tagName) {
    return '已删除“$tagName”';
  }

  @override
  String tagManagementMutationError(String error) {
    return '标签更新失败：$error';
  }

  @override
  String get statisticsTitle => '统计';

  @override
  String get statisticsEmptyTitle => '暂无统计';

  @override
  String get statisticsEmptyMessage => '添加收藏集和条目后即可查看洞察。';

  @override
  String get statisticsLoadingMessage => '正在加载统计...';

  @override
  String statisticsErrorLoading(String error) {
    return '加载统计失败：$error';
  }

  @override
  String get statisticsPortfolioValueTitle => '资产总价值';

  @override
  String statisticsAveragePricedItem(String value) {
    return '已估值条目均值：$value';
  }

  @override
  String statisticsPricedItemsBadge(int priced, int total) {
    return '已估值条目：$priced/$total';
  }

  @override
  String get statisticsQuantityTitle => '总数量';

  @override
  String get statisticsFavoritesTitle => '收藏';

  @override
  String statisticsPercentOfItems(String percent) {
    return '占条目 $percent%';
  }

  @override
  String get statisticsInventoryHealthTitle => '库存健康度';

  @override
  String get statisticsValuationCoverageLabel => '估值覆盖率';

  @override
  String statisticsPricedCaption(int priced, int total) {
    return '$total个条目中有$priced个已设价格';
  }

  @override
  String get statisticsFavoritesCoverageLabel => '收藏覆盖率';

  @override
  String statisticsFavoritesCaption(int favorites, int total) {
    return '$total个条目中有$favorites个为收藏';
  }

  @override
  String get statisticsWishlistCoverageLabel => '愿望单覆盖率';

  @override
  String statisticsWishlistCaption(int wishlist, int total) {
    return '$total个条目中有$wishlist个在愿望单';
  }

  @override
  String get statisticsItemsByTypeTitle => '按类型统计条目';

  @override
  String get statisticsItemsByConditionTitle => '按状态统计条目';

  @override
  String get statisticsTopValuedTitle => '高价值收藏集';

  @override
  String get statisticsLargestCollectionTitle => '最大收藏集';

  @override
  String get statisticsRecentlyCreatedTitle => '最近创建';

  @override
  String statisticsRecentCollectionSubtitle(int itemCount, String createdAt) {
    return '$itemCount个条目 • $createdAt';
  }

  @override
  String get statisticsNoChartData => '暂无图表数据';

  @override
  String get statisticsTotalLabel => '总计';

  @override
  String get relativeToday => '今天';

  @override
  String get relativeYesterday => '昨天';

  @override
  String relativeDaysAgo(int days) {
    return '$days天前';
  }

  @override
  String relativeWeeksAgo(int weeks) {
    return '$weeks周前';
  }

  @override
  String relativeMonthsAgo(int months) {
    return '$months个月前';
  }

  @override
  String relativeYearsAgo(int years) {
    return '$years年前';
  }

  @override
  String get collectionDetailsNotFoundTitle => '未找到收藏集';

  @override
  String get collectionDetailsNotFoundMessage => '所选收藏集不可用。';

  @override
  String get collectionDetailsCreatedLabel => '创建时间';

  @override
  String get collectionDetailsUpdatedLabel => '最后更新';

  @override
  String get collectionDetailsLoading => '正在加载收藏集...';

  @override
  String get collectionTypeBooks => '图书';

  @override
  String get collectionTypeGames => '游戏';

  @override
  String get collectionTypeMovies => '电影';

  @override
  String get collectionTypeComics => '漫画';

  @override
  String get collectionTypeMusic => '音乐';

  @override
  String get collectionTypeCustom => '自定义';
}
