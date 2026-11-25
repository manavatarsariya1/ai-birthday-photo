# Project Rules & Development Guidelines (Flutter GetX Master Boilerplate)

These rules are **MANDATORY** and must be strictly followed for every prompt, feature, refactoring, and code change in this project. No exceptions.

---

## 1. Architecture & Separation of Concerns

* **Business Logic (Controllers)**:
  * ALL business logic, state management, API calls, event handlers, validation logic, and reactive variables MUST be placed inside `*_controller.dart` files located under `lib/controllers/` (or feature-specific subfolders, e.g. `lib/controllers/splash/`, `lib/controllers/home/`).
  * Controllers must extend `GetxController`.
  * **Rule**: NEVER write business logic, HTTP requests, or complex state mutation inside UI/Screen files.

* **Presentation Logic (Screens & Views)**:
  * ALL UI layouts, widgets, animations, and visual presentation MUST be placed inside `*_screen.dart` (or `*_view.dart`) files under `lib/ui/`.
  * Screens should only observe controller state (`Obx`, `GetBuilder`, or controller getters) and trigger controller methods on user actions.

* **Routing**:
  * All navigation routes MUST be declared in `lib/routes/app_routes.dart` and registered in `lib/routes/app_pages.dart`.
  * Do NOT create redundant `*_binding.dart` files unless strictly needed; keep the clean, simple controller + view GetX structure.

---

## 2. Models & Data Layer

* ALL models (JSON serializable models, response models, DTOs, Ad configs, Remote Config models, entities) MUST strictly reside in the `lib/data/models/` directory.
* **Rule**: NEVER define model classes inside UI or Controller files. Always separate them into dedicated model files inside `lib/data/models/`.

---

## 3. Common Widgets & Reusability (`lib/utils/`)

* Whenever possible, **ALWAYS reuse existing common widgets** from `lib/utils/`:
  * `CommonButton` (`CommonButton.primary`, `CommonButton.outline`, `CommonButton.small`)
  * `CommonSegmentedTab`
  * `CommonCard`
  * `CommonAppBar`
  * `CommonTextField`
  * `CommonLoader`
  * `CommonImage`
  * `CommonSvgImage`
  * `CommonCircularSvg`
  * `CommonSwitch`
  * `CommonNoData`
  * `CommonDropDown`
  * `AppToast`
* If a new reusable widget is needed across multiple screens or components, create it cleanly inside `lib/utils/` and export it in `lib/utils/config_packages.dart`.

---

## 4. Buttons Usage (STRICT COMPLIANCE)

* **CommonButton Widget**:
  * NEVER use Flutter's raw `ElevatedButton`, `TextButton`, `OutlinedButton`, `CupertinoButton`, or manual button containers with `GestureDetector` directly in screen files.
  * **ALWAYS use `CommonButton`** from `lib/utils/common_button.dart`:
    * `CommonButton.primary(onTap: ..., title: AppStrings.someTitle)` for standard full-width action buttons.
    * `CommonButton.outline(onTap: ..., title: AppStrings.someTitle)` for outlined secondary buttons.
    * `CommonButton.small(onTap: ..., title: AppStrings.someTitle)` for compact card/action buttons.
    * `CommonButton(onTap: ..., title: AppStrings.someTitle, ...)` for customized button variations.
  * Example:
    ```dart
    // ❌ FORBIDDEN:
    ElevatedButton(onPressed: () {}, child: Text('Submit'))
    CupertinoButton(child: Container(...), onPressed: () {})

    // ✅ REQUIRED:
    CommonButton.primary(
      onTap: controller.onSubmit,
      title: AppStrings.submit,
    )
    ```

---

## 5. Text Display & Strings (STRICT COMPLIANCE)

* **CommonText Widget**:
  * For displaying text in the UI, NEVER use Flutter's default `Text()` widget directly.
  * **ALWAYS use `CommonText.text(...)`** or `CommonText.marqueeText(...)` from `lib/utils/common_text.dart`.
* **No Hardcoded Strings**:
  * NEVER write hardcoded/static string literals for any user-facing text (e.g. titles, labels, placeholders, button texts, error messages, toast messages).
  * **EVERY string displayed to the user MUST be defined in `lib/constant/app_strings.dart`** as a `static String get <key> => '<key>'.tr;` under `AppStrings`.
  * Example:
    ```dart
    // ❌ FORBIDDEN:
    Text('Submit Application')
    CommonText.text(title: 'Submit Application')

    // ✅ REQUIRED:
    // In lib/constant/app_strings.dart:
    // static String get submit => 'submit'.tr;
    // In UI:
    CommonText.text(title: AppStrings.submit)
    ```

* **Mandatory Localization Across Languages**:
  * Whenever creating or adding ANY string in `AppStrings`:
    1. Define the getter with `.tr` in `lib/constant/app_strings.dart`: `static String get myKey => 'myKey'.tr;`.
    2. Add the key and its translated value in `lib/localization/languages/*.dart` (`english.dart`, etc.) to maintain parity.

---

## 6. Color Palette & Theming (STRICT COMPLIANCE)

* **No Hardcoded Colors**:
  * NEVER hardcode color values (e.g. `Color(0xFF123456)`, `Colors.white`, `Colors.blue`) directly in UI widgets.
  * **ALWAYS use colors from `lib/theme/app_colors.dart` (`AppColors`)**.
* **Adding New Colors**:
  * If a required color is not present in `AppColors`, you MUST first add it to `lib/theme/app_colors.dart`, and then use it via `AppColors.<colorName>`.

---

## 7. Assets Management (STRICT COMPLIANCE)

* **No Hardcoded Asset Paths**:
  * NEVER write hardcoded asset path strings in UI widgets (e.g. `'assets/images/logo.png'`).
* **AppAssets Registration**:
  * Every asset (image, SVG, icon, Lottie animation, audio, video) MUST be registered as a `static const String` in `lib/constant/app_assets.dart` under `AppAssets`.
  * Always use assets via `AppAssets.<assetName>`.
  * Example:
    ```dart
    // ❌ FORBIDDEN:
    SvgPicture.asset('assets/icons/ic_home.svg')

    // ✅ REQUIRED:
    // In lib/constant/app_assets.dart:
    // static const String icHome = 'assets/icons/ic_home.svg';
    // In UI:
    CommonSvgImage(imagePath: AppAssets.icHome)
    ```

---

## 8. Responsiveness & Dimensions (ScreenUtil Strict Rules)

* **No Raw Numeric Dimensions**:
  * NEVER use raw, hardcoded pixel numbers directly without ScreenUtil extensions.
* **MANDATORY ScreenUtil Extensions**:
  * Widths, horizontal margins & horizontal padding: ALWAYS use `.w` (e.g. `16.w`, `SizedBox(width: 12.w)`)
  * Heights, vertical margins & vertical padding: ALWAYS use `.h` (e.g. `24.h`, `SizedBox(height: 20.h)`)
  * Font sizes: ALWAYS use `.sp` (e.g. `fontSize: 16.sp`)
  * Border radius & icon dimensions: ALWAYS use `.r` (e.g. `BorderRadius.circular(12.r)`)
  * Example:
    ```dart
    // ❌ FORBIDDEN:
    Container(width: 100, height: 50, padding: EdgeInsets.all(16))

    // ✅ REQUIRED:
    Container(
      width: 100.w,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
    )
    ```

---

## 9. Central Barrel Imports (`config_packages.dart`)

* **Single Consolidated Import**:
  * Instead of importing 10–15 individual packages, themes, and utility files at the top of every file, **ALWAYS prefer importing the central barrel export**:
    ```dart
    import 'package:flutter_getx_project_structure/utils/config_packages.dart';
    // OR relative import:
    // import '../utils/config_packages.dart';
    ```
  * `config_packages.dart` already exposes `GetX`, `ScreenUtil`, `FlutterSvg`, `SharedPreferences`, all common widgets, themes, and constants.

---

## 10. Logging & Debugging (No Raw Print Statements)

* **No Raw `print()` in Production Code**:
  * NEVER use `print('...')` in production code, controllers, or services.
* **Logging Standard**:
  * Use `kDebugMode` or `debugPrint('...')` / `log()` for debugging output to prevent leaking logs or slowing down production builds:
    ```dart
    // ❌ FORBIDDEN:
    print('API Error: $e');

    // ✅ REQUIRED:
    if (kDebugMode) {
      debugPrint('API Error: $e');
    }
    ```

---

## 11. Iteration & Collections: Production-Grade Declarative Approach

* **No Imperative Legacy `for` Loops**:
  * NEVER use primitive imperative `for (var i = 0; i < len; i++)` or manual `for (var item in list)` mutation loops for transforming, mapping, filtering data, or generating widget lists.
* **MANDATORY Declarative Approach**:
  * **Data Transformation & Mapping**: ALWAYS use functional higher-order methods:
    * `.map((item) => ...)`, `.where(...)`, `.fold(...)`, `.expand(...)`, `.any(...)`, `.every(...)`, `.reduce(...)`
  * **UI / Widget Trees**:
    * For small fixed lists/rows, use declarative `.map().toList()` or clean collection-`if` / collection-`for`.

---

## 12. Lazy Loading & Viewport Recycling

* **No `List.generate` for Scrollable Views**:
  * NEVER use `List.generate` inside `ListView(children: ...)` or `GridView.count(children: List.generate(...))` or `SingleChildScrollView(child: Column(children: List.generate(...)))` for dynamic or scrollable lists.
* **MANDATORY Builder Pattern**:
  * **Lists**: ALWAYS use `ListView.builder` or `ListView.separated` with `physics: const ClampingScrollPhysics()`.
  * **Grids**: ALWAYS use `GridView.builder` with `physics: const ClampingScrollPhysics()`.

---

## 13. Analytics & Event Tracking (`LogEventManager` Strict Rules)

* **Mandatory Simultaneous Event Implementation**:
  * Whenever creating or updating ANY screen, controller, dialog, bottom sheet, or user flow, simultaneously add and invoke corresponding analytics events in `lib/services/log_event_manager.dart`.
* **Standard Event Naming Conventions**:
  * **Screen Views (`_view`)**:
    * Fired when the user lands on any screen (e.g. `splash_view`, `home_view`, `paywall_view`, `settings_view`).
  * **Button & Action Clicks (`_click`)**:
    * Fired whenever the user taps any action button, card, tab, or interactive item:
      * `<screen_name>_<action>_click` (e.g. `home_action_click`, `paywall_subscribe_click`).
  * **Back Navigation (`_back_click`)**:
    * Fired whenever the user presses a back button or back trigger:
      * `<screen_name>_back_click` (e.g. `home_back_click`, `paywall_back_click`).
* **Rule**: Never use generic names like `button_click` without distinct event identifiers.

---

## 14. Ads Architecture & STRICT TEST AD UNIT IDS (CRITICAL)

* **TEST ADS ONLY IN TEMPLATE & SOURCE CODE**:
  * ALL fallback ad IDs in `ADHelper.dart` and `RemoteConfigService.dart` MUST strictly be Google's official Test Ad Unit IDs:
    * **Android App Open**: `ca-app-pub-3940256099942544/9257395921`
    * **Android Banner**: `ca-app-pub-3940256099942544/6300978111`
    * **Android Interstitial**: `ca-app-pub-3940256099942544/1033173712`
    * **Android Rewarded**: `ca-app-pub-3940256099942544/5224354917`
    * **Android Native Advanced**: `ca-app-pub-3940256099942544/2247696110`
    * **iOS App Open**: `ca-app-pub-3940256099942544/5575463023`
    * **iOS Banner**: `ca-app-pub-3940256099942544/2934735716`
    * **iOS Interstitial**: `ca-app-pub-3940256099942544/4411468910`
    * **iOS Rewarded**: `ca-app-pub-3940256099942544/1712485313`
    * **iOS Native Advanced**: `ca-app-pub-3940256099942544/3986624511`
  * **NEVER hardcode production/live AdMob IDs in Dart source files.**
  * Live Ad IDs must ONLY come dynamically via Firebase Remote Config in production!
* **Suppression Rule**:
  * ALWAYS call `ADService.suppressBackgroundOpenAdFor()` before launching external intents (Camera, ImagePicker, In-App Purchase, URL launcher, System Share).

---

## 15. Revenue Threshold Manager (Taichi Model & tROAS)

* Whenever an Ad is displayed, capture `onPaidEvent` (`valueMicros`, `currencyCode`, `precisionType`).
* Process revenue through `RevenueThresholdManager.processAdRevenue(revenueUsd)` to track daily and lifetime thresholds.
* Automatically fire `taichi_revenue_milestone` to Firebase Analytics and Meta App Events when daily milestones ($0.01, $0.05, $0.10, $0.50, $1.00) are reached to optimize ad spend campaigns.

---

## 16. Backend API Layer (`ApiService`)

* **No Raw HTTP Calls in Controllers or Screens**:
  * NEVER call `http.get` / `http.post` or construct manual headers directly inside controllers or UI files.
  * ALWAYS use `ApiService` from `lib/services/api_service.dart`.
* **Automatic Header & Token Injection**:
  * `ApiService` automatically attaches Bearer Token, `x-platform`, `x-app-version`, and `x-device-id`.
* **Pretty Box Logging**:
  * In debug mode, `ApiService` prints structured, human-readable request and response boxes for instant inspection.

---

## 17. Checklist When Starting a New Project from this Boilerplate

1. **Rename Package in `pubspec.yaml`**:
   Change `name: flutter_getx_project_structure` to `name: your_app_name`.
2. **Update Native Bundle IDs**:
   - Android: `applicationId` in `android/app/build.gradle` and namespace in `android/app/build.gradle`.
   - iOS: `PRODUCT_BUNDLE_IDENTIFIER` in Xcode / `project.pbxproj`.
3. **Add Firebase Credentials**:
   - Place `google-services.json` in `android/app/`.
   - Place `GoogleService-Info.plist` in `ios/Runner/`.
4. **Update App Constants (`lib/constant/app_constant.dart`)**:
   - Update `appName`, `appVersion`, `baseUrlLive`, and `baseUrlDev`.
5. **Add Feature Screens & Controllers**:
   - Create new controllers under `lib/controllers/<feature>/`.
   - Create new screens under `lib/ui/<feature>/`.
   - Register routes in `lib/routes/app_routes.dart` and `lib/routes/app_pages.dart`.
