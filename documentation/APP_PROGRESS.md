# App Progress

Last updated: 2026-02-22

## Status Legend

- Complete: implemented and wired into the main app flow
- In Progress: partially implemented, usable but still evolving
- Planned: not implemented yet

## Feature Matrix

| Area | Status | Notes |
| --- | --- | --- |
| Onboarding | In Progress | Multi-page onboarding exists but still has hardcoded copy and limited localization. |
| Collection management | Complete | Create/edit/delete collections, list and grid modes, action sheets, and summary metrics. |
| Collection detail -> items | Complete | Open collection to items screen with responsive list/grid support. |
| Item CRUD | Complete | Add/edit/delete items with metadata fields, image, quantity, condition, favorite/wishlist. |
| Item detail UX | Complete | Rich detail layout, quick actions, tags section, notes, and value insights. |
| Price tracking | Complete | Purchase/current value support plus historical chart points from local DB history. |
| Favorites and wishlist | Complete | Dedicated shell tabs with global item streams. |
| Search | In Progress | Collection-level search exists, currently simple title matching and partial localization coverage. |
| Barcode scanner | In Progress | Camera scan flow implemented; UI text and polish are still being localized/polished. |
| Tags system | Complete | Tag assignment, tag list with usage, rename/merge/delete, bulk multi-select actions. |
| Tag item drill-down | Complete | Tag -> grouped items by collection with per-collection open action. |
| Statistics | Complete | Portfolio value, health ratios, distribution charts, top-valued/recent/largest collection insights. |
| Import/export | Complete | JSON import/export and CSV export, integrated in settings. |
| Display preferences | Complete | Theme mode, theme variant, AMOLED option, collections/items view modes persisted. |
| Localization framework | Complete | `gen_l10n` setup with ARB files and language switcher in settings. |
| Localization coverage | In Progress | Most core flows localized; some screens still contain hardcoded English strings. |
| Custom design system | Complete | Reusable primitives (`AppButton`, `AppCard`, `AppInput`, `AppSheet`, `AppReveal`, etc.). |
| Glass bottom navigation | Complete | Custom stacked shell navigation (not `Scaffold.bottomNavigationBar`) with motion. |
| Firebase Core integration | Complete | Firebase bootstrap and options-based initialization wired at app startup. |
| Crashlytics | Complete | Global Flutter and platform error capture with runtime collection toggle support. |
| Analytics + consent | Complete | Consent gate, persistent preferences, provider-based enable/disable, auto screen tracking. |
| Remote Config runtime flags | Complete | Runtime config fetch/activate with app resume auto-refresh and status tracking. |
| Firebase Performance | Complete | Trace helpers used in export/import and sync orchestration points. |
| Operational telemetry | Complete | Local history + analytics/crashlytics logging for sync/data/runtime operational events. |
| Optional backend auth | Complete | Sign in/register/logout + secure session storage, optional for non-sync users. |
| Sync v1 (collections/items/tags) | In Progress | Outbox + push/pull + server apply + retries implemented; still feature-flag gated for rollout. |
| Sync production rollout | Planned | Feature currently gated by remote config and local readiness checks. |

## Known Gaps and Risks

- Some UI copy remains hardcoded in English (notably parts of onboarding, scanner, auth, and search).
- Sync currently covers collections, items, and tags; non-entity preferences are local-only.
- Search currently uses straightforward SQL `LIKE` matching and is not yet a global semantic search.
- Integration test coverage for advanced sync conflict edge cases is still limited.

## Recommended Next Work

1. Finish localization coverage for remaining hardcoded strings.
2. Harden sync rollout with deeper integration tests (conflicts, duplicate operations, offline replay).
3. Add stronger product analytics dashboards/events around onboarding -> auth -> sync funnel.
