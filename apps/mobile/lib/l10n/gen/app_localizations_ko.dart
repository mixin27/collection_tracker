// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '컬렉션 트래커';

  @override
  String get navHome => '홈';

  @override
  String get navFavorites => '즐겨찾기';

  @override
  String get navWishlist => '위시리스트';

  @override
  String get navSettings => '설정';

  @override
  String get actionApply => '적용';

  @override
  String get actionCancel => '취소';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionDismiss => '닫기';

  @override
  String get actionEdit => '편집';

  @override
  String get actionImport => '가져오기';

  @override
  String get actionRefresh => '새로고침';

  @override
  String get actionReset => '초기화';

  @override
  String get actionSave => '저장';

  @override
  String get actionSwitchToGrid => '그리드 보기';

  @override
  String get actionSwitchToList => '목록 보기';

  @override
  String get actionUpdate => '업데이트';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionGeneral => '일반';

  @override
  String get settingsSectionData => '데이터';

  @override
  String get settingsSectionAbout => '정보';

  @override
  String get settingsSectionDeveloper => '개발자';

  @override
  String get settingsThemeTitle => '테마';

  @override
  String get settingsLanguageTitle => '언어';

  @override
  String get settingsExportJsonTitle => 'JSON 내보내기';

  @override
  String get settingsExportJsonSubtitle => '모든 데이터를 JSON 파일로 내보냅니다';

  @override
  String get settingsExportCsvTitle => 'CSV 내보내기';

  @override
  String get settingsExportCsvSubtitle => '항목을 CSV 스프레드시트로 내보냅니다';

  @override
  String get settingsImportJsonTitle => 'JSON 가져오기';

  @override
  String get settingsImportJsonSubtitle => 'JSON 파일에서 데이터를 가져옵니다';

  @override
  String get settingsCloudSyncTitle => '클라우드 동기화';

  @override
  String get settingsCloudSyncSubtitle => '설정되지 않음';

  @override
  String get settingsManageTagsTitle => '태그 관리';

  @override
  String get settingsManageTagsSubtitle => '태그 이름 변경, 병합, 삭제';

  @override
  String get settingsLoanTrackingTitle => '대여 추적';

  @override
  String get settingsLoanTrackingSubtitle => '대여한 항목과 반납 예정일을 추적합니다';

  @override
  String get settingsVersionTitle => '버전';

  @override
  String get settingsPrivacyPolicyTitle => '개인정보 처리방침';

  @override
  String get settingsTermsTitle => '이용 약관';

  @override
  String get settingsAnalyticsTitle => '분석';

  @override
  String get settingsAnalyticsSummaryEnabled => '활성화됨';

  @override
  String get settingsAnalyticsSummaryDisabled => '비활성화됨';

  @override
  String get settingsAnalyticsSummaryPending => '동의 필요';

  @override
  String get settingsAnalyticsSummaryDenied => '동의 거부';

  @override
  String get settingsAnalyticsSheetTitle => '분석 설정';

  @override
  String get settingsAnalyticsDescription => '익명 사용 분석 및 데이터 공유 설정을 관리합니다.';

  @override
  String get settingsAnalyticsToggleTitle => '분석 활성화';

  @override
  String get settingsAnalyticsToggleSubtitle => '익명 앱 사용 이벤트 수집을 허용합니다.';

  @override
  String get settingsAnalyticsConsentStatusTitle => '동의 상태';

  @override
  String get settingsAnalyticsConsentStatusGranted => '동의함';

  @override
  String get settingsAnalyticsConsentStatusDenied => '거부됨';

  @override
  String get settingsAnalyticsConsentStatusPending => '대기 중';

  @override
  String get settingsAnalyticsReviewConsentAction => '동의 다시 보기';

  @override
  String get settingsAnalyticsRevokeConsentAction => '동의 철회';

  @override
  String get settingsAnalyticsConsentAccepted => '분석 동의가 수락되었습니다.';

  @override
  String get settingsAnalyticsConsentDeclined => '분석 동의가 거부되었습니다.';

  @override
  String get analyticsConsentDialogTitle => 'Collection Tracker 개선에 도움을 주세요';

  @override
  String get analyticsConsentDialogMessage => '앱 품질과 기능 개선을 위해 익명 사용 분석을 수집해도 될까요? 이 설정은 언제든지 설정에서 변경할 수 있습니다.';

  @override
  String get analyticsConsentAllowAction => '허용';

  @override
  String get analyticsConsentDeclineAction => '나중에';

  @override
  String get settingsCrashlyticsTestTitle => 'Crashlytics 테스트';

  @override
  String get settingsCrashlyticsTestSubtitle => '크래시 보고 확인을 위해 앱을 의도적으로 종료합니다';

  @override
  String get settingsCrashlyticsTestConfirmTitle => '테스트 크래시를 실행할까요?';

  @override
  String get settingsCrashlyticsTestConfirmMessage => '앱이 즉시 종료됩니다. 앱을 다시 열어 Firebase Crashlytics에서 크래시를 확인하세요.';

  @override
  String get settingsCrashlyticsTestConfirmAction => '지금 크래시';

  @override
  String get settingsCrashlyticsTestTriggered => '테스트 크래시를 실행하는 중...';

  @override
  String settingsCrashlyticsTestFailed(String error) {
    return '테스트 크래시 실행 실패: $error';
  }

  @override
  String get settingsFirebaseRuntimeConfigTitle => 'Firebase 런타임 구성';

  @override
  String get settingsFirebaseRuntimeConfigSubtitle => '런타임 기능 플래그 확인 및 새로고침';

  @override
  String get settingsMetadataTitle => '메타데이터 및 자동완성';

  @override
  String get settingsMetadataSummaryEnabled => '자동 바코드 조회로 사용 중';

  @override
  String get settingsMetadataSummaryManual => '수동 조회로 사용 중';

  @override
  String get settingsMetadataSummaryDisabled => '사용 안 함';

  @override
  String get settingsMetadataSummaryFeatureDisabled => '런타임 기능 플래그로 비활성화됨';

  @override
  String get settingsMetadataEnableToggleTitle => '메타데이터 보조 사용';

  @override
  String get settingsMetadataEnableToggleSubtitle => '아이템 폼에서 메타데이터 검색과 바코드 자동완성을 허용합니다.';

  @override
  String get settingsMetadataAutoFetchToggleTitle => '바코드 스캔 시 자동 조회';

  @override
  String get settingsMetadataAutoFetchToggleSubtitle => '바코드를 스캔한 뒤 메타데이터를 자동으로 가져옵니다.';

  @override
  String get settingsMetadataFillEmptyOnlyToggleTitle => '빈 필드만 채우기';

  @override
  String get settingsMetadataFillEmptyOnlyToggleSubtitle => '메타데이터를 찾았을 때 기존 제목이나 설명을 덮어쓰지 않습니다.';

  @override
  String get settingsMetadataSourcesSectionTitle => '소스';

  @override
  String get settingsMetadataSourceAvailable => '사용 가능';

  @override
  String get settingsMetadataSourceNotConfigured => '미설정';

  @override
  String get settingsMetadataSourceManualOnly => '수동만';

  @override
  String get settingsMetadataManualCollectionsLabel => '코믹, 음악 및 사용자 지정';

  @override
  String get settingsMetadataFeatureDisabledMessage => '메타데이터 보조가 런타임 구성으로 비활성화되었습니다.';

  @override
  String get settingsFirebaseRuntimeConfigSheetTitle => 'Firebase 런타임 구성';

  @override
  String get settingsFirebaseRuntimeConfigDescription => '값은 Firebase Remote Config에서 가져와 런타임에 적용됩니다.';

  @override
  String settingsFirebaseRuntimeConfigSummary(int enabledCount) {
    return '3개 신호 중 $enabledCount개 활성화';
  }

  @override
  String get settingsFirebaseRuntimeConfigAnalyticsLabel => '애널리틱스 수집';

  @override
  String get settingsFirebaseRuntimeConfigCrashlyticsLabel => 'Crashlytics 수집';

  @override
  String get settingsFirebaseRuntimeConfigPerformanceLabel => '성능 수집';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusTitle => '마지막 가져오기 상태';

  @override
  String get settingsFirebaseRuntimeConfigLastFetchTitle => '마지막 가져오기 시간';

  @override
  String get settingsFirebaseRuntimeConfigValueEnabled => '사용';

  @override
  String get settingsFirebaseRuntimeConfigValueDisabled => '사용 안 함';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusSuccess => '성공';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusFailure => '실패';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusThrottled => '제한됨';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusNoFetch => '가져온 기록 없음';

  @override
  String get settingsFirebaseRuntimeConfigRefreshAction => '구성 새로고침';

  @override
  String get settingsFirebaseRuntimeConfigRefreshingAction => '새로고침 중...';

  @override
  String get settingsFirebaseRuntimeConfigRefreshSuccess => 'Firebase 런타임 구성을 새로고침했습니다.';

  @override
  String get settingsFirebaseRuntimeConfigRefreshNoChanges => 'Firebase 런타임 구성이 이미 최신입니다.';

  @override
  String settingsFirebaseRuntimeConfigRefreshFailed(String error) {
    return '구성 새로고침 실패: $error';
  }

  @override
  String get settingsExportingData => '데이터 내보내는 중...';

  @override
  String get settingsDataExportSuccess => '데이터 내보내기 완료!';

  @override
  String settingsExportFailed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String get settingsImportDataTitle => '데이터 가져오기';

  @override
  String get settingsImportDataMessage => 'JSON 파일에서 컬렉션과 항목을 가져옵니다. 기존 데이터는 삭제되지 않습니다.\n\n계속할까요?';

  @override
  String get settingsImportingData => '데이터 가져오는 중...';

  @override
  String get settingsDataImportSuccess => '데이터 가져오기 완료!';

  @override
  String settingsImportFailed(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String get settingsThemeModeTitle => '테마 모드';

  @override
  String get settingsThemeColorVariantTitle => '색상 테마';

  @override
  String get settingsAmoledTitle => '아몰레드 모드 (순수 블랙)';

  @override
  String get settingsAmoledSubtitle => 'OLED 화면에서 배터리 소모를 줄입니다';

  @override
  String get themeModeSystem => '시스템';

  @override
  String get themeModeLight => '라이트';

  @override
  String get themeModeDark => '다크';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get languageIndonesian => '인도네시아어';

  @override
  String get languageJapanese => '일본어';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageChineseSimplified => '중국어(간체)';

  @override
  String get languageBurmese => '버마어';

  @override
  String get collectionsTitle => '내 컬렉션';

  @override
  String get collectionsCountLabel => '컬렉션';

  @override
  String get collectionsNewButton => '새 컬렉션';

  @override
  String get collectionsActionsTooltip => '컬렉션 작업';

  @override
  String get collectionsOpenAction => '컬렉션 열기';

  @override
  String get collectionsEditAction => '컬렉션 편집';

  @override
  String get collectionsDeleteTitle => '컬렉션 삭제';

  @override
  String collectionsDeleteMessage(String name, int itemCount) {
    return '\"$name\" 컬렉션과 항목 $itemCount개를 삭제할까요?';
  }

  @override
  String collectionsDeleted(String name) {
    return '$name 삭제됨';
  }

  @override
  String collectionsErrorLoading(String error) {
    return '컬렉션 로드 오류: $error';
  }

  @override
  String get itemsTitle => '항목';

  @override
  String get itemsCountLabel => '항목';

  @override
  String itemsCountWithValue(int count) {
    return '$count개 항목';
  }

  @override
  String get itemsSearchHint => '항목 검색...';

  @override
  String get itemsNoMatchesTitle => '검색 결과 없음';

  @override
  String get itemsNoMatchesMessage => '필터나 키워드를 변경해 보세요.';

  @override
  String get itemsNoItemsTitle => '아직 항목이 없습니다';

  @override
  String get itemsNoItemsMessage => '첫 번째 항목을 추가해 보세요.';

  @override
  String get itemsAddButton => '항목 추가';

  @override
  String get itemsLoadingMessage => '항목 불러오는 중...';

  @override
  String itemsErrorLoading(String error) {
    return '항목 로드 오류: $error';
  }

  @override
  String get itemsDeleteTitle => '항목 삭제';

  @override
  String itemsDeleteMessage(String name) {
    return '\"$name\"을(를) 삭제할까요?';
  }

  @override
  String itemsDeleted(String name) {
    return '$name 삭제됨';
  }

  @override
  String itemsOverviewCount(int count) {
    return '$count개 항목';
  }

  @override
  String itemsSortedBy(String sortLabel) {
    return '정렬 기준: $sortLabel';
  }

  @override
  String get itemsCollectionDetailsTooltip => '컬렉션 상세';

  @override
  String get itemsFiltersTooltip => '필터';

  @override
  String get itemsFilterTitle => '항목 필터';

  @override
  String get itemsSortByTitle => '정렬 기준';

  @override
  String get itemsFilterFavoritesOnly => '즐겨찾기만';

  @override
  String get itemsFilterWishlistOnly => '위시리스트만';

  @override
  String get itemsFilterConditionsTitle => '상태';

  @override
  String get itemsTagsTitle => '태그';

  @override
  String itemsQuantityLabel(int quantity) {
    return '수량: $quantity';
  }

  @override
  String itemsQuantityShort(int quantity) {
    return 'x$quantity';
  }

  @override
  String get itemSortCustom => '사용자 지정 순서';

  @override
  String get itemSortTitle => '제목';

  @override
  String get itemSortCreatedAt => '추가일';

  @override
  String get itemSortPurchaseDate => '구매일';

  @override
  String get itemSortCurrentValue => '현재 가치';

  @override
  String get itemSortQuantity => '수량';

  @override
  String get itemConditionMint => '최상';

  @override
  String get itemConditionGood => '양호';

  @override
  String get itemConditionFair => '보통';

  @override
  String get itemConditionPoor => '불량';

  @override
  String get itemDetailNotFoundTitle => '항목을 찾을 수 없음';

  @override
  String get itemDetailNotFoundMessage => '이 항목은 더 이상 존재하지 않습니다.';

  @override
  String get itemDetailFavorited => '즐겨찾는 중';

  @override
  String get itemDetailFavorite => '즐겨찾기';

  @override
  String get itemDetailInWishlist => '위시리스트에 있음';

  @override
  String get itemDetailPriceTrackingTitle => '가격 추적';

  @override
  String get itemDetailNoValueMessage => '현재 가치가 없습니다';

  @override
  String get itemDetailNoHistoryMessage => '가격 이력이 없습니다';

  @override
  String get itemDetailPriceHistoryError => '가격 이력을 불러올 수 없습니다';

  @override
  String get itemDetailDetailsTitle => '상세 정보';

  @override
  String get itemDetailBarcodeLabel => '바코드';

  @override
  String get itemDetailConditionLabel => '상태';

  @override
  String get itemDetailQuantityLabel => '수량';

  @override
  String get itemDetailLocationLabel => '위치';

  @override
  String get itemDetailPurchasePriceLabel => '구매 가격';

  @override
  String get itemDetailCurrentValueLabel => '현재 가치';

  @override
  String get itemDetailPurchaseDateLabel => '구매일';

  @override
  String get itemDetailNotesTitle => '메모';

  @override
  String get itemDetailLoadingMessage => '항목 상세 불러오는 중...';

  @override
  String itemDetailErrorLoading(String error) {
    return '항목 상세 로드 오류: $error';
  }

  @override
  String get itemDetailUpdateValueTitle => '현재 가치 업데이트';

  @override
  String get itemDetailCurrentValueUpdated => '현재 가치가 업데이트되었습니다';

  @override
  String itemDetailUpdateValueFailed(String error) {
    return '가치 업데이트 실패: $error';
  }

  @override
  String get addItemTitle => '항목 추가';

  @override
  String get addItemSubmit => '항목 추가';

  @override
  String get addItemTitleHint => '예: 반지의 제왕';

  @override
  String get addItemFetchingMetadata => '메타데이터 가져오는 중...';

  @override
  String addItemMatchedMetadata(String source) {
    return '$source 메타데이터와 일치함';
  }

  @override
  String get addItemTagsHint => '예: 희귀, 완성 세트';

  @override
  String get addItemSuccess => '항목이 추가되었습니다';

  @override
  String addItemError(String error) {
    return '항목 추가 오류: $error';
  }

  @override
  String get editItemTitle => '항목 편집';

  @override
  String get editItemLoading => '항목 불러오는 중...';

  @override
  String editItemError(String error) {
    return '오류: $error';
  }

  @override
  String get editItemSaveChanges => '변경사항 저장';

  @override
  String get editItemTagsHint => '예: 친필 서명, 초판';

  @override
  String get editItemSuccess => '항목이 업데이트되었습니다';

  @override
  String editItemUpdateError(String error) {
    return '항목 업데이트 오류: $error';
  }

  @override
  String get itemFormTitleLabel => '제목';

  @override
  String get itemFormTitleRequired => '제목을 입력해 주세요';

  @override
  String get itemFormBarcodeLabelOptional => '바코드 (선택)';

  @override
  String get itemFormBarcodeHint => 'ISBN, UPC 등';

  @override
  String get itemFormDescriptionLabelOptional => '설명 (선택)';

  @override
  String get itemFormDescriptionHint => '설명을 입력하세요';

  @override
  String get itemFormTagsLabelOptional => '태그 (선택)';

  @override
  String get itemFormPurchaseDateLabelOptional => '구매일 (선택)';

  @override
  String get itemFormConditionLabelOptional => '상태 (선택)';

  @override
  String get itemFormQuantityRequired => '수량을 입력해 주세요';

  @override
  String get itemFormQuantityInvalid => '올바른 수량을 입력해 주세요';

  @override
  String get itemFormLocationLabelOptional => '위치 (선택)';

  @override
  String get itemFormLocationHint => '예: 선반 A, 박스 3';

  @override
  String get itemFormNotesLabelOptional => '메모 (선택)';

  @override
  String get itemFormInvalidPrice => '잘못된 가격입니다';

  @override
  String get itemFormMustBePositive => '0 이상이어야 합니다';

  @override
  String get itemTagsEditorHint => '태그 추가';

  @override
  String get itemTagsEditorAddTooltip => '태그 추가';

  @override
  String get itemTagsEditorEmptyMessage => '아직 태그가 없습니다. 태그를 추가해 항목을 더 빠르게 정리하세요.';

  @override
  String get itemTagsEditorTooLong => '태그는 50자 이하여야 합니다';

  @override
  String get globalItemsLoading => '항목 불러오는 중...';

  @override
  String globalItemsErrorLoading(String error) {
    return '오류: $error';
  }

  @override
  String get globalItemsNoFavoritesTitle => '즐겨찾기 항목이 없습니다';

  @override
  String get globalItemsNoFavoritesMessage => '항목을 즐겨찾기로 표시하면 여기에 표시됩니다.';

  @override
  String get globalItemsNoWishlistTitle => '위시리스트가 비어 있습니다';

  @override
  String get globalItemsNoWishlistMessage => '항목을 위시리스트에 저장하면 여기에 표시됩니다.';

  @override
  String metadataSearchFieldLabel(String collectionType) {
    return '$collectionType 제목으로 검색';
  }

  @override
  String get metadataSearchEmptyTitle => '메타데이터 검색';

  @override
  String get metadataSearchEmptyMessage => '검색할 제목을 입력하세요.';

  @override
  String get metadataSearchLoading => '메타데이터 검색 중...';

  @override
  String metadataSearchError(String error) {
    return '오류: $error';
  }

  @override
  String get metadataSearchNoResultsTitle => '결과 없음';

  @override
  String get metadataSearchNoResultsMessage => '이 제목의 메타데이터를 찾지 못했습니다.';

  @override
  String get metadataSearchSuggestionTitle => '제목으로 검색';

  @override
  String get metadataSearchSuggestionMessage => '메타데이터를 찾으려면 입력하세요.';

  @override
  String get metadataSearchDisabledHint => '이 컬렉션 유형에서는 메타데이터 검색을 사용할 수 없거나 현재 비활성화되어 있습니다.';

  @override
  String get metadataNoMatchForBarcode => '이 바코드와 일치하는 메타데이터를 찾지 못했습니다.';

  @override
  String metadataSearchUnavailableForType(String collectionType) {
    return '$collectionType에는 메타데이터 검색을 사용할 수 없습니다.';
  }

  @override
  String tagItemsTitle(String tag) {
    return '태그: $tag';
  }

  @override
  String get tagItemsSortTooltip => '정렬';

  @override
  String get tagItemsSortNewest => '정렬: 최신순';

  @override
  String get tagItemsSortOldest => '정렬: 오래된순';

  @override
  String get tagItemsSortTitle => '정렬: 제목순';

  @override
  String get tagItemsLoadingCollections => '컬렉션 불러오는 중...';

  @override
  String get tagItemsLoadingItems => '태그된 항목 불러오는 중...';

  @override
  String tagItemsError(String error) {
    return '오류: $error';
  }

  @override
  String get tagItemsEmptyTitle => '항목이 없습니다';

  @override
  String get tagItemsEmptyMessage => '현재 이 태그를 사용하는 컬렉션 항목이 없습니다.';

  @override
  String get tagItemsUnknownCollection => '알 수 없음';

  @override
  String get tagItemsOpenCollectionTooltip => '컬렉션 열기';

  @override
  String tagItemsDeleteFailed(String error) {
    return '삭제 실패: $error';
  }

  @override
  String get tagManagementTitle => '태그 관리';

  @override
  String tagManagementSelectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String get tagManagementCancelSelectionTooltip => '선택 취소';

  @override
  String get tagManagementSelectTagsTooltip => '태그 선택';

  @override
  String get tagManagementSearchHint => '태그 검색...';

  @override
  String get tagManagementEmptyTitle => '생성된 태그가 없습니다';

  @override
  String tagManagementNoMatch(String query) {
    return '\"$query\"에 일치하는 태그가 없습니다';
  }

  @override
  String get tagManagementSelectVisible => '표시 항목 선택';

  @override
  String get tagManagementSelectAllMatches => '일치 항목 모두 선택';

  @override
  String get tagManagementClearSelection => '선택 해제';

  @override
  String tagManagementScrollMore(int remaining) {
    return '스크롤하여 태그 $remaining개 더 불러오기';
  }

  @override
  String get tagManagementUsedInOne => '1개 항목에서 사용됨';

  @override
  String tagManagementUsedInMany(int count) {
    return '$count개 항목에서 사용됨';
  }

  @override
  String get tagManagementRenameAction => '이름 변경';

  @override
  String get tagManagementMergeAction => '병합';

  @override
  String get tagManagementMergeIntoAction => '다음으로 병합...';

  @override
  String tagManagementLoadError(String error) {
    return '태그를 불러오지 못했습니다: $error';
  }

  @override
  String get tagManagementRenameTitle => '태그 이름 변경';

  @override
  String get tagManagementNewNameLabel => '새 이름';

  @override
  String tagManagementRenameSuccess(String oldName, String newName) {
    return '\"$oldName\"이(가) \"$newName\"(으)로 변경되었습니다';
  }

  @override
  String get tagManagementMergeSelectedTitle => '선택한 태그 병합';

  @override
  String get tagManagementChooseDestination => '대상 태그를 선택하세요:';

  @override
  String tagManagementMergeSelectedSuccess(int count, String destination) {
    return '$count개 태그를 \"$destination\"(으)로 병합했습니다';
  }

  @override
  String get tagManagementDeleteSelectedTitle => '선택한 태그 삭제';

  @override
  String tagManagementDeleteSelectedMessage(int count) {
    return '모든 항목에서 선택한 태그 $count개를 삭제할까요?\n\n이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String tagManagementDeleteSelectedSuccess(int count) {
    return '태그 $count개를 삭제했습니다';
  }

  @override
  String get tagManagementMergeIntoTitle => '다음으로 병합';

  @override
  String tagManagementMergeSuccess(String source, String target) {
    return '\"$source\"을(를) \"$target\"(으)로 병합했습니다';
  }

  @override
  String get tagManagementDeleteTitle => '태그 삭제';

  @override
  String tagManagementDeleteMessage(String tagName) {
    return '모든 항목에서 \"$tagName\"을(를) 삭제할까요?\n\n이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String tagManagementDeleteSuccess(String tagName) {
    return '\"$tagName\"을(를) 삭제했습니다';
  }

  @override
  String tagManagementMutationError(String error) {
    return '태그 업데이트 실패: $error';
  }

  @override
  String get statisticsTitle => '통계';

  @override
  String get statisticsEmptyTitle => '아직 통계가 없습니다';

  @override
  String get statisticsEmptyMessage => '컬렉션과 항목을 추가하면 인사이트를 볼 수 있습니다.';

  @override
  String get statisticsLoadingMessage => '통계 불러오는 중...';

  @override
  String statisticsErrorLoading(String error) {
    return '통계 로드 오류: $error';
  }

  @override
  String get statisticsPortfolioValueTitle => '포트폴리오 가치';

  @override
  String statisticsAveragePricedItem(String value) {
    return '평균 가격 항목: $value';
  }

  @override
  String statisticsPricedItemsBadge(int priced, int total) {
    return '가격 입력 항목: $priced/$total';
  }

  @override
  String get statisticsQuantityTitle => '총 수량';

  @override
  String get statisticsFavoritesTitle => '즐겨찾기';

  @override
  String statisticsPercentOfItems(String percent) {
    return '전체 항목의 $percent%';
  }

  @override
  String get statisticsInventoryHealthTitle => '인벤토리 상태';

  @override
  String get statisticsValuationCoverageLabel => '가치 입력 비율';

  @override
  String statisticsPricedCaption(int priced, int total) {
    return '$priced/$total 항목에 가격이 있습니다';
  }

  @override
  String get statisticsFavoritesCoverageLabel => '즐겨찾기 비율';

  @override
  String statisticsFavoritesCaption(int favorites, int total) {
    return '$favorites/$total 항목이 즐겨찾기입니다';
  }

  @override
  String get statisticsWishlistCoverageLabel => '위시리스트 비율';

  @override
  String statisticsWishlistCaption(int wishlist, int total) {
    return '$wishlist/$total 항목이 위시리스트입니다';
  }

  @override
  String get statisticsItemsByTypeTitle => '유형별 항목';

  @override
  String get statisticsItemsByConditionTitle => '상태별 항목';

  @override
  String get statisticsTopValuedTitle => '가치가 높은 컬렉션';

  @override
  String get statisticsLargestCollectionTitle => '가장 큰 컬렉션';

  @override
  String get statisticsRecentlyCreatedTitle => '최근 생성';

  @override
  String statisticsRecentCollectionSubtitle(int itemCount, String createdAt) {
    return '$itemCount개 항목 • $createdAt';
  }

  @override
  String get statisticsNoChartData => '차트 데이터가 없습니다';

  @override
  String get statisticsTotalLabel => '합계';

  @override
  String get relativeToday => '오늘';

  @override
  String get relativeYesterday => '어제';

  @override
  String relativeDaysAgo(int days) {
    return '$days일 전';
  }

  @override
  String relativeWeeksAgo(int weeks) {
    return '$weeks주 전';
  }

  @override
  String relativeMonthsAgo(int months) {
    return '$months개월 전';
  }

  @override
  String relativeYearsAgo(int years) {
    return '$years년 전';
  }

  @override
  String get collectionDetailsNotFoundTitle => '컬렉션을 찾을 수 없음';

  @override
  String get collectionDetailsNotFoundMessage => '선택한 컬렉션을 사용할 수 없습니다.';

  @override
  String get collectionDetailsCreatedLabel => '생성일';

  @override
  String get collectionDetailsUpdatedLabel => '최근 업데이트';

  @override
  String get collectionDetailsLoading => '컬렉션 불러오는 중...';

  @override
  String get collectionTypeBooks => '도서';

  @override
  String get collectionTypeGames => '게임';

  @override
  String get collectionTypeMovies => '영화';

  @override
  String get collectionTypeComics => '만화';

  @override
  String get collectionTypeMusic => '음악';

  @override
  String get collectionTypeCustom => '사용자 지정';

  @override
  String get loanTrackingTitle => '대여 추적';

  @override
  String get loanTrackingNewLoan => '새 대여';

  @override
  String get loanTrackingFilterActive => '활성';

  @override
  String get loanTrackingFilterHistory => '기록';

  @override
  String get loanTrackingEmptyHistoryTitle => '아직 반납된 대여가 없습니다';

  @override
  String get loanTrackingEmptyHistoryMessage => '반납된 항목이 여기에 표시됩니다.';

  @override
  String get loanTrackingEmptyActiveTitle => '활성 대여가 없습니다';

  @override
  String get loanTrackingEmptyActiveMessage => '대여를 생성해 빌려준 항목을 추적해 보세요.';

  @override
  String get loanTrackingLoadingLoans => '대여 불러오는 중...';

  @override
  String loanTrackingLoadFailed(String error) {
    return '대여를 불러오지 못했습니다: $error';
  }

  @override
  String get loanTrackingMarkReturnedConfirmTitle => '반납으로 표시할까요?';

  @override
  String loanTrackingMarkReturnedConfirmMessage(String itemTitle) {
    return '\"$itemTitle\" 반납을 확인합니다.';
  }

  @override
  String get loanTrackingMarkReturnedAction => '반납 처리';

  @override
  String get loanTrackingMarkedReturnedSuccess => '대여가 반납 처리되었습니다.';

  @override
  String loanTrackingMarkReturnedFailed(String error) {
    return '반납 처리에 실패했습니다: $error';
  }

  @override
  String get loanTrackingDeleteConfirmTitle => '대여 기록을 삭제할까요?';

  @override
  String loanTrackingDeleteConfirmMessage(String itemTitle) {
    return '\"$itemTitle\" 대여 기록을 삭제합니다.';
  }

  @override
  String get loanTrackingDeleteSuccess => '대여가 삭제되었습니다.';

  @override
  String loanTrackingDeleteFailed(String error) {
    return '대여 삭제에 실패했습니다: $error';
  }

  @override
  String get loanTrackingSummaryActiveLabel => '활성 대여';

  @override
  String get loanTrackingSummaryOverdueLabel => '연체';

  @override
  String get loanTrackingSummaryLoadFailed => '대여 요약을 불러올 수 없습니다.';

  @override
  String get loanTrackingFieldBorrower => '대여자';

  @override
  String get loanTrackingFieldContact => '연락처';

  @override
  String get loanTrackingFieldLoaned => '대여일';

  @override
  String get loanTrackingFieldDue => '반납 예정일';

  @override
  String get loanTrackingFieldReturned => '반납일';

  @override
  String get loanTrackingStatusReturned => '반납됨';

  @override
  String get loanTrackingStatusOverdue => '연체';

  @override
  String get loanTrackingStatusActive => '활성';

  @override
  String get loanTrackingCreateTitle => '대여 생성';

  @override
  String get loanTrackingCreateDescription => '누가 항목을 빌렸는지와 반납 예정일을 추적합니다.';

  @override
  String get loanTrackingCreateNoItemsTitle => '사용 가능한 항목이 없습니다';

  @override
  String get loanTrackingCreateNoItemsMessage => '모든 항목이 이미 대여 중이거나 아직 항목이 없습니다.';

  @override
  String get loanTrackingCreateItemLabel => '항목';

  @override
  String get loanTrackingCreateBorrowerLabel => '대여자 이름';

  @override
  String get loanTrackingCreateBorrowerHint => '예: 홍길동';

  @override
  String get loanTrackingCreateContactLabel => '연락처 (선택)';

  @override
  String get loanTrackingCreateContactHint => '전화번호, 이메일 또는 @username';

  @override
  String get loanTrackingCreateNotesLabel => '메모 (선택)';

  @override
  String get loanTrackingCreateNotesHint => '이 대여에 대한 추가 정보';

  @override
  String get loanTrackingCreateSubmitting => '생성 중...';

  @override
  String get loanTrackingCreateAction => '대여 생성';

  @override
  String get loanTrackingLoadingItems => '항목 불러오는 중...';

  @override
  String loanTrackingLoadItemsFailed(String error) {
    return '항목을 불러오지 못했습니다: $error';
  }

  @override
  String get loanTrackingBorrowerRequired => '대여자 이름은 필수입니다.';

  @override
  String get loanTrackingCreateSuccess => '대여가 생성되었습니다.';

  @override
  String loanTrackingCreateFailed(String error) {
    return '대여 생성에 실패했습니다: $error';
  }

  @override
  String get loanTrackingNoDueDate => '반납 예정일 없음';

  @override
  String get loanTrackingPickDateAction => '선택';

  @override
  String get loanTrackingClearDateAction => '지우기';

  @override
  String get loanTrackingDueDateLabel => '반납 예정일';

  @override
  String get authTitleAccount => '계정';

  @override
  String get authCreateAccountHeading => '계정 만들기';

  @override
  String get authSignInHeading => '로그인';

  @override
  String get authCreateAccountDescription => '계정을 만들어 컬렉션을 여러 기기에서 동기화하세요.';

  @override
  String get authSignInDescription => '로그인하면 클라우드 동기화와 계정 기능을 사용할 수 있습니다.';

  @override
  String get authSignInChoice => '로그인';

  @override
  String get authRegisterChoice => '회원가입';

  @override
  String get authEmailLabel => '이메일';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authEmailRequiredError => '이메일은 필수입니다.';

  @override
  String get authEmailInvalidError => '유효한 이메일을 입력하세요.';

  @override
  String get authPasswordLabel => '비밀번호';

  @override
  String get authPasswordHint => '최소 8자, A-Z, a-z, 0-9';

  @override
  String get authPasswordRequiredError => '비밀번호는 필수입니다.';

  @override
  String get authPasswordLengthError => '비밀번호는 최소 8자 이상이어야 합니다.';

  @override
  String get authPasswordPolicyError => '비밀번호에는 대문자, 소문자, 숫자가 포함되어야 합니다.';

  @override
  String get authDisplayNameLabel => '표시 이름 (선택)';

  @override
  String get authDisplayNameHint => '어떻게 불러드릴까요?';

  @override
  String get authCreateAccountAction => '계정 만들기';

  @override
  String get authNotNowAction => '나중에';

  @override
  String get authUnavailableMessage => '현재 인증을 사용할 수 없습니다.';

  @override
  String get authRegisterSuccess => '계정이 생성되었고 로그인되었습니다.';

  @override
  String get authSignInSuccess => '로그인되었습니다.';

  @override
  String authSignInFailed(String error) {
    return '로그인 실패: $error';
  }

  @override
  String get authSignedOut => '로그아웃되었습니다.';

  @override
  String get authFinalConfirmationTitle => '최종 확인';

  @override
  String get authFinalConfirmationMessage => '지금 계정 삭제 요청을 제출할까요? 이 기기에서 즉시 로그아웃됩니다.';

  @override
  String get authBackAction => '뒤로';

  @override
  String get authSubmitRequestAction => '요청 제출';

  @override
  String get authDeletionRequestSubmitted => '계정 삭제 요청이 제출되었습니다. 로그아웃되었습니다.';

  @override
  String get authDeletionEndpointMissing => '계정 삭제 요청 엔드포인트가 아직 백엔드에 구성되지 않았습니다.';

  @override
  String get authDeletionImpactDialogTitle => '계정 삭제를 요청하기 전에';

  @override
  String get authDeletionImpactReviewPrompt => '영향을 신중히 확인해 주세요.';

  @override
  String get authIrreversibleRequestTitle => '되돌릴 수 없는 요청';

  @override
  String get authImpactLineSessionRevoked => '요청 즉시 계정 세션이 취소됩니다.';

  @override
  String get authImpactLineCloudDataDeleted => '이 계정과 연결된 동기화 클라우드 데이터는 처리 중 영구 삭제될 수 있습니다.';

  @override
  String get authImpactLineCannotRestore => '삭제된 계정 데이터는 처리 후 복구할 수 없습니다.';

  @override
  String get authUnderstandAction => '이해했습니다';

  @override
  String get authPasswordPolicySuffix => '영문 키보드 문자와 숫자(A-Z, a-z, 0-9)를 사용하세요.';

  @override
  String get authAccountConnected => '계정 연결됨';

  @override
  String get authSignedInReadySubtitle => '로그인되어 클라우드 동기화 준비 완료';

  @override
  String get authActiveStatus => '활성';

  @override
  String get authSessionDetailsTitle => '세션 정보';

  @override
  String get authUserIdLabel => '사용자 ID';

  @override
  String get authDeviceIdLabel => '기기 ID';

  @override
  String get authUnknownValue => '알 수 없음';

  @override
  String get authDeletionNoticeTitle => '계정 삭제 안내';

  @override
  String get authDeletionNoticeSubtitle => '삭제 요청은 처리되면 되돌릴 수 없습니다.';

  @override
  String get authDeletionNoticeLineProfileSessions => '계정 프로필과 활성 세션은 클라우드 접근에서 제거됩니다.';

  @override
  String get authDeletionNoticeLineSyncedData => '동기화된 컬렉션, 항목, 태그, 대여 데이터가 영구 삭제될 수 있습니다.';

  @override
  String get authRequestDeletionAction => '계정 삭제 요청';

  @override
  String get authSignOutAction => '로그아웃';

  @override
  String get authDoneAction => '완료';

  @override
  String get authHeaderCreateTitle => '계정을 만들어 보세요';

  @override
  String get authHeaderWelcomeTitle => '다시 오신 것을 환영합니다';

  @override
  String get authHeaderCreateSubtitle => '계정은 선택 사항이지만 클라우드 동기화와 다중 기기 접근에 필요합니다.';

  @override
  String get authHeaderSignInSubtitle => '로그인하여 클라우드 동기화와 계정 기능을 사용하세요.';

  @override
  String get authUnavailableTitle => '인증을 사용할 수 없음';
}
