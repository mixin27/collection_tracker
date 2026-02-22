# Localization

This app uses Flutter `gen_l10n` with ARB files and runtime language selection.

## 1. Current Supported Locales

| Language | Code | ARB file |
| --- | --- | --- |
| English | `en` | `apps/mobile/lib/l10n/arb/app_en.arb` |
| Spanish | `es` | `apps/mobile/lib/l10n/arb/app_es.arb` |
| Indonesian | `id` | `apps/mobile/lib/l10n/arb/app_id.arb` |
| Japanese | `ja` | `apps/mobile/lib/l10n/arb/app_ja.arb` |
| Korean | `ko` | `apps/mobile/lib/l10n/arb/app_ko.arb` |
| Burmese | `my` | `apps/mobile/lib/l10n/arb/app_my.arb` |
| Chinese (Simplified) | `zh` | `apps/mobile/lib/l10n/arb/app_zh.arb` |

## 2. Generation Config

`apps/mobile/l10n.yaml`:

- `arb-dir: lib/l10n/arb`
- `template-arb-file: app_en.arb`
- output: `lib/l10n/gen/app_localizations.dart`

Generate localizations:

```bash
cd apps/mobile
flutter gen-l10n
```

## 3. Runtime Language Selection

- Language enum/provider: `apps/mobile/lib/core/providers/locale_provider.dart`
- Preference key: `app_language`
- Settings screen allows switching at runtime

## 4. Metadata Requirement (Important)

To avoid ARB warnings such as:

- `The message with key "..." does not have metadata defined.`

Add corresponding metadata entries for each message key:

- `"myKey": "..."`
- `"@myKey": { "description": "..." }`

Using empty metadata objects is technically possible, but descriptions are recommended for maintainability.

## 5. Current Coverage Notes

Localized coverage is broad across main flows (collections/items/statistics/settings), but some screens still contain hardcoded English strings and should be migrated to l10n keys.

Primary areas still needing cleanup:

- Onboarding copy
- Scanner copy
- Some auth and search screen strings
- Some developer/debug-only text

## 6. UI Overflow Guidance for Long Translations

Compact devices and long strings can cause overflow. Current mitigation patterns used in app:

- `maxLines: 1` + `TextOverflow.ellipsis` on navigation labels and chips
- responsive `crossAxisCount` and tile heights in grids
- conservative text scaling logic in custom navigation components

When adding new localized strings, verify layouts on:

- Android physical compact phones
- iOS simulator with larger text scale

## 7. Adding a New Language

1. Add `app_<code>.arb` under `apps/mobile/lib/l10n/arb/`.
2. Translate all required keys and keep `@metadata` entries.
3. Run `flutter gen-l10n`.
4. Add language option to `AppLanguage` in `locale_provider.dart`.
5. Add display label in settings language selector.
6. Verify navigation labels, bottom sheets, and grids for overflow.
