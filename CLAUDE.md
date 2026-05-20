# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

MyRate — Flutter mobile app (Android/iOS): an ad-free currency converter built on the ExchangeRate-API. Korean/English with system-following dark mode. No analytics, no tracking SDKs (this is a core product differentiator — do not add Firebase Analytics, AdMob, Crashlytics, etc.).

Dart package name is `myrate` (pubspec); folder name `my-rate` is dash-form only because Dart identifiers cannot contain dashes.

## Common commands

```bash
# First-time / after dependency changes
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed + riverpod codegen

# Run dev build — API key MUST be injected at compile time
./scripts/run.sh                                            # reads .env, runs flutter run --dart-define-from-file=.env
flutter run --dart-define=EXCHANGE_RATE_API_KEY=<key>       # equivalent inline

# Codegen watch while iterating on @freezed / @Riverpod classes
dart run build_runner watch --delete-conflicting-outputs

# Tests
flutter test                                                # all unit/widget tests
flutter test test/features/converter/logic/conversion_test.dart   # single file
flutter test --name "swap"                                  # single test by name regex
flutter test integration_test/app_test.dart                 # widget-level integration test (runs in unit harness)

# Static analysis
flutter analyze                                             # strict-casts / strict-inference / strict-raw-types enabled
```

`.env` is gitignored. Copy `.env.example` and fill in `EXCHANGE_RATE_API_KEY` (free plan: 1500 req/month at https://www.exchangerate-api.com/sign-up).

## Architecture

### Layering (`lib/`)

```
domain/       Pure-Dart models (freezed) + repository interfaces. No Flutter/IO deps.
data/         Repository impls; remote (Dio + ExchangeRate-API), local (SharedPreferences stores);
              DTOs (json_serializable); Riverpod providers wiring it all up.
features/     UI + feature-local notifiers, grouped by screen (converter, currency_picker, settings).
core/         Routing (go_router), theme, generated l10n, AppException hierarchy, utils, constants.
```

The dependency rule is one-way: `features → data → domain`, with `core` as cross-cutting. Don't import upward (e.g. domain importing data).

### State management — Riverpod codegen

All providers/notifiers use `@Riverpod` / `@riverpod` from `riverpod_annotation`. After editing any annotated class you **must** run build_runner — the `.g.dart` next to each provider file is required and is checked in.

`@freezed` data classes (in `domain/`) emit `.freezed.dart` siblings, also checked in. `.g.dart` and `.freezed.dart` are excluded from analyzer and gitignored only for `lib/core/l10n/generated/` (the rest are tracked).

`keepAlive: true` is used for app-scoped singletons (`sharedPreferences`, `dio`, `currencyCatalog`, repositories, `SettingsNotifier`). Feature notifiers (e.g. `ConverterNotifier`) are autoDispose by default.

### API key injection

The ExchangeRate-API key is read via `String.fromEnvironment('EXCHANGE_RATE_API_KEY')` in `lib/data/exchange_rate/providers.dart`. This is a **compile-time** constant — you cannot read it from a runtime `.env` loader. Always use `--dart-define` or `--dart-define-from-file=.env`. The repo's `scripts/run.sh` enforces the .env path.

### Repository fallback semantics (important)

`ExchangeRateRepositoryImpl.getLatest` in `lib/data/exchange_rate/exchange_rate_repository_impl.dart` implements specific fallback rules — preserve them when refactoring:

1. Fresh cache (`now <= apiNextUpdateAt`) and not `forceRefresh` → return cached.
2. API call succeeds → save + return new snapshot.
3. `NetworkException` (timeouts, connection errors) + cache exists → return cached snapshot (caller surfaces `isStale=true`).
4. `NetworkException` + no cache → rethrow with `hasCache: false`.
5. `ApiException` (HTTP 4xx/5xx) + cache exists → return cached.
6. `InvalidApiKeyException` → **always rethrow**, never fall back to cache (it's a developer/config error, not a transient failure).

`ExchangeRateSnapshot.isStaleAt(now)` is `now.isAfter(apiNextUpdateAt)`. Cross-rate conversion (non-USD base → non-USD target) is computed in `lib/features/converter/logic/conversion.dart` via `toRate / fromRate`.

### Localization

ARB sources: `lib/core/l10n/app_{en,ko}.arb`. The `intl` tool regenerates `lib/core/l10n/generated/app_localizations*.dart` on each Flutter build (driven by `l10n.yaml`). The generated directory is gitignored, so don't hand-edit those files — edit the ARBs and rebuild. Use `AppLocalizations.of(context)!.someKey` in widgets.

Locale resolution is overridden in two places (`lib/app.dart` and `AppSettings.flutterLocale`) so that `'system'` language correctly picks ko when the device locale list contains it — Flutter's default fallback otherwise drops to `en` for some locale lists. Preserve this override behavior.

### Currency catalog

`assets/currencies.json` (declared in `pubspec.yaml`) is the source of truth for currency display names, flags, decimal places, and short labels. Loaded once via `CurrencyCatalog.load()` and cached in the `currencyCatalog` provider. The ExchangeRate-API returns ~161 currency codes; codes not in the catalog fall back to a default `Currency(code, code, '', 2, code)` shape.

### Persistence keys

All `SharedPreferences` keys are namespaced by their store class — don't read/write prefs directly:
- `RateCache` — prefix `cache.rates.` per base currency
- `FavoritesStore` — favorite currency codes
- `SettingsStore` — defaultFrom / defaultTo / language / themeMode

### Routing

`go_router` is configured in `lib/core/routing/app_router.dart`. Three routes only: `/`, `/picker`, `/settings`. The picker takes a `CurrencyPickerArgs` via `extra` (callback-based — the picker doesn't know which slot it's editing).

## Conventions

- `analysis_options.yaml` enforces strict-casts/inference/raw-types and these lints: `prefer_single_quotes`, `require_trailing_commas`, `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `avoid_print`, `sort_child_properties_last`. Generated files (`**/*.g.dart`, `**/*.freezed.dart`, `**/generated/**`) are excluded.
- Use `debugPrint` (or proper logging) — never `print`.
- UI strings always go through `AppLocalizations`; never hardcode user-visible text.
- New `Currency`/state shapes go in `domain/` as `@freezed` classes; never put `package:flutter` imports there.
- New providers use the `@Riverpod` annotation form (not `Provider(...)` constructors).

## Docs

Design and implementation history live under `docs/superpowers/`:
- `docs/superpowers/specs/2026-05-12-myrate-design.md` — original design spec
- `docs/superpowers/plans/2026-05-12-myrate.md` — implementation plan
- `TEST_REPORT.md`, `QA_REPORT.md` at the repo root — test/QA snapshots
