// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Collection Tracker';

  @override
  String get navHome => 'Beranda';

  @override
  String get navFavorites => 'Favorit';

  @override
  String get navWishlist => 'Wishlist';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionDelete => 'Hapus';

  @override
  String get actionDismiss => 'Tutup';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionImport => 'Impor';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSwitchToGrid => 'Ubah ke grid';

  @override
  String get actionSwitchToList => 'Ubah ke daftar';

  @override
  String get actionUpdate => 'Update';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsSectionGeneral => 'Umum';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsSectionAbout => 'Tentang';

  @override
  String get settingsSectionDeveloper => 'Pengembang';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get settingsLanguageTitle => 'Bahasa';

  @override
  String get settingsExportJsonTitle => 'Ekspor ke JSON';

  @override
  String get settingsExportJsonSubtitle => 'Ekspor semua data sebagai file JSON';

  @override
  String get settingsExportCsvTitle => 'Ekspor ke CSV';

  @override
  String get settingsExportCsvSubtitle => 'Ekspor item sebagai lembar CSV';

  @override
  String get settingsImportJsonTitle => 'Impor dari JSON';

  @override
  String get settingsImportJsonSubtitle => 'Impor data dari file JSON';

  @override
  String get settingsCloudSyncTitle => 'Sinkronisasi Cloud';

  @override
  String get settingsCloudSyncSubtitle => 'Belum dikonfigurasi';

  @override
  String get settingsManageTagsTitle => 'Kelola Tag';

  @override
  String get settingsManageTagsSubtitle => 'Ubah nama, gabungkan, dan hapus tag';

  @override
  String get settingsLoanTrackingTitle => 'Pelacakan Pinjaman';

  @override
  String get settingsLoanTrackingSubtitle => 'Lacak item yang dipinjam dan tanggal pengembalian';

  @override
  String get settingsVersionTitle => 'Versi';

  @override
  String get settingsPrivacyPolicyTitle => 'Kebijakan Privasi';

  @override
  String get settingsTermsTitle => 'Ketentuan Layanan';

  @override
  String get settingsAnalyticsTitle => 'Analitik';

  @override
  String get settingsAnalyticsSummaryEnabled => 'Aktif';

  @override
  String get settingsAnalyticsSummaryDisabled => 'Nonaktif';

  @override
  String get settingsAnalyticsSummaryPending => 'Perlu persetujuan';

  @override
  String get settingsAnalyticsSummaryDenied => 'Persetujuan ditolak';

  @override
  String get settingsAnalyticsSheetTitle => 'Preferensi Analitik';

  @override
  String get settingsAnalyticsDescription => 'Atur analitik penggunaan anonim dan preferensi berbagi data.';

  @override
  String get settingsAnalyticsToggleTitle => 'Aktifkan analitik';

  @override
  String get settingsAnalyticsToggleSubtitle => 'Izinkan pengumpulan event penggunaan aplikasi secara anonim.';

  @override
  String get settingsAnalyticsConsentStatusTitle => 'Status persetujuan';

  @override
  String get settingsAnalyticsConsentStatusGranted => 'Disetujui';

  @override
  String get settingsAnalyticsConsentStatusDenied => 'Ditolak';

  @override
  String get settingsAnalyticsConsentStatusPending => 'Menunggu';

  @override
  String get settingsAnalyticsReviewConsentAction => 'Tinjau Persetujuan';

  @override
  String get settingsAnalyticsRevokeConsentAction => 'Cabut Persetujuan';

  @override
  String get settingsAnalyticsConsentAccepted => 'Persetujuan analitik diterima.';

  @override
  String get settingsAnalyticsConsentDeclined => 'Persetujuan analitik ditolak.';

  @override
  String get analyticsConsentDialogTitle => 'Bantu Tingkatkan Collection Tracker';

  @override
  String get analyticsConsentDialogMessage => 'Bolehkah kami mengumpulkan analitik penggunaan anonim untuk meningkatkan kualitas dan fitur aplikasi? Anda dapat mengubahnya kapan saja di Pengaturan.';

  @override
  String get analyticsConsentAllowAction => 'Izinkan';

  @override
  String get analyticsConsentDeclineAction => 'Nanti saja';

  @override
  String get settingsCrashlyticsTestTitle => 'Uji Crashlytics';

  @override
  String get settingsCrashlyticsTestSubtitle => 'Sengaja membuat aplikasi crash untuk memverifikasi pelaporan crash';

  @override
  String get settingsCrashlyticsTestConfirmTitle => 'Picu crash uji coba?';

  @override
  String get settingsCrashlyticsTestConfirmMessage => 'Aplikasi akan langsung crash. Buka kembali aplikasi untuk memverifikasi crash di Firebase Crashlytics.';

  @override
  String get settingsCrashlyticsTestConfirmAction => 'Crash Sekarang';

  @override
  String get settingsCrashlyticsTestTriggered => 'Memicu crash uji coba...';

  @override
  String settingsCrashlyticsTestFailed(String error) {
    return 'Gagal memicu uji crash: $error';
  }

  @override
  String get settingsFirebaseRuntimeConfigTitle => 'Konfigurasi Runtime Firebase';

  @override
  String get settingsFirebaseRuntimeConfigSubtitle => 'Periksa dan segarkan flag fitur runtime';

  @override
  String get settingsMetadataTitle => 'Metadata & Isi Otomatis';

  @override
  String get settingsMetadataSummaryEnabled => 'Aktif dengan pencarian barcode otomatis';

  @override
  String get settingsMetadataSummaryManual => 'Aktif dengan pencarian manual';

  @override
  String get settingsMetadataSummaryDisabled => 'Nonaktif';

  @override
  String get settingsMetadataSummaryFeatureDisabled => 'Dinonaktifkan oleh flag fitur runtime';

  @override
  String get settingsMetadataEnableToggleTitle => 'Aktifkan bantuan metadata';

  @override
  String get settingsMetadataEnableToggleSubtitle => 'Izinkan pencarian metadata dan isi otomatis berbasis barcode pada formulir item.';

  @override
  String get settingsMetadataAutoFetchToggleTitle => 'Ambil otomatis saat barcode dipindai';

  @override
  String get settingsMetadataAutoFetchToggleSubtitle => 'Setelah barcode dipindai, metadata diambil secara otomatis.';

  @override
  String get settingsMetadataFillEmptyOnlyToggleTitle => 'Isi hanya kolom kosong';

  @override
  String get settingsMetadataFillEmptyOnlyToggleSubtitle => 'Jangan menimpa judul atau deskripsi yang sudah ada saat metadata ditemukan.';

  @override
  String get settingsMetadataSourcesSectionTitle => 'Sumber';

  @override
  String get settingsMetadataSourceAvailable => 'Tersedia';

  @override
  String get settingsMetadataSourceNotConfigured => 'Belum dikonfigurasi';

  @override
  String get settingsMetadataSourceManualOnly => 'Manual saja';

  @override
  String get settingsMetadataManualCollectionsLabel => 'Komik, Musik, dan Kustom';

  @override
  String get settingsMetadataFeatureDisabledMessage => 'Bantuan metadata dinonaktifkan oleh konfigurasi runtime.';

  @override
  String get settingsFirebaseRuntimeConfigSheetTitle => 'Konfigurasi Runtime Firebase';

  @override
  String get settingsFirebaseRuntimeConfigDescription => 'Nilai diambil dari Firebase Remote Config dan diterapkan saat runtime.';

  @override
  String settingsFirebaseRuntimeConfigSummary(int enabledCount) {
    return '$enabledCount dari 3 sinyal aktif';
  }

  @override
  String get settingsFirebaseRuntimeConfigAnalyticsLabel => 'Pengumpulan analitik';

  @override
  String get settingsFirebaseRuntimeConfigCrashlyticsLabel => 'Pengumpulan Crashlytics';

  @override
  String get settingsFirebaseRuntimeConfigPerformanceLabel => 'Pengumpulan performa';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusTitle => 'Status pengambilan terakhir';

  @override
  String get settingsFirebaseRuntimeConfigLastFetchTitle => 'Waktu pengambilan terakhir';

  @override
  String get settingsFirebaseRuntimeConfigValueEnabled => 'Aktif';

  @override
  String get settingsFirebaseRuntimeConfigValueDisabled => 'Nonaktif';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusSuccess => 'Berhasil';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusFailure => 'Gagal';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusThrottled => 'Dibatasi';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusNoFetch => 'Belum pernah diambil';

  @override
  String get settingsFirebaseRuntimeConfigRefreshAction => 'Segarkan konfigurasi';

  @override
  String get settingsFirebaseRuntimeConfigRefreshingAction => 'Menyegarkan...';

  @override
  String get settingsFirebaseRuntimeConfigRefreshSuccess => 'Konfigurasi runtime Firebase diperbarui.';

  @override
  String get settingsFirebaseRuntimeConfigRefreshNoChanges => 'Konfigurasi runtime Firebase sudah terbaru.';

  @override
  String settingsFirebaseRuntimeConfigRefreshFailed(String error) {
    return 'Gagal menyegarkan konfigurasi: $error';
  }

  @override
  String get settingsExportingData => 'Mengekspor data...';

  @override
  String get settingsDataExportSuccess => 'Data berhasil diekspor!';

  @override
  String settingsExportFailed(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String get settingsImportDataTitle => 'Impor Data';

  @override
  String get settingsImportDataMessage => 'Ini akan mengimpor koleksi dan item dari file JSON. Data yang sudah ada tidak akan dihapus.\\n\\nLanjutkan?';

  @override
  String get settingsImportingData => 'Mengimpor data...';

  @override
  String get settingsDataImportSuccess => 'Data berhasil diimpor!';

  @override
  String settingsImportFailed(String error) {
    return 'Impor gagal: $error';
  }

  @override
  String get settingsThemeModeTitle => 'Mode Tema';

  @override
  String get settingsThemeColorVariantTitle => 'Varian Warna';

  @override
  String get settingsAmoledTitle => 'Mode Amoled (Hitam Pekat)';

  @override
  String get settingsAmoledSubtitle => 'Mengurangi konsumsi baterai pada layar OLED';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeModeLight => 'Terang';

  @override
  String get themeModeDark => 'Gelap';

  @override
  String get languageSystem => 'Ikuti Sistem';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageSpanish => 'Spanyol';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageJapanese => 'Jepang';

  @override
  String get languageKorean => 'Bahasa Korea';

  @override
  String get languageChineseSimplified => 'Tionghoa Sederhana';

  @override
  String get languageBurmese => 'Burma';

  @override
  String get collectionsTitle => 'Koleksi Saya';

  @override
  String get collectionsCountLabel => 'Koleksi';

  @override
  String get collectionsNewButton => 'Koleksi Baru';

  @override
  String get collectionsActionsTooltip => 'Aksi koleksi';

  @override
  String get collectionsOpenAction => 'Buka koleksi';

  @override
  String get collectionsEditAction => 'Edit koleksi';

  @override
  String get collectionsDeleteTitle => 'Hapus Koleksi';

  @override
  String collectionsDeleteMessage(String name, int itemCount) {
    return 'Hapus \"$name\" dan $itemCount item di koleksi ini?';
  }

  @override
  String collectionsDeleted(String name) {
    return '$name dihapus';
  }

  @override
  String collectionsErrorLoading(String error) {
    return 'Error loading collections: $error';
  }

  @override
  String get itemsTitle => 'Item';

  @override
  String get itemsCountLabel => 'Item';

  @override
  String itemsCountWithValue(int count) {
    return '$count item';
  }

  @override
  String get itemsSearchHint => 'Cari item...';

  @override
  String get itemsNoMatchesTitle => 'Tidak ada hasil';

  @override
  String get itemsNoMatchesMessage => 'Coba ubah filter atau kata kunci.';

  @override
  String get itemsNoItemsTitle => 'Belum ada item';

  @override
  String get itemsNoItemsMessage => 'Mulai dengan menambahkan item pertamamu.';

  @override
  String get itemsAddButton => 'Tambah Item';

  @override
  String get itemsLoadingMessage => 'Memuat item...';

  @override
  String itemsErrorLoading(String error) {
    return 'Gagal memuat item: $error';
  }

  @override
  String get itemsDeleteTitle => 'Hapus Item';

  @override
  String itemsDeleteMessage(String name) {
    return 'Hapus \"$name\"?';
  }

  @override
  String itemsDeleted(String name) {
    return '$name dihapus';
  }

  @override
  String itemsOverviewCount(int count) {
    return '$count item';
  }

  @override
  String itemsSortedBy(String sortLabel) {
    return 'Diurutkan berdasarkan $sortLabel';
  }

  @override
  String get itemsCollectionDetailsTooltip => 'Detail koleksi';

  @override
  String get itemsFiltersTooltip => 'Filter';

  @override
  String get itemsFilterTitle => 'Filter Item';

  @override
  String get itemsSortByTitle => 'Urutkan berdasarkan';

  @override
  String get itemsFilterFavoritesOnly => 'Hanya favorit';

  @override
  String get itemsFilterWishlistOnly => 'Hanya wishlist';

  @override
  String get itemsFilterConditionsTitle => 'Kondisi';

  @override
  String get itemsTagsTitle => 'Tag';

  @override
  String itemsQuantityLabel(int quantity) {
    return 'Jml: $quantity';
  }

  @override
  String itemsQuantityShort(int quantity) {
    return 'x$quantity';
  }

  @override
  String get itemSortCustom => 'Urutan kustom';

  @override
  String get itemSortTitle => 'Judul';

  @override
  String get itemSortCreatedAt => 'Tanggal ditambahkan';

  @override
  String get itemSortPurchaseDate => 'Tanggal beli';

  @override
  String get itemSortCurrentValue => 'Nilai saat ini';

  @override
  String get itemSortQuantity => 'Jumlah';

  @override
  String get itemConditionMint => 'Sempurna';

  @override
  String get itemConditionGood => 'Baik';

  @override
  String get itemConditionFair => 'Cukup';

  @override
  String get itemConditionPoor => 'Buruk';

  @override
  String get itemDetailNotFoundTitle => 'Item tidak ditemukan';

  @override
  String get itemDetailNotFoundMessage => 'Item ini sudah tidak ada.';

  @override
  String get itemDetailFavorited => 'Difavoritkan';

  @override
  String get itemDetailFavorite => 'Favorit';

  @override
  String get itemDetailInWishlist => 'Di Wishlist';

  @override
  String get itemDetailPriceTrackingTitle => 'Pelacakan harga';

  @override
  String get itemDetailNoValueMessage => 'Belum ada nilai saat ini';

  @override
  String get itemDetailNoHistoryMessage => 'Belum ada riwayat harga';

  @override
  String get itemDetailPriceHistoryError => 'Gagal memuat riwayat harga';

  @override
  String get itemDetailDetailsTitle => 'Detail';

  @override
  String get itemDetailBarcodeLabel => 'Barcode';

  @override
  String get itemDetailConditionLabel => 'Kondisi';

  @override
  String get itemDetailQuantityLabel => 'Jumlah';

  @override
  String get itemDetailLocationLabel => 'Lokasi';

  @override
  String get itemDetailPurchasePriceLabel => 'Harga beli';

  @override
  String get itemDetailCurrentValueLabel => 'Nilai saat ini';

  @override
  String get itemDetailPurchaseDateLabel => 'Tanggal beli';

  @override
  String get itemDetailNotesTitle => 'Catatan';

  @override
  String get itemDetailLoadingMessage => 'Memuat detail item...';

  @override
  String itemDetailErrorLoading(String error) {
    return 'Gagal memuat detail item: $error';
  }

  @override
  String get itemDetailUpdateValueTitle => 'Perbarui nilai saat ini';

  @override
  String get itemDetailCurrentValueUpdated => 'Nilai saat ini diperbarui';

  @override
  String itemDetailUpdateValueFailed(String error) {
    return 'Gagal memperbarui nilai: $error';
  }

  @override
  String get addItemTitle => 'Tambah Item';

  @override
  String get addItemSubmit => 'Tambah Item';

  @override
  String get addItemTitleHint => 'contoh: The Lord of the Rings';

  @override
  String get addItemFetchingMetadata => 'Mengambil metadata...';

  @override
  String addItemMatchedMetadata(String source) {
    return 'Metadata $source ditemukan';
  }

  @override
  String get addItemTagsHint => 'contoh: Langka, Set Lengkap';

  @override
  String get addItemSuccess => 'Item berhasil ditambahkan';

  @override
  String addItemError(String error) {
    return 'Gagal menambahkan item: $error';
  }

  @override
  String get editItemTitle => 'Edit Item';

  @override
  String get editItemLoading => 'Memuat item...';

  @override
  String editItemError(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get editItemSaveChanges => 'Simpan Perubahan';

  @override
  String get editItemTagsHint => 'contoh: Bertanda tangan, Edisi Pertama';

  @override
  String get editItemSuccess => 'Item berhasil diperbarui';

  @override
  String editItemUpdateError(String error) {
    return 'Gagal memperbarui item: $error';
  }

  @override
  String get itemFormTitleLabel => 'Judul';

  @override
  String get itemFormTitleRequired => 'Silakan masukkan judul';

  @override
  String get itemFormBarcodeLabelOptional => 'Barcode (opsional)';

  @override
  String get itemFormBarcodeHint => 'ISBN, UPC, dll.';

  @override
  String get itemFormDescriptionLabelOptional => 'Deskripsi (opsional)';

  @override
  String get itemFormDescriptionHint => 'Tambahkan deskripsi';

  @override
  String get itemFormTagsLabelOptional => 'Tag (opsional)';

  @override
  String get itemFormPurchaseDateLabelOptional => 'Tanggal beli (opsional)';

  @override
  String get itemFormConditionLabelOptional => 'Kondisi (opsional)';

  @override
  String get itemFormQuantityRequired => 'Silakan masukkan jumlah';

  @override
  String get itemFormQuantityInvalid => 'Masukkan jumlah yang valid';

  @override
  String get itemFormLocationLabelOptional => 'Lokasi (opsional)';

  @override
  String get itemFormLocationHint => 'contoh: Rak A, Kotak 3';

  @override
  String get itemFormNotesLabelOptional => 'Catatan (opsional)';

  @override
  String get itemFormInvalidPrice => 'Harga tidak valid';

  @override
  String get itemFormMustBePositive => 'Harus bernilai positif';

  @override
  String get itemTagsEditorHint => 'Tambahkan tag';

  @override
  String get itemTagsEditorAddTooltip => 'Tambah tag';

  @override
  String get itemTagsEditorEmptyMessage => 'Belum ada tag. Tambahkan tag agar item lebih mudah diatur.';

  @override
  String get itemTagsEditorTooLong => 'Tag harus 50 karakter atau kurang';

  @override
  String get globalItemsLoading => 'Memuat item...';

  @override
  String globalItemsErrorLoading(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get globalItemsNoFavoritesTitle => 'Belum ada item favorit';

  @override
  String get globalItemsNoFavoritesMessage => 'Tandai item sebagai favorit agar muncul di sini.';

  @override
  String get globalItemsNoWishlistTitle => 'Wishlist kamu kosong';

  @override
  String get globalItemsNoWishlistMessage => 'Simpan item ke wishlist untuk melihatnya di sini.';

  @override
  String metadataSearchFieldLabel(String collectionType) {
    return 'Cari $collectionType berdasarkan judul';
  }

  @override
  String get metadataSearchEmptyTitle => 'Cari metadata';

  @override
  String get metadataSearchEmptyMessage => 'Masukkan judul untuk mencari.';

  @override
  String get metadataSearchLoading => 'Mencari metadata...';

  @override
  String metadataSearchError(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get metadataSearchNoResultsTitle => 'Tidak ada hasil';

  @override
  String get metadataSearchNoResultsMessage => 'Tidak ada metadata ditemukan untuk judul ini.';

  @override
  String get metadataSearchSuggestionTitle => 'Cari berdasarkan judul';

  @override
  String get metadataSearchSuggestionMessage => 'Mulai mengetik untuk mencari metadata.';

  @override
  String get metadataSearchDisabledHint => 'Pencarian metadata tidak tersedia untuk tipe koleksi ini atau sedang dinonaktifkan.';

  @override
  String get metadataNoMatchForBarcode => 'Tidak ditemukan metadata yang cocok untuk barcode ini.';

  @override
  String metadataSearchUnavailableForType(String collectionType) {
    return 'Pencarian metadata tidak tersedia untuk $collectionType.';
  }

  @override
  String tagItemsTitle(String tag) {
    return 'Tag: $tag';
  }

  @override
  String get tagItemsSortTooltip => 'Urutkan';

  @override
  String get tagItemsSortNewest => 'Urutkan: Terbaru';

  @override
  String get tagItemsSortOldest => 'Urutkan: Terlama';

  @override
  String get tagItemsSortTitle => 'Urutkan: Judul';

  @override
  String get tagItemsLoadingCollections => 'Memuat koleksi...';

  @override
  String get tagItemsLoadingItems => 'Memuat item bertag...';

  @override
  String tagItemsError(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get tagItemsEmptyTitle => 'Tidak ada item ditemukan';

  @override
  String get tagItemsEmptyMessage => 'Belum ada item koleksi yang menggunakan tag ini.';

  @override
  String get tagItemsUnknownCollection => 'Tidak diketahui';

  @override
  String get tagItemsOpenCollectionTooltip => 'Buka koleksi';

  @override
  String tagItemsDeleteFailed(String error) {
    return 'Gagal menghapus: $error';
  }

  @override
  String get tagManagementTitle => 'Kelola Tag';

  @override
  String tagManagementSelectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String get tagManagementCancelSelectionTooltip => 'Batalkan pilihan';

  @override
  String get tagManagementSelectTagsTooltip => 'Pilih tag';

  @override
  String get tagManagementSearchHint => 'Cari tag...';

  @override
  String get tagManagementEmptyTitle => 'Belum ada tag';

  @override
  String tagManagementNoMatch(String query) {
    return 'Tidak ada tag yang cocok dengan \"$query\"';
  }

  @override
  String get tagManagementSelectVisible => 'Pilih yang terlihat';

  @override
  String get tagManagementSelectAllMatches => 'Pilih semua yang cocok';

  @override
  String get tagManagementClearSelection => 'Hapus pilihan';

  @override
  String tagManagementScrollMore(int remaining) {
    return 'Gulir untuk memuat $remaining tag lagi';
  }

  @override
  String get tagManagementUsedInOne => 'Digunakan di 1 item';

  @override
  String tagManagementUsedInMany(int count) {
    return 'Digunakan di $count item';
  }

  @override
  String get tagManagementRenameAction => 'Ubah nama';

  @override
  String get tagManagementMergeAction => 'Gabungkan';

  @override
  String get tagManagementMergeIntoAction => 'Gabungkan ke...';

  @override
  String tagManagementLoadError(String error) {
    return 'Gagal memuat tag: $error';
  }

  @override
  String get tagManagementRenameTitle => 'Ubah Nama Tag';

  @override
  String get tagManagementNewNameLabel => 'Nama baru';

  @override
  String tagManagementRenameSuccess(String oldName, String newName) {
    return '\"$oldName\" diubah menjadi \"$newName\"';
  }

  @override
  String get tagManagementMergeSelectedTitle => 'Gabungkan Tag Terpilih';

  @override
  String get tagManagementChooseDestination => 'Pilih tag tujuan:';

  @override
  String tagManagementMergeSelectedSuccess(int count, String destination) {
    return '$count tag digabungkan ke \"$destination\"';
  }

  @override
  String get tagManagementDeleteSelectedTitle => 'Hapus Tag Terpilih';

  @override
  String tagManagementDeleteSelectedMessage(int count) {
    return 'Hapus $count tag terpilih dari semua item?\\n\\nTindakan ini tidak dapat dibatalkan.';
  }

  @override
  String tagManagementDeleteSelectedSuccess(int count) {
    return '$count tag dihapus';
  }

  @override
  String get tagManagementMergeIntoTitle => 'Gabungkan ke';

  @override
  String tagManagementMergeSuccess(String source, String target) {
    return '\"$source\" digabungkan ke \"$target\"';
  }

  @override
  String get tagManagementDeleteTitle => 'Hapus Tag';

  @override
  String tagManagementDeleteMessage(String tagName) {
    return 'Hapus \"$tagName\" dari semua item?\\n\\nTindakan ini tidak dapat dibatalkan.';
  }

  @override
  String tagManagementDeleteSuccess(String tagName) {
    return '\"$tagName\" dihapus';
  }

  @override
  String tagManagementMutationError(String error) {
    return 'Gagal memperbarui tag: $error';
  }

  @override
  String get statisticsTitle => 'Statistik';

  @override
  String get statisticsEmptyTitle => 'Belum ada statistik';

  @override
  String get statisticsEmptyMessage => 'Tambahkan koleksi dan item untuk melihat insight.';

  @override
  String get statisticsLoadingMessage => 'Memuat statistik...';

  @override
  String statisticsErrorLoading(String error) {
    return 'Gagal memuat statistik: $error';
  }

  @override
  String get statisticsPortfolioValueTitle => 'Nilai portofolio';

  @override
  String statisticsAveragePricedItem(String value) {
    return 'Rata-rata item bernilai: $value';
  }

  @override
  String statisticsPricedItemsBadge(int priced, int total) {
    return 'Item bernilai: $priced/$total';
  }

  @override
  String get statisticsQuantityTitle => 'Jumlah total';

  @override
  String get statisticsFavoritesTitle => 'Favorit';

  @override
  String statisticsPercentOfItems(String percent) {
    return '$percent% dari item';
  }

  @override
  String get statisticsInventoryHealthTitle => 'Kesehatan inventaris';

  @override
  String get statisticsValuationCoverageLabel => 'Cakupan valuasi';

  @override
  String statisticsPricedCaption(int priced, int total) {
    return '$priced dari $total item memiliki harga';
  }

  @override
  String get statisticsFavoritesCoverageLabel => 'Cakupan favorit';

  @override
  String statisticsFavoritesCaption(int favorites, int total) {
    return '$favorites dari $total item adalah favorit';
  }

  @override
  String get statisticsWishlistCoverageLabel => 'Cakupan wishlist';

  @override
  String statisticsWishlistCaption(int wishlist, int total) {
    return '$wishlist dari $total item ada di wishlist';
  }

  @override
  String get statisticsItemsByTypeTitle => 'Item berdasarkan jenis';

  @override
  String get statisticsItemsByConditionTitle => 'Item berdasarkan kondisi';

  @override
  String get statisticsTopValuedTitle => 'Koleksi dengan nilai tertinggi';

  @override
  String get statisticsLargestCollectionTitle => 'Koleksi terbesar';

  @override
  String get statisticsRecentlyCreatedTitle => 'Baru dibuat';

  @override
  String statisticsRecentCollectionSubtitle(int itemCount, String createdAt) {
    return '$itemCount item • $createdAt';
  }

  @override
  String get statisticsNoChartData => 'Data grafik tidak tersedia';

  @override
  String get statisticsTotalLabel => 'Total';

  @override
  String get relativeToday => 'Hari ini';

  @override
  String get relativeYesterday => 'Kemarin';

  @override
  String relativeDaysAgo(int days) {
    return '$days hari lalu';
  }

  @override
  String relativeWeeksAgo(int weeks) {
    return '$weeks minggu lalu';
  }

  @override
  String relativeMonthsAgo(int months) {
    return '$months bulan lalu';
  }

  @override
  String relativeYearsAgo(int years) {
    return '$years tahun lalu';
  }

  @override
  String get collectionDetailsNotFoundTitle => 'Koleksi tidak ditemukan';

  @override
  String get collectionDetailsNotFoundMessage => 'Koleksi yang dipilih tidak tersedia.';

  @override
  String get collectionDetailsCreatedLabel => 'Dibuat';

  @override
  String get collectionDetailsUpdatedLabel => 'Terakhir diperbarui';

  @override
  String get collectionDetailsLoading => 'Memuat koleksi...';

  @override
  String get collectionTypeBooks => 'Buku';

  @override
  String get collectionTypeGames => 'Game';

  @override
  String get collectionTypeMovies => 'Film';

  @override
  String get collectionTypeComics => 'Komik';

  @override
  String get collectionTypeMusic => 'Musik';

  @override
  String get collectionTypeCustom => 'Kustom';

  @override
  String get loanTrackingTitle => 'Pelacakan Pinjaman';

  @override
  String get loanTrackingNewLoan => 'Pinjaman Baru';

  @override
  String get loanTrackingFilterActive => 'Aktif';

  @override
  String get loanTrackingFilterHistory => 'Riwayat';

  @override
  String get loanTrackingEmptyHistoryTitle => 'Belum ada pinjaman yang dikembalikan';

  @override
  String get loanTrackingEmptyHistoryMessage => 'Item yang sudah dikembalikan akan muncul di sini.';

  @override
  String get loanTrackingEmptyActiveTitle => 'Tidak ada pinjaman aktif';

  @override
  String get loanTrackingEmptyActiveMessage => 'Buat pinjaman untuk mulai melacak item yang dipinjam.';

  @override
  String get loanTrackingLoadingLoans => 'Memuat pinjaman...';

  @override
  String loanTrackingLoadFailed(String error) {
    return 'Gagal memuat pinjaman: $error';
  }

  @override
  String get loanTrackingMarkReturnedConfirmTitle => 'Tandai sudah dikembalikan?';

  @override
  String loanTrackingMarkReturnedConfirmMessage(String itemTitle) {
    return 'Konfirmasi pengembalian untuk \"$itemTitle\".';
  }

  @override
  String get loanTrackingMarkReturnedAction => 'Tandai Dikembalikan';

  @override
  String get loanTrackingMarkedReturnedSuccess => 'Pinjaman ditandai sudah dikembalikan.';

  @override
  String loanTrackingMarkReturnedFailed(String error) {
    return 'Gagal menandai pengembalian: $error';
  }

  @override
  String get loanTrackingDeleteConfirmTitle => 'Hapus catatan pinjaman?';

  @override
  String loanTrackingDeleteConfirmMessage(String itemTitle) {
    return 'Hapus catatan pinjaman untuk \"$itemTitle\".';
  }

  @override
  String get loanTrackingDeleteSuccess => 'Pinjaman dihapus.';

  @override
  String loanTrackingDeleteFailed(String error) {
    return 'Gagal menghapus pinjaman: $error';
  }

  @override
  String get loanTrackingSummaryActiveLabel => 'Pinjaman Aktif';

  @override
  String get loanTrackingSummaryOverdueLabel => 'Terlambat';

  @override
  String get loanTrackingSummaryLoadFailed => 'Tidak dapat memuat ringkasan pinjaman.';

  @override
  String get loanTrackingFieldBorrower => 'Peminjam';

  @override
  String get loanTrackingFieldContact => 'Kontak';

  @override
  String get loanTrackingFieldLoaned => 'Dipinjamkan';

  @override
  String get loanTrackingFieldDue => 'Jatuh tempo';

  @override
  String get loanTrackingFieldReturned => 'Dikembalikan';

  @override
  String get loanTrackingStatusReturned => 'Dikembalikan';

  @override
  String get loanTrackingStatusOverdue => 'Terlambat';

  @override
  String get loanTrackingStatusActive => 'Aktif';

  @override
  String get loanTrackingCreateTitle => 'Buat Pinjaman';

  @override
  String get loanTrackingCreateDescription => 'Lacak siapa yang meminjam item dan kapan harus dikembalikan.';

  @override
  String get loanTrackingCreateNoItemsTitle => 'Tidak ada item yang tersedia';

  @override
  String get loanTrackingCreateNoItemsMessage => 'Semua item sedang dipinjam atau belum ada item.';

  @override
  String get loanTrackingCreateItemLabel => 'Item';

  @override
  String get loanTrackingCreateBorrowerLabel => 'Nama peminjam';

  @override
  String get loanTrackingCreateBorrowerHint => 'mis. Budi Santoso';

  @override
  String get loanTrackingCreateContactLabel => 'Kontak (opsional)';

  @override
  String get loanTrackingCreateContactHint => 'Telepon, email, atau @username';

  @override
  String get loanTrackingCreateNotesLabel => 'Catatan (opsional)';

  @override
  String get loanTrackingCreateNotesHint => 'Detail tambahan untuk pinjaman ini';

  @override
  String get loanTrackingCreateSubmitting => 'Membuat...';

  @override
  String get loanTrackingCreateAction => 'Buat Pinjaman';

  @override
  String get loanTrackingLoadingItems => 'Memuat item...';

  @override
  String loanTrackingLoadItemsFailed(String error) {
    return 'Gagal memuat item: $error';
  }

  @override
  String get loanTrackingBorrowerRequired => 'Nama peminjam wajib diisi.';

  @override
  String get loanTrackingCreateSuccess => 'Pinjaman berhasil dibuat.';

  @override
  String loanTrackingCreateFailed(String error) {
    return 'Gagal membuat pinjaman: $error';
  }

  @override
  String get loanTrackingNoDueDate => 'Tanpa tanggal jatuh tempo';

  @override
  String get loanTrackingPickDateAction => 'Pilih';

  @override
  String get loanTrackingClearDateAction => 'Hapus';

  @override
  String get loanTrackingDueDateLabel => 'Tanggal jatuh tempo';

  @override
  String get authTitleAccount => 'Akun';

  @override
  String get authCreateAccountHeading => 'Buat Akun';

  @override
  String get authSignInHeading => 'Masuk';

  @override
  String get authCreateAccountDescription => 'Buat akun untuk menyinkronkan koleksi Anda di berbagai perangkat.';

  @override
  String get authSignInDescription => 'Masuk untuk mengaktifkan sinkronisasi cloud dan fitur akun.';

  @override
  String get authSignInChoice => 'Masuk';

  @override
  String get authRegisterChoice => 'Daftar';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'anda@contoh.com';

  @override
  String get authEmailRequiredError => 'Email wajib diisi.';

  @override
  String get authEmailInvalidError => 'Masukkan email yang valid.';

  @override
  String get authPasswordLabel => 'Kata sandi';

  @override
  String get authPasswordHint => 'Min 8 karakter, A-Z, a-z, 0-9';

  @override
  String get authPasswordRequiredError => 'Kata sandi wajib diisi.';

  @override
  String get authPasswordLengthError => 'Kata sandi minimal 8 karakter.';

  @override
  String get authPasswordPolicyError => 'Kata sandi harus mengandung huruf besar, huruf kecil, dan angka.';

  @override
  String get authDisplayNameLabel => 'Nama tampilan (opsional)';

  @override
  String get authDisplayNameHint => 'Kami memanggil Anda dengan nama apa?';

  @override
  String get authCreateAccountAction => 'Buat akun';

  @override
  String get authNotNowAction => 'Nanti saja';

  @override
  String get authUnavailableMessage => 'Autentikasi sedang tidak tersedia.';

  @override
  String get authRegisterSuccess => 'Akun berhasil dibuat dan Anda sudah masuk.';

  @override
  String get authSignInSuccess => 'Berhasil masuk.';

  @override
  String authSignInFailed(String error) {
    return 'Gagal masuk: $error';
  }

  @override
  String get authSignedOut => 'Berhasil keluar.';

  @override
  String get authFinalConfirmationTitle => 'Konfirmasi akhir';

  @override
  String get authFinalConfirmationMessage => 'Kirim permintaan penghapusan akun sekarang? Anda akan langsung keluar dari perangkat ini.';

  @override
  String get authBackAction => 'Kembali';

  @override
  String get authSubmitRequestAction => 'Kirim Permintaan';

  @override
  String get authDeletionRequestSubmitted => 'Permintaan penghapusan akun dikirim. Anda telah keluar.';

  @override
  String get authDeletionEndpointMissing => 'Endpoint permintaan penghapusan belum dikonfigurasi di backend.';

  @override
  String get authDeletionImpactDialogTitle => 'Sebelum meminta penghapusan akun';

  @override
  String get authDeletionImpactReviewPrompt => 'Tinjau dampaknya dengan saksama.';

  @override
  String get authIrreversibleRequestTitle => 'Permintaan tidak dapat dibatalkan';

  @override
  String get authImpactLineSessionRevoked => 'Sesi akun Anda dicabut segera setelah permintaan dikirim.';

  @override
  String get authImpactLineCloudDataDeleted => 'Data cloud tersinkron yang terkait akun ini dapat dihapus permanen saat diproses.';

  @override
  String get authImpactLineCannotRestore => 'Data akun yang sudah dihapus tidak dapat dipulihkan setelah diproses.';

  @override
  String get authUnderstandAction => 'Saya mengerti';

  @override
  String get authPasswordPolicySuffix => 'Gunakan huruf dan angka keyboard Inggris (A-Z, a-z, 0-9).';

  @override
  String get authAccountConnected => 'Akun terhubung';

  @override
  String get authSignedInReadySubtitle => 'Sudah masuk dan siap untuk sinkronisasi cloud';

  @override
  String get authActiveStatus => 'Aktif';

  @override
  String get authSessionDetailsTitle => 'Detail sesi';

  @override
  String get authUserIdLabel => 'ID Pengguna';

  @override
  String get authDeviceIdLabel => 'ID Perangkat';

  @override
  String get authUnknownValue => 'Tidak diketahui';

  @override
  String get authDeletionNoticeTitle => 'Pemberitahuan penghapusan akun';

  @override
  String get authDeletionNoticeSubtitle => 'Permintaan penghapusan bersifat permanen setelah diproses.';

  @override
  String get authDeletionNoticeLineProfileSessions => 'Profil akun dan sesi aktif akan dihapus dari akses cloud.';

  @override
  String get authDeletionNoticeLineSyncedData => 'Koleksi, item, tag, dan pinjaman tersinkron dapat dihapus permanen.';

  @override
  String get authRequestDeletionAction => 'Minta penghapusan akun';

  @override
  String get authSignOutAction => 'Keluar';

  @override
  String get authDoneAction => 'Selesai';

  @override
  String get authHeaderCreateTitle => 'Buat akun Anda';

  @override
  String get authHeaderWelcomeTitle => 'Selamat datang kembali';

  @override
  String get authHeaderCreateSubtitle => 'Akun bersifat opsional, tetapi diperlukan untuk sinkronisasi cloud dan akses multi-perangkat.';

  @override
  String get authHeaderSignInSubtitle => 'Masuk untuk menggunakan sinkronisasi cloud dan fitur berbasis akun.';

  @override
  String get authUnavailableTitle => 'Autentikasi tidak tersedia';
}
