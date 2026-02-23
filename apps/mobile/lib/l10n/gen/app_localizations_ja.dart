// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Collection Tracker';

  @override
  String get navHome => 'ホーム';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get navWishlist => 'ウィッシュリスト';

  @override
  String get navSettings => '設定';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionDelete => '削除';

  @override
  String get actionDismiss => '閉じる';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionImport => 'インポート';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSwitchToGrid => 'グリッド表示';

  @override
  String get actionSwitchToList => 'リスト表示';

  @override
  String get actionUpdate => 'Update';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionGeneral => '一般';

  @override
  String get settingsSectionData => 'データ';

  @override
  String get settingsSectionAbout => '情報';

  @override
  String get settingsSectionDeveloper => '開発者';

  @override
  String get settingsThemeTitle => 'テーマ';

  @override
  String get settingsLanguageTitle => '言語';

  @override
  String get settingsExportJsonTitle => 'JSONにエクスポート';

  @override
  String get settingsExportJsonSubtitle => 'すべてのデータをJSONとして出力';

  @override
  String get settingsExportCsvTitle => 'CSVにエクスポート';

  @override
  String get settingsExportCsvSubtitle => 'アイテムをCSVとして出力';

  @override
  String get settingsImportJsonTitle => 'JSONからインポート';

  @override
  String get settingsImportJsonSubtitle => 'JSONファイルからデータを取り込む';

  @override
  String get settingsCloudSyncTitle => 'クラウド同期';

  @override
  String get settingsCloudSyncSubtitle => '未設定';

  @override
  String get settingsManageTagsTitle => 'タグ管理';

  @override
  String get settingsManageTagsSubtitle => 'タグの名前変更・統合・削除';

  @override
  String get settingsLoanTrackingTitle => '貸出管理';

  @override
  String get settingsLoanTrackingSubtitle => '貸し出したアイテムと返却予定日を追跡';

  @override
  String get settingsVersionTitle => 'バージョン';

  @override
  String get settingsPrivacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get settingsTermsTitle => '利用規約';

  @override
  String get settingsAnalyticsTitle => 'アナリティクス';

  @override
  String get settingsAnalyticsSummaryEnabled => '有効';

  @override
  String get settingsAnalyticsSummaryDisabled => '無効';

  @override
  String get settingsAnalyticsSummaryPending => '同意が必要';

  @override
  String get settingsAnalyticsSummaryDenied => '同意しない';

  @override
  String get settingsAnalyticsSheetTitle => 'アナリティクス設定';

  @override
  String get settingsAnalyticsDescription => '匿名の利用状況分析とデータ共有設定を管理します。';

  @override
  String get settingsAnalyticsToggleTitle => 'アナリティクスを有効化';

  @override
  String get settingsAnalyticsToggleSubtitle => '匿名のアプリ利用イベントの収集を許可します。';

  @override
  String get settingsAnalyticsConsentStatusTitle => '同意ステータス';

  @override
  String get settingsAnalyticsConsentStatusGranted => '同意済み';

  @override
  String get settingsAnalyticsConsentStatusDenied => '拒否';

  @override
  String get settingsAnalyticsConsentStatusPending => '保留';

  @override
  String get settingsAnalyticsReviewConsentAction => '同意内容を確認';

  @override
  String get settingsAnalyticsRevokeConsentAction => '同意を取り消す';

  @override
  String get settingsAnalyticsConsentAccepted => 'アナリティクスへの同意を受け付けました。';

  @override
  String get settingsAnalyticsConsentDeclined => 'アナリティクスへの同意を拒否しました。';

  @override
  String get analyticsConsentDialogTitle => 'Collection Tracker の改善にご協力ください';

  @override
  String get analyticsConsentDialogMessage => 'アプリ品質と機能改善のため、匿名の利用データ収集にご協力いただけますか？この設定はいつでも設定画面で変更できます。';

  @override
  String get analyticsConsentAllowAction => '許可';

  @override
  String get analyticsConsentDeclineAction => '今はしない';

  @override
  String get settingsCrashlyticsTestTitle => 'Crashlytics をテスト';

  @override
  String get settingsCrashlyticsTestSubtitle => 'クラッシュレポートを確認するため、意図的にアプリをクラッシュさせます';

  @override
  String get settingsCrashlyticsTestConfirmTitle => 'テストクラッシュを実行しますか？';

  @override
  String get settingsCrashlyticsTestConfirmMessage => 'アプリはすぐにクラッシュします。再起動して Firebase Crashlytics でクラッシュを確認してください。';

  @override
  String get settingsCrashlyticsTestConfirmAction => '今すぐクラッシュ';

  @override
  String get settingsCrashlyticsTestTriggered => 'テストクラッシュを実行しています...';

  @override
  String settingsCrashlyticsTestFailed(String error) {
    return 'テストクラッシュの実行に失敗しました: $error';
  }

  @override
  String get settingsFirebaseRuntimeConfigTitle => 'Firebase ランタイム設定';

  @override
  String get settingsFirebaseRuntimeConfigSubtitle => 'ランタイム機能フラグを確認して更新';

  @override
  String get settingsMetadataTitle => 'メタデータと自動入力';

  @override
  String get settingsMetadataSummaryEnabled => 'バーコード自動検索で有効';

  @override
  String get settingsMetadataSummaryManual => '手動検索で有効';

  @override
  String get settingsMetadataSummaryDisabled => '無効';

  @override
  String get settingsMetadataSummaryFeatureDisabled => '実行時の機能フラグにより無効';

  @override
  String get settingsMetadataEnableToggleTitle => 'メタデータ補助を有効化';

  @override
  String get settingsMetadataEnableToggleSubtitle => 'アイテムフォームでメタデータ検索とバーコード自動入力を利用します。';

  @override
  String get settingsMetadataAutoFetchToggleTitle => 'バーコード読み取り時に自動取得';

  @override
  String get settingsMetadataAutoFetchToggleSubtitle => 'バーコードを読み取った後、メタデータを自動取得します。';

  @override
  String get settingsMetadataFillEmptyOnlyToggleTitle => '空欄のみ入力';

  @override
  String get settingsMetadataFillEmptyOnlyToggleSubtitle => 'メタデータ検出時に既存のタイトルや説明を上書きしません。';

  @override
  String get settingsMetadataSourcesSectionTitle => 'ソース';

  @override
  String get settingsMetadataSourceAvailable => '利用可能';

  @override
  String get settingsMetadataSourceNotConfigured => '未設定';

  @override
  String get settingsMetadataSourceManualOnly => '手動のみ';

  @override
  String get settingsMetadataManualCollectionsLabel => 'コミック・音楽・カスタム';

  @override
  String get settingsMetadataFeatureDisabledMessage => 'メタデータ補助は実行時設定で無効化されています。';

  @override
  String get settingsFirebaseRuntimeConfigSheetTitle => 'Firebase ランタイム設定';

  @override
  String get settingsFirebaseRuntimeConfigDescription => '値は Firebase Remote Config から取得され、実行時に適用されます。';

  @override
  String settingsFirebaseRuntimeConfigSummary(int enabledCount) {
    return '3 件中 $enabledCount 件が有効';
  }

  @override
  String get settingsFirebaseRuntimeConfigAnalyticsLabel => 'アナリティクス収集';

  @override
  String get settingsFirebaseRuntimeConfigCrashlyticsLabel => 'Crashlytics 収集';

  @override
  String get settingsFirebaseRuntimeConfigPerformanceLabel => 'パフォーマンス収集';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusTitle => '最終取得ステータス';

  @override
  String get settingsFirebaseRuntimeConfigLastFetchTitle => '最終取得時刻';

  @override
  String get settingsFirebaseRuntimeConfigValueEnabled => '有効';

  @override
  String get settingsFirebaseRuntimeConfigValueDisabled => '無効';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusSuccess => '成功';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusFailure => '失敗';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusThrottled => '制限中';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusNoFetch => '未取得';

  @override
  String get settingsFirebaseRuntimeConfigRefreshAction => '設定を更新';

  @override
  String get settingsFirebaseRuntimeConfigRefreshingAction => '更新中...';

  @override
  String get settingsFirebaseRuntimeConfigRefreshSuccess => 'Firebase ランタイム設定を更新しました。';

  @override
  String get settingsFirebaseRuntimeConfigRefreshNoChanges => 'Firebase ランタイム設定は最新です。';

  @override
  String settingsFirebaseRuntimeConfigRefreshFailed(String error) {
    return '設定の更新に失敗しました: $error';
  }

  @override
  String get settingsExportingData => 'データをエクスポート中...';

  @override
  String get settingsDataExportSuccess => 'データのエクスポートに成功しました！';

  @override
  String settingsExportFailed(String error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get settingsImportDataTitle => 'データをインポート';

  @override
  String get settingsImportDataMessage => 'JSONファイルからコレクションとアイテムをインポートします。既存データは削除されません。\\n\\n続行しますか？';

  @override
  String get settingsImportingData => 'データをインポート中...';

  @override
  String get settingsDataImportSuccess => 'データのインポートに成功しました！';

  @override
  String settingsImportFailed(String error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get settingsThemeModeTitle => 'テーマモード';

  @override
  String get settingsThemeColorVariantTitle => 'カラーバリエーション';

  @override
  String get settingsAmoledTitle => 'Amoledモード（純黒）';

  @override
  String get settingsAmoledSubtitle => 'OLED画面でバッテリー消費を抑えます';

  @override
  String get themeModeSystem => 'システム';

  @override
  String get themeModeLight => 'ライト';

  @override
  String get themeModeDark => 'ダーク';

  @override
  String get languageSystem => 'システム設定';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languageIndonesian => 'インドネシア語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '韓国語';

  @override
  String get languageChineseSimplified => '簡体字中国語';

  @override
  String get languageBurmese => 'ビルマ語';

  @override
  String get collectionsTitle => 'マイコレクション';

  @override
  String get collectionsCountLabel => 'コレクション';

  @override
  String get collectionsNewButton => '新しいコレクション';

  @override
  String get collectionsActionsTooltip => 'コレクション操作';

  @override
  String get collectionsOpenAction => 'コレクションを開く';

  @override
  String get collectionsEditAction => 'コレクションを編集';

  @override
  String get collectionsDeleteTitle => 'コレクションを削除';

  @override
  String collectionsDeleteMessage(String name, int itemCount) {
    return '\"$name\" とこのコレクション内の $itemCount 件のアイテムを削除しますか？';
  }

  @override
  String collectionsDeleted(String name) {
    return '$name を削除しました';
  }

  @override
  String collectionsErrorLoading(String error) {
    return 'Error loading collections: $error';
  }

  @override
  String get itemsTitle => 'アイテム';

  @override
  String get itemsCountLabel => 'アイテム';

  @override
  String itemsCountWithValue(int count) {
    return '$count件';
  }

  @override
  String get itemsSearchHint => 'アイテムを検索...';

  @override
  String get itemsNoMatchesTitle => '一致する結果がありません';

  @override
  String get itemsNoMatchesMessage => 'フィルターやキーワードを変更してください。';

  @override
  String get itemsNoItemsTitle => 'まだアイテムがありません';

  @override
  String get itemsNoItemsMessage => '最初のアイテムを追加して始めましょう。';

  @override
  String get itemsAddButton => 'アイテムを追加';

  @override
  String get itemsLoadingMessage => 'アイテムを読み込み中...';

  @override
  String itemsErrorLoading(String error) {
    return 'アイテムの読み込みエラー: $error';
  }

  @override
  String get itemsDeleteTitle => 'アイテムを削除';

  @override
  String itemsDeleteMessage(String name) {
    return '\"$name\" を削除しますか？';
  }

  @override
  String itemsDeleted(String name) {
    return '$name を削除しました';
  }

  @override
  String itemsOverviewCount(int count) {
    return '$count件';
  }

  @override
  String itemsSortedBy(String sortLabel) {
    return '並び順: $sortLabel';
  }

  @override
  String get itemsCollectionDetailsTooltip => 'コレクション詳細';

  @override
  String get itemsFiltersTooltip => 'フィルター';

  @override
  String get itemsFilterTitle => 'アイテムを絞り込む';

  @override
  String get itemsSortByTitle => '並び替え';

  @override
  String get itemsFilterFavoritesOnly => 'お気に入りのみ';

  @override
  String get itemsFilterWishlistOnly => 'ウィッシュリストのみ';

  @override
  String get itemsFilterConditionsTitle => '状態';

  @override
  String get itemsTagsTitle => 'タグ';

  @override
  String itemsQuantityLabel(int quantity) {
    return '数量: $quantity';
  }

  @override
  String itemsQuantityShort(int quantity) {
    return 'x$quantity';
  }

  @override
  String get itemSortCustom => 'カスタム順';

  @override
  String get itemSortTitle => 'タイトル';

  @override
  String get itemSortCreatedAt => '追加日';

  @override
  String get itemSortPurchaseDate => '購入日';

  @override
  String get itemSortCurrentValue => '現在価値';

  @override
  String get itemSortQuantity => '数量';

  @override
  String get itemConditionMint => '新品同様';

  @override
  String get itemConditionGood => '良好';

  @override
  String get itemConditionFair => '普通';

  @override
  String get itemConditionPoor => '悪い';

  @override
  String get itemDetailNotFoundTitle => 'アイテムが見つかりません';

  @override
  String get itemDetailNotFoundMessage => 'このアイテムは存在しません。';

  @override
  String get itemDetailFavorited => 'お気に入り済み';

  @override
  String get itemDetailFavorite => 'お気に入り';

  @override
  String get itemDetailInWishlist => 'ウィッシュリスト済み';

  @override
  String get itemDetailPriceTrackingTitle => '価格トラッキング';

  @override
  String get itemDetailNoValueMessage => '現在価値がありません';

  @override
  String get itemDetailNoHistoryMessage => '価格履歴がまだありません';

  @override
  String get itemDetailPriceHistoryError => '価格履歴を読み込めません';

  @override
  String get itemDetailDetailsTitle => '詳細';

  @override
  String get itemDetailBarcodeLabel => 'バーコード';

  @override
  String get itemDetailConditionLabel => '状態';

  @override
  String get itemDetailQuantityLabel => '数量';

  @override
  String get itemDetailLocationLabel => '保管場所';

  @override
  String get itemDetailPurchasePriceLabel => '購入価格';

  @override
  String get itemDetailCurrentValueLabel => '現在価値';

  @override
  String get itemDetailPurchaseDateLabel => '購入日';

  @override
  String get itemDetailNotesTitle => 'メモ';

  @override
  String get itemDetailLoadingMessage => 'アイテム詳細を読み込み中...';

  @override
  String itemDetailErrorLoading(String error) {
    return 'アイテム詳細の読み込みエラー: $error';
  }

  @override
  String get itemDetailUpdateValueTitle => '現在価値を更新';

  @override
  String get itemDetailCurrentValueUpdated => '現在価値を更新しました';

  @override
  String itemDetailUpdateValueFailed(String error) {
    return '値の更新に失敗しました: $error';
  }

  @override
  String get addItemTitle => 'アイテムを追加';

  @override
  String get addItemSubmit => 'アイテムを追加';

  @override
  String get addItemTitleHint => '例: ロード・オブ・ザ・リング';

  @override
  String get addItemFetchingMetadata => 'メタデータを取得中...';

  @override
  String addItemMatchedMetadata(String source) {
    return '$source のメタデータに一致しました';
  }

  @override
  String get addItemTagsHint => '例: レア, コンプリートセット';

  @override
  String get addItemSuccess => 'アイテムを追加しました';

  @override
  String addItemError(String error) {
    return 'アイテムの追加エラー: $error';
  }

  @override
  String get editItemTitle => 'アイテムを編集';

  @override
  String get editItemLoading => 'アイテムを読み込み中...';

  @override
  String editItemError(String error) {
    return 'エラー: $error';
  }

  @override
  String get editItemSaveChanges => '変更を保存';

  @override
  String get editItemTagsHint => '例: サイン入り, 初版';

  @override
  String get editItemSuccess => 'アイテムを更新しました';

  @override
  String editItemUpdateError(String error) {
    return 'アイテムの更新エラー: $error';
  }

  @override
  String get itemFormTitleLabel => 'タイトル';

  @override
  String get itemFormTitleRequired => 'タイトルを入力してください';

  @override
  String get itemFormBarcodeLabelOptional => 'バーコード（任意）';

  @override
  String get itemFormBarcodeHint => 'ISBN, UPC など';

  @override
  String get itemFormDescriptionLabelOptional => '説明（任意）';

  @override
  String get itemFormDescriptionHint => '説明を追加';

  @override
  String get itemFormTagsLabelOptional => 'タグ（任意）';

  @override
  String get itemFormPurchaseDateLabelOptional => '購入日（任意）';

  @override
  String get itemFormConditionLabelOptional => '状態（任意）';

  @override
  String get itemFormQuantityRequired => '数量を入力してください';

  @override
  String get itemFormQuantityInvalid => '有効な数量を入力してください';

  @override
  String get itemFormLocationLabelOptional => '保管場所（任意）';

  @override
  String get itemFormLocationHint => '例: 棚A、箱3';

  @override
  String get itemFormNotesLabelOptional => 'メモ（任意）';

  @override
  String get itemFormInvalidPrice => '無効な価格です';

  @override
  String get itemFormMustBePositive => '0以上で入力してください';

  @override
  String get itemTagsEditorHint => 'タグを追加';

  @override
  String get itemTagsEditorAddTooltip => 'タグを追加';

  @override
  String get itemTagsEditorEmptyMessage => 'まだタグがありません。タグを追加すると整理しやすくなります。';

  @override
  String get itemTagsEditorTooLong => 'タグは50文字以内で入力してください';

  @override
  String get globalItemsLoading => 'アイテムを読み込み中...';

  @override
  String globalItemsErrorLoading(String error) {
    return 'エラー: $error';
  }

  @override
  String get globalItemsNoFavoritesTitle => 'お気に入りのアイテムはまだありません';

  @override
  String get globalItemsNoFavoritesMessage => 'アイテムをお気に入りに追加するとここに表示されます。';

  @override
  String get globalItemsNoWishlistTitle => 'ウィッシュリストは空です';

  @override
  String get globalItemsNoWishlistMessage => 'アイテムをウィッシュリストに保存するとここに表示されます。';

  @override
  String metadataSearchFieldLabel(String collectionType) {
    return '$collectionType をタイトルで検索';
  }

  @override
  String get metadataSearchEmptyTitle => 'メタデータ検索';

  @override
  String get metadataSearchEmptyMessage => '検索するタイトルを入力してください。';

  @override
  String get metadataSearchLoading => 'メタデータを検索中...';

  @override
  String metadataSearchError(String error) {
    return 'エラー: $error';
  }

  @override
  String get metadataSearchNoResultsTitle => '結果がありません';

  @override
  String get metadataSearchNoResultsMessage => 'このタイトルのメタデータは見つかりませんでした。';

  @override
  String get metadataSearchSuggestionTitle => 'タイトルで検索';

  @override
  String get metadataSearchSuggestionMessage => '入力してメタデータを検索してください。';

  @override
  String get metadataSearchDisabledHint => 'このコレクション種別ではメタデータ検索が利用できないか、現在無効です。';

  @override
  String get metadataNoMatchForBarcode => 'このバーコードに一致するメタデータが見つかりません。';

  @override
  String metadataSearchUnavailableForType(String collectionType) {
    return '$collectionType ではメタデータ検索を利用できません。';
  }

  @override
  String tagItemsTitle(String tag) {
    return 'タグ: $tag';
  }

  @override
  String get tagItemsSortTooltip => '並び替え';

  @override
  String get tagItemsSortNewest => '並び替え: 新しい順';

  @override
  String get tagItemsSortOldest => '並び替え: 古い順';

  @override
  String get tagItemsSortTitle => '並び替え: タイトル順';

  @override
  String get tagItemsLoadingCollections => 'コレクションを読み込み中...';

  @override
  String get tagItemsLoadingItems => 'タグ付きアイテムを読み込み中...';

  @override
  String tagItemsError(String error) {
    return 'エラー: $error';
  }

  @override
  String get tagItemsEmptyTitle => 'アイテムが見つかりません';

  @override
  String get tagItemsEmptyMessage => 'このタグを使用しているアイテムはありません。';

  @override
  String get tagItemsUnknownCollection => '不明';

  @override
  String get tagItemsOpenCollectionTooltip => 'コレクションを開く';

  @override
  String tagItemsDeleteFailed(String error) {
    return '削除に失敗しました: $error';
  }

  @override
  String get tagManagementTitle => 'タグ管理';

  @override
  String tagManagementSelectedCount(int count) {
    return '$count件を選択';
  }

  @override
  String get tagManagementCancelSelectionTooltip => '選択をキャンセル';

  @override
  String get tagManagementSelectTagsTooltip => 'タグを選択';

  @override
  String get tagManagementSearchHint => 'タグを検索...';

  @override
  String get tagManagementEmptyTitle => 'まだタグがありません';

  @override
  String tagManagementNoMatch(String query) {
    return '\"$query\" に一致するタグはありません';
  }

  @override
  String get tagManagementSelectVisible => '表示中を選択';

  @override
  String get tagManagementSelectAllMatches => '一致するものをすべて選択';

  @override
  String get tagManagementClearSelection => '選択を解除';

  @override
  String tagManagementScrollMore(int remaining) {
    return 'スクロールしてさらに $remaining 件のタグを読み込む';
  }

  @override
  String get tagManagementUsedInOne => '1件のアイテムで使用';

  @override
  String tagManagementUsedInMany(int count) {
    return '$count件のアイテムで使用';
  }

  @override
  String get tagManagementRenameAction => '名前を変更';

  @override
  String get tagManagementMergeAction => '統合';

  @override
  String get tagManagementMergeIntoAction => '次に統合...';

  @override
  String tagManagementLoadError(String error) {
    return 'タグの読み込みに失敗しました: $error';
  }

  @override
  String get tagManagementRenameTitle => 'タグ名を変更';

  @override
  String get tagManagementNewNameLabel => '新しい名前';

  @override
  String tagManagementRenameSuccess(String oldName, String newName) {
    return '\"$oldName\" を \"$newName\" に変更しました';
  }

  @override
  String get tagManagementMergeSelectedTitle => '選択したタグを統合';

  @override
  String get tagManagementChooseDestination => '統合先のタグを選択:';

  @override
  String tagManagementMergeSelectedSuccess(int count, String destination) {
    return '$count件のタグを \"$destination\" に統合しました';
  }

  @override
  String get tagManagementDeleteSelectedTitle => '選択したタグを削除';

  @override
  String tagManagementDeleteSelectedMessage(int count) {
    return 'すべてのアイテムから選択した $count 件のタグを削除しますか？\\n\\nこの操作は元に戻せません。';
  }

  @override
  String tagManagementDeleteSelectedSuccess(int count) {
    return '$count件のタグを削除しました';
  }

  @override
  String get tagManagementMergeIntoTitle => '統合先';

  @override
  String tagManagementMergeSuccess(String source, String target) {
    return '\"$source\" を \"$target\" に統合しました';
  }

  @override
  String get tagManagementDeleteTitle => 'タグを削除';

  @override
  String tagManagementDeleteMessage(String tagName) {
    return 'すべてのアイテムから \"$tagName\" を削除しますか？\\n\\nこの操作は元に戻せません。';
  }

  @override
  String tagManagementDeleteSuccess(String tagName) {
    return '\"$tagName\" を削除しました';
  }

  @override
  String tagManagementMutationError(String error) {
    return 'タグの更新に失敗しました: $error';
  }

  @override
  String get statisticsTitle => '統計';

  @override
  String get statisticsEmptyTitle => 'まだ統計がありません';

  @override
  String get statisticsEmptyMessage => 'コレクションとアイテムを追加するとインサイトを表示できます。';

  @override
  String get statisticsLoadingMessage => '統計を読み込み中...';

  @override
  String statisticsErrorLoading(String error) {
    return '統計の読み込みエラー: $error';
  }

  @override
  String get statisticsPortfolioValueTitle => 'ポートフォリオ価値';

  @override
  String statisticsAveragePricedItem(String value) {
    return '平均評価額: $value';
  }

  @override
  String statisticsPricedItemsBadge(int priced, int total) {
    return '価格設定済み: $priced/$total';
  }

  @override
  String get statisticsQuantityTitle => '総数量';

  @override
  String get statisticsFavoritesTitle => 'お気に入り';

  @override
  String statisticsPercentOfItems(String percent) {
    return 'アイテムの$percent%';
  }

  @override
  String get statisticsInventoryHealthTitle => '在庫状況';

  @override
  String get statisticsValuationCoverageLabel => '価格設定カバレッジ';

  @override
  String statisticsPricedCaption(int priced, int total) {
    return '$total件中$priced件に価格あり';
  }

  @override
  String get statisticsFavoritesCoverageLabel => 'お気に入りカバレッジ';

  @override
  String statisticsFavoritesCaption(int favorites, int total) {
    return '$total件中$favorites件がお気に入り';
  }

  @override
  String get statisticsWishlistCoverageLabel => 'ウィッシュリストカバレッジ';

  @override
  String statisticsWishlistCaption(int wishlist, int total) {
    return '$total件中$wishlist件がウィッシュリスト';
  }

  @override
  String get statisticsItemsByTypeTitle => '種類別アイテム';

  @override
  String get statisticsItemsByConditionTitle => '状態別アイテム';

  @override
  String get statisticsTopValuedTitle => '高価値コレクション';

  @override
  String get statisticsLargestCollectionTitle => '最大のコレクション';

  @override
  String get statisticsRecentlyCreatedTitle => '最近作成';

  @override
  String statisticsRecentCollectionSubtitle(int itemCount, String createdAt) {
    return '$itemCount件 • $createdAt';
  }

  @override
  String get statisticsNoChartData => 'グラフデータがありません';

  @override
  String get statisticsTotalLabel => '合計';

  @override
  String get relativeToday => '今日';

  @override
  String get relativeYesterday => '昨日';

  @override
  String relativeDaysAgo(int days) {
    return '$days日前';
  }

  @override
  String relativeWeeksAgo(int weeks) {
    return '$weeks週間前';
  }

  @override
  String relativeMonthsAgo(int months) {
    return '$monthsか月前';
  }

  @override
  String relativeYearsAgo(int years) {
    return '$years年前';
  }

  @override
  String get collectionDetailsNotFoundTitle => 'コレクションが見つかりません';

  @override
  String get collectionDetailsNotFoundMessage => '選択したコレクションは利用できません。';

  @override
  String get collectionDetailsCreatedLabel => '作成日';

  @override
  String get collectionDetailsUpdatedLabel => '最終更新';

  @override
  String get collectionDetailsLoading => 'コレクションを読み込み中...';

  @override
  String get collectionTypeBooks => '本';

  @override
  String get collectionTypeGames => 'ゲーム';

  @override
  String get collectionTypeMovies => '映画';

  @override
  String get collectionTypeComics => 'コミック';

  @override
  String get collectionTypeMusic => '音楽';

  @override
  String get collectionTypeCustom => 'カスタム';

  @override
  String get loanTrackingTitle => '貸出管理';

  @override
  String get loanTrackingNewLoan => '新しい貸出';

  @override
  String get loanTrackingFilterActive => 'アクティブ';

  @override
  String get loanTrackingFilterHistory => '履歴';

  @override
  String get loanTrackingEmptyHistoryTitle => '返却済みの貸出はまだありません';

  @override
  String get loanTrackingEmptyHistoryMessage => '返却されたアイテムはここに表示されます。';

  @override
  String get loanTrackingEmptyActiveTitle => 'アクティブな貸出はありません';

  @override
  String get loanTrackingEmptyActiveMessage => '貸出を作成して、借りられたアイテムの管理を始めましょう。';

  @override
  String get loanTrackingLoadingLoans => '貸出を読み込み中...';

  @override
  String loanTrackingLoadFailed(String error) {
    return '貸出の読み込みに失敗しました: $error';
  }

  @override
  String get loanTrackingMarkReturnedConfirmTitle => '返却済みにしますか？';

  @override
  String loanTrackingMarkReturnedConfirmMessage(String itemTitle) {
    return '\"$itemTitle\" の返却を確認します。';
  }

  @override
  String get loanTrackingMarkReturnedAction => '返却済みにする';

  @override
  String get loanTrackingMarkedReturnedSuccess => '貸出を返却済みにしました。';

  @override
  String loanTrackingMarkReturnedFailed(String error) {
    return '返却の更新に失敗しました: $error';
  }

  @override
  String get loanTrackingDeleteConfirmTitle => '貸出記録を削除しますか？';

  @override
  String loanTrackingDeleteConfirmMessage(String itemTitle) {
    return '\"$itemTitle\" の貸出記録を削除します。';
  }

  @override
  String get loanTrackingDeleteSuccess => '貸出記録を削除しました。';

  @override
  String loanTrackingDeleteFailed(String error) {
    return '貸出の削除に失敗しました: $error';
  }

  @override
  String get loanTrackingSummaryActiveLabel => 'アクティブな貸出';

  @override
  String get loanTrackingSummaryOverdueLabel => '期限超過';

  @override
  String get loanTrackingSummaryLoadFailed => '貸出サマリーを読み込めませんでした。';

  @override
  String get loanTrackingFieldBorrower => '借り手';

  @override
  String get loanTrackingFieldContact => '連絡先';

  @override
  String get loanTrackingFieldLoaned => '貸出日';

  @override
  String get loanTrackingFieldDue => '返却期限';

  @override
  String get loanTrackingFieldReturned => '返却日';

  @override
  String get loanTrackingStatusReturned => '返却済み';

  @override
  String get loanTrackingStatusOverdue => '期限超過';

  @override
  String get loanTrackingStatusActive => 'アクティブ';

  @override
  String get loanTrackingCreateTitle => '貸出を作成';

  @override
  String get loanTrackingCreateDescription => '誰がアイテムを借りたか、いつ返却予定かを記録します。';

  @override
  String get loanTrackingCreateNoItemsTitle => '利用可能なアイテムがありません';

  @override
  String get loanTrackingCreateNoItemsMessage => 'すべて貸出中か、まだアイテムがありません。';

  @override
  String get loanTrackingCreateItemLabel => 'アイテム';

  @override
  String get loanTrackingCreateBorrowerLabel => '借り手の名前';

  @override
  String get loanTrackingCreateBorrowerHint => '例: 山田 太郎';

  @override
  String get loanTrackingCreateContactLabel => '連絡先（任意）';

  @override
  String get loanTrackingCreateContactHint => '電話、メール、または @username';

  @override
  String get loanTrackingCreateNotesLabel => 'メモ（任意）';

  @override
  String get loanTrackingCreateNotesHint => 'この貸出の追加情報';

  @override
  String get loanTrackingCreateSubmitting => '作成中...';

  @override
  String get loanTrackingCreateAction => '貸出を作成';

  @override
  String get loanTrackingLoadingItems => 'アイテムを読み込み中...';

  @override
  String loanTrackingLoadItemsFailed(String error) {
    return 'アイテムの読み込みに失敗しました: $error';
  }

  @override
  String get loanTrackingBorrowerRequired => '借り手の名前は必須です。';

  @override
  String get loanTrackingCreateSuccess => '貸出を作成しました。';

  @override
  String loanTrackingCreateFailed(String error) {
    return '貸出の作成に失敗しました: $error';
  }

  @override
  String get loanTrackingNoDueDate => '返却期限なし';

  @override
  String get loanTrackingPickDateAction => '選択';

  @override
  String get loanTrackingClearDateAction => 'クリア';

  @override
  String get loanTrackingDueDateLabel => '返却期限';

  @override
  String get authTitleAccount => 'アカウント';

  @override
  String get authCreateAccountHeading => 'アカウント作成';

  @override
  String get authSignInHeading => 'サインイン';

  @override
  String get authCreateAccountDescription => 'アカウントを作成すると、コレクションを複数端末で同期できます。';

  @override
  String get authSignInDescription => 'サインインするとクラウド同期とアカウント機能を利用できます。';

  @override
  String get authSignInChoice => 'サインイン';

  @override
  String get authRegisterChoice => '登録';

  @override
  String get authEmailLabel => 'メールアドレス';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authEmailRequiredError => 'メールアドレスは必須です。';

  @override
  String get authEmailInvalidError => '有効なメールアドレスを入力してください。';

  @override
  String get authPasswordLabel => 'パスワード';

  @override
  String get authPasswordHint => '8文字以上、A-Z、a-z、0-9';

  @override
  String get authPasswordRequiredError => 'パスワードは必須です。';

  @override
  String get authPasswordLengthError => 'パスワードは8文字以上で入力してください。';

  @override
  String get authPasswordPolicyError => 'パスワードには大文字、小文字、数字を含めてください。';

  @override
  String get authDisplayNameLabel => '表示名（任意）';

  @override
  String get authDisplayNameHint => '呼び名を入力してください';

  @override
  String get authCreateAccountAction => 'アカウントを作成';

  @override
  String get authNotNowAction => '今はしない';

  @override
  String get authUnavailableMessage => '認証は現在利用できません。';

  @override
  String get authRegisterSuccess => 'アカウントを作成してサインインしました。';

  @override
  String get authSignInSuccess => 'サインインしました。';

  @override
  String authSignInFailed(String error) {
    return 'サインインに失敗しました: $error';
  }

  @override
  String get authSignedOut => 'サインアウトしました。';

  @override
  String get authFinalConfirmationTitle => '最終確認';

  @override
  String get authFinalConfirmationMessage => '今すぐアカウント削除リクエストを送信しますか？この端末では直ちにサインアウトされます。';

  @override
  String get authBackAction => '戻る';

  @override
  String get authSubmitRequestAction => 'リクエストを送信';

  @override
  String get authDeletionRequestSubmitted => 'アカウント削除リクエストを送信しました。サインアウトされました。';

  @override
  String get authDeletionEndpointMissing => '削除リクエストのエンドポイントがバックエンドにまだ設定されていません。';

  @override
  String get authDeletionImpactDialogTitle => 'アカウント削除をリクエストする前に';

  @override
  String get authDeletionImpactReviewPrompt => '影響をよくご確認ください。';

  @override
  String get authIrreversibleRequestTitle => '取り消し不可のリクエスト';

  @override
  String get authImpactLineSessionRevoked => 'リクエスト送信後、アカウントセッションはすぐに無効化されます。';

  @override
  String get authImpactLineCloudDataDeleted => 'このアカウントに紐づく同期済みクラウドデータは、処理中に完全削除される可能性があります。';

  @override
  String get authImpactLineCannotRestore => '削除されたアカウントデータは処理後に復元できません。';

  @override
  String get authUnderstandAction => '理解しました';

  @override
  String get authPasswordPolicySuffix => '英字キーボードの文字と数字（A-Z、a-z、0-9）を使用してください。';

  @override
  String get authAccountConnected => 'アカウント接続済み';

  @override
  String get authSignedInReadySubtitle => 'サインイン済みでクラウド同期の準備ができています';

  @override
  String get authActiveStatus => '有効';

  @override
  String get authSessionDetailsTitle => 'セッション詳細';

  @override
  String get authUserIdLabel => 'ユーザーID';

  @override
  String get authDeviceIdLabel => 'デバイスID';

  @override
  String get authUnknownValue => '不明';

  @override
  String get authDeletionNoticeTitle => 'アカウント削除に関する注意';

  @override
  String get authDeletionNoticeSubtitle => '削除リクエストは処理されると元に戻せません。';

  @override
  String get authDeletionNoticeLineProfileSessions => 'アカウントプロフィールと有効なセッションはクラウドアクセスから削除されます。';

  @override
  String get authDeletionNoticeLineSyncedData => '同期済みのコレクション、アイテム、タグ、貸出データは完全に削除される可能性があります。';

  @override
  String get authRequestDeletionAction => 'アカウント削除をリクエスト';

  @override
  String get authSignOutAction => 'サインアウト';

  @override
  String get authDoneAction => '完了';

  @override
  String get authHeaderCreateTitle => 'アカウントを作成';

  @override
  String get authHeaderWelcomeTitle => 'おかえりなさい';

  @override
  String get authHeaderCreateSubtitle => 'アカウントは任意ですが、クラウド同期と複数端末アクセスには必要です。';

  @override
  String get authHeaderSignInSubtitle => 'サインインしてクラウド同期とアカウント機能を利用しましょう。';

  @override
  String get authUnavailableTitle => '認証を利用できません';
}
