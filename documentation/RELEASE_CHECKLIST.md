# Play Store Release Checklist (Tailored)

Last updated: 2026-02-23

## Current App Snapshot (From Repo)

- App name: `Collectra`
- Android applicationId / package: `dev.mixin27.collection_tracker`
- Current app version: `1.0.1+2`
- Android icon entry: `@mipmap/launcher_icon`
- Android adaptive icon background: image asset (`@drawable/ic_launcher_background`)
- Firebase plugins enabled: Google Services + Crashlytics
- Release signing config: present in Android Gradle (uses `android/key.properties`)
- Privacy policy draft: present at `documentation/PRIVACY_POLICY.md` (placeholders still need replacement)
- Store listing draft: present at `documentation/PLAY_STORE_LISTING.md`

## Release Readiness Checklist

- [x] App ID is stable: `dev.mixin27.collection_tracker`.
- [x] Release signing config is wired in `apps/mobile/android/app/build.gradle.kts`.
- [x] Keystore files exist locally (`apps/mobile/android/collection-tracker-keystore.jks`, `apps/mobile/android/key.properties`).
- [x] App icon + adaptive icon assets are generated and committed from brand pipeline.
- [x] Feature graphic exists at `apps/mobile/assets/branding/play_store_feature_graphic.png`.
- [x] Crashlytics plugin is integrated in Android build.
- [x] Privacy policy markdown exists.
- [x] Play Store metadata draft exists.
- [x] Account deletion request flow exists in auth UI/backend service.
- Replace placeholders in `documentation/PRIVACY_POLICY.md`:
- [ ] `{{LEGAL_ENTITY_NAME}}`
- [ ] `{{SUPPORT_EMAIL}}`
- [ ] `{{WEBSITE_URL}}`
- [ ] `{{JURISDICTION}}`
- [ ] Publish privacy policy to a public HTTPS URL and add it in Play Console.
- [ ] Confirm support email + website are set in Play Console listing.
- [ ] Complete Data safety form to match actual behavior and permissions.
- [ ] Complete Content rating questionnaire.
- [ ] Confirm app category and tags in Play Console (recommended: Productivity).
- [ ] Upload screenshots and verify they match latest UI.
- [ ] Run pre-release QA on physical Android devices (small + large screens).
- [ ] Build and upload signed `.aab` to Internal testing first.
- [ ] Review Pre-launch report issues and resolve blockers.
- [ ] Roll out to production using staged rollout.

## Policy-Focused Checks

- [ ] Verify target SDK requirement for current Play deadline (new uploads/updates).
- [ ] Verify native dependency compatibility with Android 16 KB page size requirement.
- Confirm account deletion request path is available to reviewers:
- [ ] In-app navigation path
- [ ] Alternate support contact path
- [ ] Ensure privacy policy text matches real Firebase/runtime-feature-flag behavior.

## Android Permissions Review (Manifest)

Current manifest declares:

- `android.permission.CAMERA`
- `android.permission.READ_EXTERNAL_STORAGE` (maxSdkVersion 32)
- `android.permission.WRITE_EXTERNAL_STORAGE` (maxSdkVersion 32)
- `android.permission.READ_MEDIA_IMAGES`
- `android.permission.INTERNET`
- `android.permission.POST_NOTIFICATIONS`

Before production:

- [ ] Ensure each permission has a user-facing feature justification in store listing/privacy text.
- [ ] Ensure permission prompts are contextual and not requested unnecessarily.

## Build Commands

No `--dart-define` is required for a release build, unless you want runtime overrides.

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build appbundle --release
```

Output artifact:

- `apps/mobile/build/app/outputs/bundle/release/app-release.aab`

Optional example with quoted `--dart-define`:

```bash
flutter build appbundle --release \
  --dart-define='APP_UPDATE_STORE_URL_ANDROID=https://play.google.com/store/apps/details?id=dev.mixin27.collection_tracker'
```

## Release Gate (Go/No-Go)

- [ ] Crash-free smoke test completed on release build.
- [ ] Sync/auth/notifications/import-export basic paths validated.
- [ ] Privacy policy URL live and reachable.
- [ ] Data safety + content rating completed.
- [ ] Internal testing upload successful.
- [ ] Production staged rollout plan approved.
