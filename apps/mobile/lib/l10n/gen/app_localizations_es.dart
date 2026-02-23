// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Collectra';

  @override
  String get navHome => 'Inicio';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navWishlist => 'Deseados';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionDismiss => 'Cerrar';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSwitchToGrid => 'Cambiar a cuadrícula';

  @override
  String get actionSwitchToList => 'Cambiar a lista';

  @override
  String get actionUpdate => 'Update';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionData => 'Datos';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsSectionDeveloper => 'Desarrollador';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsExportJsonTitle => 'Exportar a JSON';

  @override
  String get settingsExportJsonSubtitle => 'Exportar todos los datos como JSON';

  @override
  String get settingsExportCsvTitle => 'Exportar a CSV';

  @override
  String get settingsExportCsvSubtitle => 'Exportar artículos como hoja CSV';

  @override
  String get settingsImportJsonTitle => 'Importar desde JSON';

  @override
  String get settingsImportJsonSubtitle => 'Importar datos desde archivo JSON';

  @override
  String get settingsCloudSyncTitle => 'Sincronización en la nube';

  @override
  String get settingsCloudSyncSubtitle => 'No configurado';

  @override
  String get settingsManageTagsTitle => 'Gestionar etiquetas';

  @override
  String get settingsManageTagsSubtitle => 'Renombrar, combinar y eliminar etiquetas';

  @override
  String get settingsLoanTrackingTitle => 'Seguimiento de préstamos';

  @override
  String get settingsLoanTrackingSubtitle => 'Controla artículos prestados y fechas de devolución';

  @override
  String get settingsVersionTitle => 'Versión';

  @override
  String get settingsPrivacyPolicyTitle => 'Política de privacidad';

  @override
  String get settingsTermsTitle => 'Términos de servicio';

  @override
  String get settingsAnalyticsTitle => 'Analíticas';

  @override
  String get settingsAnalyticsSummaryEnabled => 'Activadas';

  @override
  String get settingsAnalyticsSummaryDisabled => 'Desactivadas';

  @override
  String get settingsAnalyticsSummaryPending => 'Se requiere consentimiento';

  @override
  String get settingsAnalyticsSummaryDenied => 'Consentimiento rechazado';

  @override
  String get settingsAnalyticsSheetTitle => 'Preferencias de analíticas';

  @override
  String get settingsAnalyticsDescription => 'Controla las analíticas de uso anónimas y las preferencias de compartición de datos.';

  @override
  String get settingsAnalyticsToggleTitle => 'Activar analíticas';

  @override
  String get settingsAnalyticsToggleSubtitle => 'Permite recopilar eventos anónimos de uso de la aplicación.';

  @override
  String get settingsAnalyticsConsentStatusTitle => 'Estado del consentimiento';

  @override
  String get settingsAnalyticsConsentStatusGranted => 'Concedido';

  @override
  String get settingsAnalyticsConsentStatusDenied => 'Rechazado';

  @override
  String get settingsAnalyticsConsentStatusPending => 'Pendiente';

  @override
  String get settingsAnalyticsReviewConsentAction => 'Revisar consentimiento';

  @override
  String get settingsAnalyticsRevokeConsentAction => 'Revocar consentimiento';

  @override
  String get settingsAnalyticsConsentAccepted => 'Consentimiento de analíticas aceptado.';

  @override
  String get settingsAnalyticsConsentDeclined => 'Consentimiento de analíticas rechazado.';

  @override
  String get analyticsConsentDialogTitle => 'Ayúdanos a mejorar Collectra';

  @override
  String get analyticsConsentDialogMessage => '¿Podemos recopilar analíticas de uso anónimas para mejorar la calidad y las funciones de la app? Puedes cambiarlo en Configuración en cualquier momento.';

  @override
  String get analyticsConsentAllowAction => 'Permitir';

  @override
  String get analyticsConsentDeclineAction => 'Ahora no';

  @override
  String get settingsCrashlyticsTestTitle => 'Probar Crashlytics';

  @override
  String get settingsCrashlyticsTestSubtitle => 'Bloquea la app intencionalmente para verificar los reportes de fallos';

  @override
  String get settingsCrashlyticsTestConfirmTitle => '¿Activar bloqueo de prueba?';

  @override
  String get settingsCrashlyticsTestConfirmMessage => 'La aplicación se cerrará inmediatamente. Ábrela de nuevo para verificar el fallo en Firebase Crashlytics.';

  @override
  String get settingsCrashlyticsTestConfirmAction => 'Bloquear ahora';

  @override
  String get settingsCrashlyticsTestTriggered => 'Iniciando bloqueo de prueba...';

  @override
  String settingsCrashlyticsTestFailed(String error) {
    return 'No se pudo iniciar la prueba de bloqueo: $error';
  }

  @override
  String get settingsFirebaseRuntimeConfigTitle => 'Configuración de ejecución de Firebase';

  @override
  String get settingsFirebaseRuntimeConfigSubtitle => 'Inspecciona y actualiza las banderas de ejecución';

  @override
  String get settingsMetadataTitle => 'Metadatos y Autorrelleno';

  @override
  String get settingsMetadataSummaryEnabled => 'Activado con búsqueda automática por código de barras';

  @override
  String get settingsMetadataSummaryManual => 'Activado con búsqueda manual';

  @override
  String get settingsMetadataSummaryDisabled => 'Desactivado';

  @override
  String get settingsMetadataSummaryFeatureDisabled => 'Desactivado por bandera de ejecución';

  @override
  String get settingsMetadataEnableToggleTitle => 'Activar asistencia de metadatos';

  @override
  String get settingsMetadataEnableToggleSubtitle => 'Permite la búsqueda de metadatos y el autorrelleno por código de barras en formularios de artículos.';

  @override
  String get settingsMetadataAutoFetchToggleTitle => 'Buscar automáticamente al escanear código';

  @override
  String get settingsMetadataAutoFetchToggleSubtitle => 'Después de escanear un código de barras, obtiene metadatos automáticamente.';

  @override
  String get settingsMetadataFillEmptyOnlyToggleTitle => 'Rellenar solo campos vacíos';

  @override
  String get settingsMetadataFillEmptyOnlyToggleSubtitle => 'No sobrescribe el título ni la descripción existentes cuando se encuentran metadatos.';

  @override
  String get settingsMetadataSourcesSectionTitle => 'Fuentes';

  @override
  String get settingsMetadataSourceAvailable => 'Disponible';

  @override
  String get settingsMetadataSourceNotConfigured => 'Sin configurar';

  @override
  String get settingsMetadataSourceManualOnly => 'Solo manual';

  @override
  String get settingsMetadataManualCollectionsLabel => 'Cómics, Música y Personalizado';

  @override
  String get settingsMetadataFeatureDisabledMessage => 'La asistencia de metadatos está desactivada por configuración de ejecución.';

  @override
  String get settingsFirebaseRuntimeConfigSheetTitle => 'Configuración de ejecución de Firebase';

  @override
  String get settingsFirebaseRuntimeConfigDescription => 'Los valores se obtienen de Firebase Remote Config y se aplican en tiempo de ejecución.';

  @override
  String settingsFirebaseRuntimeConfigSummary(int enabledCount) {
    return '$enabledCount de 3 señales activas';
  }

  @override
  String get settingsFirebaseRuntimeConfigAnalyticsLabel => 'Recopilación de analíticas';

  @override
  String get settingsFirebaseRuntimeConfigCrashlyticsLabel => 'Recopilación de Crashlytics';

  @override
  String get settingsFirebaseRuntimeConfigPerformanceLabel => 'Recopilación de rendimiento';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusTitle => 'Estado de la última obtención';

  @override
  String get settingsFirebaseRuntimeConfigLastFetchTitle => 'Hora de la última obtención';

  @override
  String get settingsFirebaseRuntimeConfigValueEnabled => 'Activado';

  @override
  String get settingsFirebaseRuntimeConfigValueDisabled => 'Desactivado';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusSuccess => 'Correcto';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusFailure => 'Fallido';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusThrottled => 'Limitado';

  @override
  String get settingsFirebaseRuntimeConfigFetchStatusNoFetch => 'Aún sin obtención';

  @override
  String get settingsFirebaseRuntimeConfigRefreshAction => 'Actualizar configuración';

  @override
  String get settingsFirebaseRuntimeConfigRefreshingAction => 'Actualizando...';

  @override
  String get settingsFirebaseRuntimeConfigRefreshSuccess => 'La configuración de ejecución de Firebase se actualizó.';

  @override
  String get settingsFirebaseRuntimeConfigRefreshNoChanges => 'La configuración de ejecución de Firebase ya está actualizada.';

  @override
  String settingsFirebaseRuntimeConfigRefreshFailed(String error) {
    return 'No se pudo actualizar la configuración: $error';
  }

  @override
  String get settingsExportingData => 'Exportando datos...';

  @override
  String get settingsDataExportSuccess => '¡Datos exportados correctamente!';

  @override
  String settingsExportFailed(String error) {
    return 'Error de exportación: $error';
  }

  @override
  String get settingsImportDataTitle => 'Importar datos';

  @override
  String get settingsImportDataMessage => 'Esto importará colecciones y artículos desde un archivo JSON. Los datos existentes no se eliminarán.\n\n¿Continuar?';

  @override
  String get settingsImportingData => 'Importando datos...';

  @override
  String get settingsDataImportSuccess => '¡Datos importados correctamente!';

  @override
  String settingsImportFailed(String error) {
    return 'Error de importación: $error';
  }

  @override
  String get settingsThemeModeTitle => 'Modo de tema';

  @override
  String get settingsThemeColorVariantTitle => 'Variante de color';

  @override
  String get settingsAmoledTitle => 'Modo Amoled (negro puro)';

  @override
  String get settingsAmoledSubtitle => 'Reduce el consumo de batería en pantallas OLED';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageIndonesian => 'Indonesio';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageChineseSimplified => 'Chino simplificado';

  @override
  String get languageBurmese => 'Birmano';

  @override
  String get collectionsTitle => 'Mis colecciones';

  @override
  String get collectionsCountLabel => 'Colecciones';

  @override
  String get collectionsNewButton => 'Nueva colección';

  @override
  String get collectionsActionsTooltip => 'Acciones de la colección';

  @override
  String get collectionsOpenAction => 'Abrir colección';

  @override
  String get collectionsEditAction => 'Editar colección';

  @override
  String get collectionsDeleteTitle => 'Eliminar colección';

  @override
  String collectionsDeleteMessage(String name, int itemCount) {
    return '¿Eliminar \"$name\" y $itemCount artículos de esta colección?';
  }

  @override
  String collectionsDeleted(String name) {
    return '$name eliminada';
  }

  @override
  String collectionsErrorLoading(String error) {
    return 'Error loading collections: $error';
  }

  @override
  String get itemsTitle => 'Artículos';

  @override
  String get itemsCountLabel => 'Artículos';

  @override
  String itemsCountWithValue(int count) {
    return '$count artículos';
  }

  @override
  String get itemsSearchHint => 'Buscar artículos...';

  @override
  String get itemsNoMatchesTitle => 'No se encontraron coincidencias';

  @override
  String get itemsNoMatchesMessage => 'Prueba a cambiar los filtros o las palabras clave.';

  @override
  String get itemsNoItemsTitle => 'Aún no hay artículos';

  @override
  String get itemsNoItemsMessage => 'Comienza añadiendo tu primer artículo.';

  @override
  String get itemsAddButton => 'Añadir artículo';

  @override
  String get itemsLoadingMessage => 'Cargando artículos...';

  @override
  String itemsErrorLoading(String error) {
    return 'Error al cargar artículos: $error';
  }

  @override
  String get itemsDeleteTitle => 'Eliminar artículo';

  @override
  String itemsDeleteMessage(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String itemsDeleted(String name) {
    return '$name eliminado';
  }

  @override
  String itemsOverviewCount(int count) {
    return '$count artículos';
  }

  @override
  String itemsSortedBy(String sortLabel) {
    return 'Ordenado por $sortLabel';
  }

  @override
  String get itemsCollectionDetailsTooltip => 'Detalles de la colección';

  @override
  String get itemsFiltersTooltip => 'Filtros';

  @override
  String get itemsFilterTitle => 'Filtrar artículos';

  @override
  String get itemsSortByTitle => 'Ordenar por';

  @override
  String get itemsFilterFavoritesOnly => 'Solo favoritos';

  @override
  String get itemsFilterWishlistOnly => 'Solo lista de deseos';

  @override
  String get itemsFilterConditionsTitle => 'Estado';

  @override
  String get itemsTagsTitle => 'Etiquetas';

  @override
  String itemsQuantityLabel(int quantity) {
    return 'Cant.: $quantity';
  }

  @override
  String itemsQuantityShort(int quantity) {
    return 'x$quantity';
  }

  @override
  String get itemSortCustom => 'Orden personalizado';

  @override
  String get itemSortTitle => 'Título';

  @override
  String get itemSortCreatedAt => 'Fecha de creación';

  @override
  String get itemSortPurchaseDate => 'Fecha de compra';

  @override
  String get itemSortCurrentValue => 'Valor actual';

  @override
  String get itemSortQuantity => 'Cantidad';

  @override
  String get itemConditionMint => 'Excelente';

  @override
  String get itemConditionGood => 'Bueno';

  @override
  String get itemConditionFair => 'Aceptable';

  @override
  String get itemConditionPoor => 'Malo';

  @override
  String get itemDetailNotFoundTitle => 'Artículo no encontrado';

  @override
  String get itemDetailNotFoundMessage => 'Este artículo ya no existe.';

  @override
  String get itemDetailFavorited => 'En favoritos';

  @override
  String get itemDetailFavorite => 'Favorito';

  @override
  String get itemDetailInWishlist => 'En lista de deseos';

  @override
  String get itemDetailPriceTrackingTitle => 'Seguimiento de precio';

  @override
  String get itemDetailNoValueMessage => 'No hay valor actual disponible';

  @override
  String get itemDetailNoHistoryMessage => 'Aún no hay historial de precios';

  @override
  String get itemDetailPriceHistoryError => 'No se pudo cargar el historial de precios';

  @override
  String get itemDetailDetailsTitle => 'Detalles';

  @override
  String get itemDetailBarcodeLabel => 'Código de barras';

  @override
  String get itemDetailConditionLabel => 'Estado';

  @override
  String get itemDetailQuantityLabel => 'Cantidad';

  @override
  String get itemDetailLocationLabel => 'Ubicación';

  @override
  String get itemDetailPurchasePriceLabel => 'Precio de compra';

  @override
  String get itemDetailCurrentValueLabel => 'Valor actual';

  @override
  String get itemDetailPurchaseDateLabel => 'Fecha de compra';

  @override
  String get itemDetailNotesTitle => 'Notas';

  @override
  String get itemDetailLoadingMessage => 'Cargando detalles del artículo...';

  @override
  String itemDetailErrorLoading(String error) {
    return 'Error al cargar detalles del artículo: $error';
  }

  @override
  String get itemDetailUpdateValueTitle => 'Actualizar valor actual';

  @override
  String get itemDetailCurrentValueUpdated => 'Valor actual actualizado';

  @override
  String itemDetailUpdateValueFailed(String error) {
    return 'Error al actualizar el valor: $error';
  }

  @override
  String get addItemTitle => 'Añadir artículo';

  @override
  String get addItemSubmit => 'Añadir artículo';

  @override
  String get addItemTitleHint => 'p. ej., El Señor de los Anillos';

  @override
  String get addItemFetchingMetadata => 'Obteniendo metadatos...';

  @override
  String addItemMatchedMetadata(String source) {
    return 'Metadatos de $source coincidentes';
  }

  @override
  String get addItemTagsHint => 'p. ej., Raro, Colección completa';

  @override
  String get addItemSuccess => 'Artículo añadido correctamente';

  @override
  String addItemError(String error) {
    return 'Error al añadir artículo: $error';
  }

  @override
  String get editItemTitle => 'Editar artículo';

  @override
  String get editItemLoading => 'Cargando artículo...';

  @override
  String editItemError(String error) {
    return 'Error: $error';
  }

  @override
  String get editItemSaveChanges => 'Guardar cambios';

  @override
  String get editItemTagsHint => 'p. ej., Firmado, Primera edición';

  @override
  String get editItemSuccess => 'Artículo actualizado correctamente';

  @override
  String editItemUpdateError(String error) {
    return 'Error al actualizar artículo: $error';
  }

  @override
  String get itemFormTitleLabel => 'Título';

  @override
  String get itemFormTitleRequired => 'Introduce un título';

  @override
  String get itemFormBarcodeLabelOptional => 'Código de barras (opcional)';

  @override
  String get itemFormBarcodeHint => 'ISBN, UPC, etc.';

  @override
  String get itemFormDescriptionLabelOptional => 'Descripción (opcional)';

  @override
  String get itemFormDescriptionHint => 'Añade una descripción';

  @override
  String get itemFormTagsLabelOptional => 'Etiquetas (opcional)';

  @override
  String get itemFormPurchaseDateLabelOptional => 'Fecha de compra (opcional)';

  @override
  String get itemFormConditionLabelOptional => 'Estado (opcional)';

  @override
  String get itemFormQuantityRequired => 'Introduce la cantidad';

  @override
  String get itemFormQuantityInvalid => 'Introduce una cantidad válida';

  @override
  String get itemFormLocationLabelOptional => 'Ubicación (opcional)';

  @override
  String get itemFormLocationHint => 'p. ej., Estante A, Caja 3';

  @override
  String get itemFormNotesLabelOptional => 'Notas (opcional)';

  @override
  String get itemFormInvalidPrice => 'Precio no válido';

  @override
  String get itemFormMustBePositive => 'Debe ser positivo';

  @override
  String get itemTagsEditorHint => 'Añadir una etiqueta';

  @override
  String get itemTagsEditorAddTooltip => 'Añadir etiqueta';

  @override
  String get itemTagsEditorEmptyMessage => 'Aún no hay etiquetas. Añade etiquetas para organizar más rápido.';

  @override
  String get itemTagsEditorTooLong => 'Las etiquetas deben tener 50 caracteres o menos';

  @override
  String get globalItemsLoading => 'Cargando artículos...';

  @override
  String globalItemsErrorLoading(String error) {
    return 'Error: $error';
  }

  @override
  String get globalItemsNoFavoritesTitle => 'Aún no hay favoritos';

  @override
  String get globalItemsNoFavoritesMessage => 'Marca artículos como favoritos para verlos aquí.';

  @override
  String get globalItemsNoWishlistTitle => 'Tu lista de deseos está vacía';

  @override
  String get globalItemsNoWishlistMessage => 'Guarda artículos en la lista de deseos para verlos aquí.';

  @override
  String metadataSearchFieldLabel(String collectionType) {
    return 'Buscar $collectionType por título';
  }

  @override
  String get metadataSearchEmptyTitle => 'Buscar metadatos';

  @override
  String get metadataSearchEmptyMessage => 'Introduce un título para buscar.';

  @override
  String get metadataSearchLoading => 'Buscando metadatos...';

  @override
  String metadataSearchError(String error) {
    return 'Error: $error';
  }

  @override
  String get metadataSearchNoResultsTitle => 'Sin resultados';

  @override
  String get metadataSearchNoResultsMessage => 'No se encontraron metadatos para este título.';

  @override
  String get metadataSearchSuggestionTitle => 'Buscar por título';

  @override
  String get metadataSearchSuggestionMessage => 'Empieza a escribir para buscar metadatos.';

  @override
  String get metadataSearchDisabledHint => 'La búsqueda de metadatos no está disponible para este tipo de colección o está desactivada.';

  @override
  String get metadataNoMatchForBarcode => 'No se encontraron metadatos para este código de barras.';

  @override
  String metadataSearchUnavailableForType(String collectionType) {
    return 'La búsqueda de metadatos no está disponible para $collectionType.';
  }

  @override
  String tagItemsTitle(String tag) {
    return 'Etiqueta: $tag';
  }

  @override
  String get tagItemsSortTooltip => 'Ordenar';

  @override
  String get tagItemsSortNewest => 'Ordenar: más recientes';

  @override
  String get tagItemsSortOldest => 'Ordenar: más antiguos';

  @override
  String get tagItemsSortTitle => 'Ordenar: título';

  @override
  String get tagItemsLoadingCollections => 'Cargando colecciones...';

  @override
  String get tagItemsLoadingItems => 'Cargando artículos etiquetados...';

  @override
  String tagItemsError(String error) {
    return 'Error: $error';
  }

  @override
  String get tagItemsEmptyTitle => 'No se encontraron artículos';

  @override
  String get tagItemsEmptyMessage => 'Ningún artículo usa actualmente esta etiqueta.';

  @override
  String get tagItemsUnknownCollection => 'Desconocido';

  @override
  String get tagItemsOpenCollectionTooltip => 'Abrir colección';

  @override
  String tagItemsDeleteFailed(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get tagManagementTitle => 'Gestionar etiquetas';

  @override
  String tagManagementSelectedCount(int count) {
    return '$count seleccionadas';
  }

  @override
  String get tagManagementCancelSelectionTooltip => 'Cancelar selección';

  @override
  String get tagManagementSelectTagsTooltip => 'Seleccionar etiquetas';

  @override
  String get tagManagementSearchHint => 'Buscar etiquetas...';

  @override
  String get tagManagementEmptyTitle => 'Aún no hay etiquetas';

  @override
  String tagManagementNoMatch(String query) {
    return 'No hay etiquetas que coincidan con \"$query\"';
  }

  @override
  String get tagManagementSelectVisible => 'Seleccionar visibles';

  @override
  String get tagManagementSelectAllMatches => 'Seleccionar todas las coincidencias';

  @override
  String get tagManagementClearSelection => 'Limpiar selección';

  @override
  String tagManagementScrollMore(int remaining) {
    return 'Desplázate para cargar $remaining etiquetas más';
  }

  @override
  String get tagManagementUsedInOne => 'Usada en 1 artículo';

  @override
  String tagManagementUsedInMany(int count) {
    return 'Usada en $count artículos';
  }

  @override
  String get tagManagementRenameAction => 'Renombrar';

  @override
  String get tagManagementMergeAction => 'Fusionar';

  @override
  String get tagManagementMergeIntoAction => 'Fusionar en...';

  @override
  String tagManagementLoadError(String error) {
    return 'Error al cargar etiquetas: $error';
  }

  @override
  String get tagManagementRenameTitle => 'Renombrar etiqueta';

  @override
  String get tagManagementNewNameLabel => 'Nuevo nombre';

  @override
  String tagManagementRenameSuccess(String oldName, String newName) {
    return '\"$oldName\" renombrada a \"$newName\"';
  }

  @override
  String get tagManagementMergeSelectedTitle => 'Fusionar etiquetas seleccionadas';

  @override
  String get tagManagementChooseDestination => 'Elige la etiqueta de destino:';

  @override
  String tagManagementMergeSelectedSuccess(int count, String destination) {
    return '$count etiquetas fusionadas en \"$destination\"';
  }

  @override
  String get tagManagementDeleteSelectedTitle => 'Eliminar etiquetas seleccionadas';

  @override
  String tagManagementDeleteSelectedMessage(int count) {
    return '¿Eliminar $count etiquetas seleccionadas de todos los artículos?\n\nEsto no se puede deshacer.';
  }

  @override
  String tagManagementDeleteSelectedSuccess(int count) {
    return '$count etiquetas eliminadas';
  }

  @override
  String get tagManagementMergeIntoTitle => 'Fusionar en';

  @override
  String tagManagementMergeSuccess(String source, String target) {
    return '\"$source\" fusionada en \"$target\"';
  }

  @override
  String get tagManagementDeleteTitle => 'Eliminar etiqueta';

  @override
  String tagManagementDeleteMessage(String tagName) {
    return '¿Eliminar \"$tagName\" de todos los artículos?\n\nEsto no se puede deshacer.';
  }

  @override
  String tagManagementDeleteSuccess(String tagName) {
    return '\"$tagName\" eliminada';
  }

  @override
  String tagManagementMutationError(String error) {
    return 'Error al actualizar etiquetas: $error';
  }

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get statisticsEmptyTitle => 'Aún no hay estadísticas';

  @override
  String get statisticsEmptyMessage => 'Añade colecciones y artículos para ver información.';

  @override
  String get statisticsLoadingMessage => 'Cargando estadísticas...';

  @override
  String statisticsErrorLoading(String error) {
    return 'Error al cargar estadísticas: $error';
  }

  @override
  String get statisticsPortfolioValueTitle => 'Valor del portafolio';

  @override
  String statisticsAveragePricedItem(String value) {
    return 'Precio medio por artículo: $value';
  }

  @override
  String statisticsPricedItemsBadge(int priced, int total) {
    return 'Artículos con precio: $priced/$total';
  }

  @override
  String get statisticsQuantityTitle => 'Cantidad total';

  @override
  String get statisticsFavoritesTitle => 'Favoritos';

  @override
  String statisticsPercentOfItems(String percent) {
    return '$percent% de los artículos';
  }

  @override
  String get statisticsInventoryHealthTitle => 'Estado del inventario';

  @override
  String get statisticsValuationCoverageLabel => 'Cobertura de valoración';

  @override
  String statisticsPricedCaption(int priced, int total) {
    return '$priced de $total artículos tienen precio';
  }

  @override
  String get statisticsFavoritesCoverageLabel => 'Cobertura de favoritos';

  @override
  String statisticsFavoritesCaption(int favorites, int total) {
    return '$favorites de $total artículos son favoritos';
  }

  @override
  String get statisticsWishlistCoverageLabel => 'Cobertura de lista de deseos';

  @override
  String statisticsWishlistCaption(int wishlist, int total) {
    return '$wishlist de $total artículos están en la lista de deseos';
  }

  @override
  String get statisticsItemsByTypeTitle => 'Artículos por tipo';

  @override
  String get statisticsItemsByConditionTitle => 'Artículos por estado';

  @override
  String get statisticsTopValuedTitle => 'Colecciones con mayor valor';

  @override
  String get statisticsLargestCollectionTitle => 'Colección más grande';

  @override
  String get statisticsRecentlyCreatedTitle => 'Creadas recientemente';

  @override
  String statisticsRecentCollectionSubtitle(int itemCount, String createdAt) {
    return '$itemCount artículos • $createdAt';
  }

  @override
  String get statisticsNoChartData => 'No hay datos de gráfico disponibles';

  @override
  String get statisticsTotalLabel => 'Total';

  @override
  String get relativeToday => 'Hoy';

  @override
  String get relativeYesterday => 'Ayer';

  @override
  String relativeDaysAgo(int days) {
    return 'Hace $days días';
  }

  @override
  String relativeWeeksAgo(int weeks) {
    return 'Hace $weeks semanas';
  }

  @override
  String relativeMonthsAgo(int months) {
    return 'Hace $months meses';
  }

  @override
  String relativeYearsAgo(int years) {
    return 'Hace $years años';
  }

  @override
  String get collectionDetailsNotFoundTitle => 'Colección no encontrada';

  @override
  String get collectionDetailsNotFoundMessage => 'La colección seleccionada no está disponible.';

  @override
  String get collectionDetailsCreatedLabel => 'Creada';

  @override
  String get collectionDetailsUpdatedLabel => 'Última actualización';

  @override
  String get collectionDetailsLoading => 'Cargando colección...';

  @override
  String get collectionTypeBooks => 'Libros';

  @override
  String get collectionTypeGames => 'Juegos';

  @override
  String get collectionTypeMovies => 'Películas';

  @override
  String get collectionTypeComics => 'Cómics';

  @override
  String get collectionTypeMusic => 'Música';

  @override
  String get collectionTypeCustom => 'Personalizada';

  @override
  String get loanTrackingTitle => 'Seguimiento de préstamos';

  @override
  String get loanTrackingNewLoan => 'Nuevo préstamo';

  @override
  String get loanTrackingFilterActive => 'Activos';

  @override
  String get loanTrackingFilterHistory => 'Historial';

  @override
  String get loanTrackingEmptyHistoryTitle => 'Aún no hay préstamos devueltos';

  @override
  String get loanTrackingEmptyHistoryMessage => 'Los artículos devueltos aparecerán aquí.';

  @override
  String get loanTrackingEmptyActiveTitle => 'No hay préstamos activos';

  @override
  String get loanTrackingEmptyActiveMessage => 'Crea un préstamo para empezar a seguir artículos prestados.';

  @override
  String get loanTrackingLoadingLoans => 'Cargando préstamos...';

  @override
  String loanTrackingLoadFailed(String error) {
    return 'No se pudieron cargar los préstamos: $error';
  }

  @override
  String get loanTrackingMarkReturnedConfirmTitle => '¿Marcar como devuelto?';

  @override
  String loanTrackingMarkReturnedConfirmMessage(String itemTitle) {
    return 'Confirmar devolución de \"$itemTitle\".';
  }

  @override
  String get loanTrackingMarkReturnedAction => 'Marcar devuelto';

  @override
  String get loanTrackingMarkedReturnedSuccess => 'El préstamo se marcó como devuelto.';

  @override
  String loanTrackingMarkReturnedFailed(String error) {
    return 'No se pudo marcar la devolución: $error';
  }

  @override
  String get loanTrackingDeleteConfirmTitle => '¿Eliminar registro del préstamo?';

  @override
  String loanTrackingDeleteConfirmMessage(String itemTitle) {
    return 'Eliminar registro del préstamo de \"$itemTitle\".';
  }

  @override
  String get loanTrackingDeleteSuccess => 'Préstamo eliminado.';

  @override
  String loanTrackingDeleteFailed(String error) {
    return 'No se pudo eliminar el préstamo: $error';
  }

  @override
  String get loanTrackingSummaryActiveLabel => 'Préstamos activos';

  @override
  String get loanTrackingSummaryOverdueLabel => 'Vencidos';

  @override
  String get loanTrackingSummaryLoadFailed => 'No se pudo cargar el resumen de préstamos.';

  @override
  String get loanTrackingFieldBorrower => 'Prestatario';

  @override
  String get loanTrackingFieldContact => 'Contacto';

  @override
  String get loanTrackingFieldLoaned => 'Prestado';

  @override
  String get loanTrackingFieldDue => 'Vence';

  @override
  String get loanTrackingFieldReturned => 'Devuelto';

  @override
  String get loanTrackingStatusReturned => 'Devuelto';

  @override
  String get loanTrackingStatusOverdue => 'Vencido';

  @override
  String get loanTrackingStatusActive => 'Activo';

  @override
  String get loanTrackingCreateTitle => 'Crear préstamo';

  @override
  String get loanTrackingCreateDescription => 'Registra quién tomó un artículo prestado y cuándo debe devolverlo.';

  @override
  String get loanTrackingCreateNoItemsTitle => 'No hay artículos disponibles';

  @override
  String get loanTrackingCreateNoItemsMessage => 'Todos los artículos están prestados actualmente o aún no hay artículos.';

  @override
  String get loanTrackingCreateItemLabel => 'Artículo';

  @override
  String get loanTrackingCreateBorrowerLabel => 'Nombre del prestatario';

  @override
  String get loanTrackingCreateBorrowerHint => 'p. ej. Juan Pérez';

  @override
  String get loanTrackingCreateContactLabel => 'Contacto (opcional)';

  @override
  String get loanTrackingCreateContactHint => 'Teléfono, correo o @usuario';

  @override
  String get loanTrackingCreateNotesLabel => 'Notas (opcional)';

  @override
  String get loanTrackingCreateNotesHint => 'Detalles adicionales para este préstamo';

  @override
  String get loanTrackingCreateSubmitting => 'Creando...';

  @override
  String get loanTrackingCreateAction => 'Crear préstamo';

  @override
  String get loanTrackingLoadingItems => 'Cargando artículos...';

  @override
  String loanTrackingLoadItemsFailed(String error) {
    return 'No se pudieron cargar los artículos: $error';
  }

  @override
  String get loanTrackingBorrowerRequired => 'El nombre del prestatario es obligatorio.';

  @override
  String get loanTrackingCreateSuccess => 'Préstamo creado correctamente.';

  @override
  String loanTrackingCreateFailed(String error) {
    return 'No se pudo crear el préstamo: $error';
  }

  @override
  String get loanTrackingNoDueDate => 'Sin fecha de vencimiento';

  @override
  String get loanTrackingPickDateAction => 'Elegir';

  @override
  String get loanTrackingClearDateAction => 'Limpiar';

  @override
  String get loanTrackingDueDateLabel => 'Fecha de vencimiento';

  @override
  String get authTitleAccount => 'Cuenta';

  @override
  String get authCreateAccountHeading => 'Crear cuenta';

  @override
  String get authSignInHeading => 'Iniciar sesión';

  @override
  String get authCreateAccountDescription => 'Crea una cuenta para sincronizar tus colecciones entre dispositivos.';

  @override
  String get authSignInDescription => 'Inicia sesión para habilitar la sincronización en la nube y funciones de cuenta.';

  @override
  String get authSignInChoice => 'Iniciar sesión';

  @override
  String get authRegisterChoice => 'Registrarse';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authEmailHint => 'tu@ejemplo.com';

  @override
  String get authEmailRequiredError => 'El correo electrónico es obligatorio.';

  @override
  String get authEmailInvalidError => 'Introduce un correo electrónico válido.';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authPasswordHint => 'Mín. 8 caracteres, A-Z, a-z, 0-9';

  @override
  String get authPasswordRequiredError => 'La contraseña es obligatoria.';

  @override
  String get authPasswordLengthError => 'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get authPasswordPolicyError => 'La contraseña debe incluir mayúsculas, minúsculas y números.';

  @override
  String get authDisplayNameLabel => 'Nombre para mostrar (opcional)';

  @override
  String get authDisplayNameHint => '¿Cómo debemos llamarte?';

  @override
  String get authCreateAccountAction => 'Crear cuenta';

  @override
  String get authNotNowAction => 'Ahora no';

  @override
  String get authUnavailableMessage => 'La autenticación no está disponible en este momento.';

  @override
  String get authRegisterSuccess => 'Cuenta creada e inicio de sesión completado.';

  @override
  String get authSignInSuccess => 'Inicio de sesión exitoso.';

  @override
  String authSignInFailed(String error) {
    return 'Error al iniciar sesión: $error';
  }

  @override
  String get authSignedOut => 'Sesión cerrada.';

  @override
  String get authFinalConfirmationTitle => 'Confirmación final';

  @override
  String get authFinalConfirmationMessage => '¿Enviar solicitud de eliminación de cuenta ahora? Se cerrará la sesión de inmediato en este dispositivo.';

  @override
  String get authBackAction => 'Atrás';

  @override
  String get authSubmitRequestAction => 'Enviar solicitud';

  @override
  String get authDeletionRequestSubmitted => 'Solicitud de eliminación enviada. Se cerró tu sesión.';

  @override
  String get authDeletionEndpointMissing => 'El endpoint de solicitud de eliminación aún no está configurado en el backend.';

  @override
  String get authDeletionImpactDialogTitle => 'Antes de solicitar la eliminación de la cuenta';

  @override
  String get authDeletionImpactReviewPrompt => 'Revisa cuidadosamente el impacto.';

  @override
  String get authIrreversibleRequestTitle => 'Solicitud irreversible';

  @override
  String get authImpactLineSessionRevoked => 'La sesión de tu cuenta se revoca inmediatamente al solicitarla.';

  @override
  String get authImpactLineCloudDataDeleted => 'Los datos sincronizados en la nube vinculados a esta cuenta pueden eliminarse permanentemente durante el proceso.';

  @override
  String get authImpactLineCannotRestore => 'Los datos eliminados de la cuenta no se pueden restaurar una vez procesados.';

  @override
  String get authUnderstandAction => 'Entiendo';

  @override
  String get authPasswordPolicySuffix => 'Usa letras y dígitos del teclado en inglés (A-Z, a-z, 0-9).';

  @override
  String get authAccountConnected => 'Cuenta conectada';

  @override
  String get authSignedInReadySubtitle => 'Sesión iniciada y lista para sincronización en la nube';

  @override
  String get authActiveStatus => 'Activa';

  @override
  String get authSessionDetailsTitle => 'Detalles de la sesión';

  @override
  String get authUserIdLabel => 'ID de usuario';

  @override
  String get authDeviceIdLabel => 'ID del dispositivo';

  @override
  String get authUnknownValue => 'Desconocido';

  @override
  String get authDeletionNoticeTitle => 'Aviso de eliminación de cuenta';

  @override
  String get authDeletionNoticeSubtitle => 'Las solicitudes de eliminación son irreversibles una vez procesadas.';

  @override
  String get authDeletionNoticeLineProfileSessions => 'El perfil de la cuenta y las sesiones activas se eliminarán del acceso en la nube.';

  @override
  String get authDeletionNoticeLineSyncedData => 'Las colecciones, artículos, etiquetas y préstamos sincronizados pueden eliminarse permanentemente.';

  @override
  String get authRequestDeletionAction => 'Solicitar eliminación de cuenta';

  @override
  String get authSignOutAction => 'Cerrar sesión';

  @override
  String get authDoneAction => 'Listo';

  @override
  String get authHeaderCreateTitle => 'Crea tu cuenta';

  @override
  String get authHeaderWelcomeTitle => 'Bienvenido de nuevo';

  @override
  String get authHeaderCreateSubtitle => 'Las cuentas son opcionales, pero necesarias para sincronización en la nube y acceso multidispositivo.';

  @override
  String get authHeaderSignInSubtitle => 'Inicia sesión para acceder a sincronización en la nube y funciones de cuenta.';

  @override
  String get authUnavailableTitle => 'Autenticación no disponible';
}
