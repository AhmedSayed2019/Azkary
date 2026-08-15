# /refactor — Feature Migration Agent

User request: $ARGUMENTS

You are the **Refactor Agent** for the Gomla Flutter app. You migrate a legacy feature
into `lib/features/refactor/<feature>/` as a complete, clean-architecture vertical slice —
data + domain + presentation + routes + DI + tests — with every file fully implemented.

> **Migrate, never restore.** Old code under `lib/features/<feature>/` (non-refactor) is a
> *reference only*. Read it to learn the API shape, endpoints, and business rules, then
> rewrite it to the rules below. Never uncomment, copy verbatim, or re-wire legacy widgets.
> "Copy old code" means *port the logic*, not the old style.

---

## Step 1 — Read context before writing a single line

Run these reads in parallel, every time:

1. `AGENT.md` (project root) — architecture + style baseline.
2. The legacy feature being migrated — `lib/features/<feature>/` (the source of truth for
   endpoints, request/response shape, and business rules).
3. The canonical full-feature reference (the most complete migrated slice):
   - `lib/features/refactor/my_rewards/data/datasource/remote/my_rewards_remote_datasource.dart`
   - `lib/features/refactor/my_rewards/data/repository/my_rewards_repository_imp.dart`
   - `lib/features/refactor/my_rewards/domain/usecase/get_reward_center_use_case.dart`
   - `lib/features/refactor/my_rewards/presentation/my_rewards_view_model.dart`
   - `lib/features/refactor/my_rewards/presentation/screens/my_rewards_screen.dart`
   - `lib/features/refactor/my_rewards/presentation/injection.dart`
4. Routing reference: `lib/features/refactor/products/products_routes.dart` +
   `lib/features/refactor/products/presentation/route_generator.dart`.
5. The style layer — `lib/core/res/` (read the ones you'll touch):
   `color.dart`, `values_manager.dart`, `font_manager.dart`, `decoration.dart`,
   `text_styles.dart`, `theme_helper.dart`, `responsive_service.dart`. Most are re-exported from
   the barrel `lib/core/res/resources.dart` (import that, not the individuals). The `.sp` font
   helper already lives in `font_manager.dart` (so it's in the barrel); import
   `responsive_service.dart` directly only for raw `scaleWidth/Height/Radius` calls.
6. The shared state/sheet widgets you must reuse (read before using — see Step 4 table):
   `lib/core/widgets/screen_state_layout.dart`, `shimmer_skeleton.dart`, `empty_state.dart`,
   `not_auth_status_layout.dart`, and `lib/base/presentation/sheet/custom_modal_sheet.dart`.

> ⚠️ The reference files show the **structure** to follow. Some (e.g. `my_rewards_screen.dart`)
> still contain `flutter_screenutil` (`.sp`) and raw `FontWeight.w600` — those are **legacy
> leftovers and are NOT to be copied**. The UI rules in Step 4 override them.

---

## Step 2 — Parse the request

From `$ARGUMENTS` extract:
- **Feature name** (folder under `refactor/`, e.g. `wallet`, `orders`).
- **Scope**: full feature migration, or one layer (e.g. "just the data layer"), or one screen.
- **Source**: which legacy folder/files to port from.
- **Endpoints**: API paths + method + response shape (from the legacy datasource/repository).
- **Screens/dialogs** needed and their states (list, detail, form, etc.).

If the feature folder, source, or endpoints can't be inferred, ask **one** focused question
listing every missing item together. Do not ask in multiple rounds.

---

## Step 3 — Layer layout (create every file)

```
lib/features/refactor/<feature>/
├── data/
│   ├── datasource/remote/<feature>_remote_datasource.dart   # Dio calls + URL constants (abstract <Feature>URLs)
│   ├── model/<name>_model.dart                              # DTO: fromJson + toEntity()
│   └── repository/<feature>_repository_imp.dart             # implements domain repo; delegates to datasource
├── domain/
│   ├── entity/<name>_entity.dart                            # pure Dart; + `static get shimmerSeed` for shimmer
│   ├── parameters/<feature>_parameters.dart                 # input objects for use cases (when needed)
│   ├── repository/<feature>_repository.dart                 # abstract contract, returns ApiResult<T>
│   └── usecase/<verb>_<feature>_use_case.dart               # one op per class, `call(...)`
├── presentation/
│   ├── modules/
│   │   └── <module_name>/            # ONE folder per screen — screen + VM + widgets co-located
│   │       ├── <module>_screen.dart
│   │       ├── <module>_view_model.dart   # factory VM lives here (NOT in parent folder)
│   │       └── widgets/
│   │           └── <widget>.dart
│   ├── injection.dart                # init<Feature>RefactorFeatures()
│   └── route_generator.dart          # <Feature>RouteGenerator.routes (List<GoRoute>)
└── <feature>_routes.dart             # path constants (separate routes file)
```

> **`modules/` rule:** Never use a `screens/` subfolder. Each screen lives in its own
> `modules/<name>/` directory together with its ViewModel and its widgets. Multiple screens
> in the same feature = multiple subfolders under `modules/`. There is no separate top-level
> `widgets/` or `screens/` folder under `presentation/` — everything lives inside `modules/`.

### Layer rules (hard constraints)
- **Data** knows Dio + DTOs. Wraps every call in `try { … } on DioException`. Returns
  `ApiResult<T>` via `ApiHelper.check(...)` on success and `ApiChecker.checkApi(...)` on failure.
  URL constants live in an `abstract class <Feature>URLs { <Feature>URLs._(); … }` at the top
  of the datasource. Models expose `fromJson` + `toEntity()` — no business logic.
  **All fields in every model class must be private (`_field`) with explicit getters. The
  constructor assigns `_field = field` (no public fields — ever).**
- **Domain** is pure Dart: zero Flutter, zero Dio, zero JSON. Entities are immutable.
  Use cases hold the abstract repository and expose `call(...)` returning `ApiResult<T>`.
  **All entity fields must be private (`_field`) with explicit getters. Parameters classes
  use private fields + mutation methods (e.g. `setPage()`, `reset()`) + `toJson()` — never
  public mutable fields.**
- **Presentation** uses a `ChangeNotifier` ViewModel — **never Cubit/Bloc**. The VM calls
  use cases (never repositories), guards `notifyListeners` behind a `_disposed` flag via a private
  `_notify()`, and exposes `load()` / `getList()` + `retry()`. State shape depends on the screen:
  - **List / paginated screens (the standard):** expose a single typed
    `ApiResult<PaginationListEntity<T>>? get responseModel` + `bool get isLoading` (load-more flag).
    The screen derives all four states from `responseModel` — see the list pattern in Step 4.
  - **Single-object / detail screens:** expose `loading` / `error` / `data` (+ `isEmpty`) getters.

### ViewModel internal structure (mandatory layout)

Every ViewModel **must** follow this exact internal organisation — section headings are
`///` doc-comments so they appear in the IDE outline:

```dart
class XxxViewModel extends ChangeNotifier {
  final _tag = 'XxxViewModel';          // used with logger(); always the class name

  XxxViewModel({required XxxUseCase getXxx, ...}) : _getXxx = getXxx, ...;

  final XxxUseCase _getXxx;
  bool _disposed = false;

  ///Variables
  ApiResult<XxxEntity>? _responseModel;   // one per logical data group
  bool _isLoading = false;               // load-more / in-flight flag

  ///Getters
  ApiResult<XxxEntity>? get responseModel => _responseModel;
  bool get isLoading => _isLoading;

  ///Calling API functions

  /// Entry point. Pass [reload] = true to reset + re-fetch (pull-to-refresh).
  Future<void> init({bool reload = false}) async {
    await getXxx(reload: reload);
    // call further sub-functions if this screen loads multiple resources
  }

  Future<void> getXxx({bool reload = false}) async {
    _responseModel = null;        // always clear first
    if (reload) _notify();        // only push the loading frame on explicit reload
    _responseModel = await _getXxx();
    _notify();
  }

  Future<void> retry() => init(reload: true);

  @override
  void dispose() { _disposed = true; super.dispose(); }

  void _notify() { if (!_disposed) notifyListeners(); }
}
```

**Rules:**
- `_tag` is the **first** field; never a top-level constant — it must sit inside the class.
- `///Variables` / `///Getters` / `///Calling API functions` are **mandatory** section
  headers inside every ViewModel. Their names are fixed; do not rename them.
- **All** ViewModel fields are private (`_field`) — expose them only via getters.
- The **reload pattern** in every API method: set result to `null` first, then
  `if (reload) _notify()` (so pull-to-refresh shows loading), then fetch, then `_notify()`.
- When a screen loads a **single resource**, use `load({bool reload = false})` directly
  (skip the `init` wrapper). When it loads **multiple resources**, `init` dispatches to
  per-resource methods (like the home VM loading home + notification count in parallel).
- `retry()` always delegates to `init(reload: true)` or `load(reload: true)`.

### Private-field rule — all layers, all classes

```
✓ Correct                              ✗ Wrong
_field with getter                     public field
final String _name; get name => _name  final String name;
constructor: _name = name              constructor: this.name = name
```

This applies without exception to **Models**, **Entities**, **Parameters**, and
**ViewModels**. No public mutable state anywhere in the refactor tree.

### Parameters class layout

```dart
class XxxParameters {
  int _page;
  String? _filter;

  XxxParameters({int page = 1, String? filter})
      : _page = page,
        _filter = filter;

  int get page => _page;
  String? get filter => _filter;

  void nextPage() => _page++;
  void reset() => _page = 1;
  void setFilter(String? v) => _filter = v;

  Map<String, dynamic> toJson() => {
    'page': _page,
    if (_filter != null) 'filter': _filter,
  };
}
```

---

## Step 4 — UI rules (break any → the code is wrong)

| Rule | ✓ Correct | ✗ Wrong |
|---|---|---|
| Text | `GText(...)` | bare `Text(...)` |
| Strings | `tr(LocaleKeys.x)` | hard-coded literals, `AppLocale.instance.x` |
| Colors | `AppColor.x.themeColor` or `Theme.of(context)` | `Color(0xFF…)`, `GColors.*`, `Colors.*` for brand colors |
| Sizing | semantic `k*` radius (`kCardRadius` cards, `kButtonRadius` buttons…) + `kScreenPadding*` + `.w/.h/.r` for dynamic dims | `flutter_screenutil` `.w/.h/.r/.sp`, one radius for everything |
| Font weight | `FontWeightManager.{bold,semiBold,medium,regular,light}` | `FontWeight.w600`, `FontWeight.bold` |
| Theme | dark + light via `.themeColor` | brightness-blind hardcoded colors |
| Widgets | separate `StatelessWidget` classes | `Widget _buildXxx()` helper methods |
| 4-state UI | `CustomScreenStateLayout(isLoading/error/isEmpty/onRetry/builder)` | raw `if (isLoading)` chains |
| Loading | `ShimmerSkeleton(isLoading: true, child: _Body(data: Entity.shimmerSeed))` in `loadingBuilder` | bare `CircularProgressIndicator` |
| Empty | `CustomEmptyStateView(...)` in `noDataBuilder` / `emptyWidget` | custom one-off empty UI |
| Error | **must** pass `errorBuilder` (built-in fallback is a blank `SizedBox`) → `CustomEmptyStateView(title: error, onReload: onRetry)` | relying on the default (renders nothing) |
| Unauth | wrap auth-gated bodies in `CustomNotAuthStatusView(child: …, error: vm.error)` | custom login-prompt UI |
| Bottom sheet | `CustomModalSheet.showModalSheet(context:, screen:)`; structured → `BaseSheetShell` | raw `showModalBottomSheet` |
| Lists | **paginated product** lists → `CustomPaginationGalleryView`; **other paged** data → `CustomPaginationGridview` / `CustomPaginationListView`; **non-paginated vertical item lists** → `CustomListAnimatorData` (animated; `itemCount`/`itemBuilder`/`padding`/`verticalSpace`); grids → `CustomGridAnimatorData` | raw `ListView.builder` / `ListView.separated` for content lists |
| Interactions | `Haptics.tap()/select()/action()/confirm()` on taps/confirms | silent taps |
| Width / height | `MediaQuery.sizeOf(context).width` / `.height` in widgets; `deviceWidth` / `deviceHeight` only in non-widget code | `MediaQuery.of(context).size` (non-reactive), raw screenutil |
| Responsive | tablet + mobile branch (`MediaQuery.sizeOf(context).width >= 600`) | single fixed mobile layout |
| State read | `context.watch<VM>()` for **app-scoped** VMs from `providers.dart`; `ListenableBuilder(listenable: _vm)` or pass `_vm` to children for **factory** VMs | `ChangeNotifierProvider` in routes/screens/dialogs; `BlocBuilder`, `Consumer<VM>` |
| Completeness | every file fully written, zero commented-out code | `// TODO`, stubbed bodies, dead commented blocks |

### The `lib/core/res/` style layer — the single source for all styling

Import once: `import 'package:gomla_app/core/res/resources.dart';` (barrel — pulls colors,
decoration, fonts, text styles, theme, values).

| Need | Use (from `core/res`) | File |
|---|---|---|
| Color | `AppColor.<name>.themeColor` (auto light/dark) | `color.dart` |
| Dark check | `AppColor.isDarkMode` / `isAppDark(context)` | `color.dart` |
| Padding | `kScreenPaddingNormal` (16), `kScreenPaddingLarge` (32) | `values_manager.dart` |
| Radius | **semantic — pick by component** (see table below) | `values_manager.dart` |
| Font weight | `FontWeightManager.{bold,semiBold,medium,regular,light}` | `font_manager.dart` |
| Font size | `FontSize.{s10…s48,…}.sp` (i.e. `× ResponsiveService.scaleText()` — see below) | `font_manager.dart` |
| Font family | `FontConstants.fontFamily` | `font_manager.dart` |
| Decoration | `BoxDecoration().cardStyle()`, `.radius()`, `.shadow()`, `.borderStyle()`, `.customColor()`, `.gradientStyle()` | `decoration.dart` |
| Directional radius | `CustomBorderRadius.customRadiusDirectional(...)` | `decoration.dart` |

**Radius — pick the constant whose name matches the component** (never one radius for
everything; semantic names let a whole category be re-themed in one place):

| Component | Constant | Value |
|---|---|---|
| Card / container / surface | `kCardRadius` | 18 |
| Button | `kButtonRadius` | 12 |
| Cart item | `kCartRadius` | 14 |
| Form field / input / general | `kFormRadius` | 12 |
| Small chip / inset | `kFormRadiusSmall` | 6 |
| Medium element | `kFormRadiusNormal` | 8 |
| Large (search bar / sheet) | `kFormRadiusLarge` | 16 |

**Screen width & height — and the tablet breakpoint:**

```dart
// Inside a widget — reactive (rebuilds on rotation/resize). This is the idiom (117 uses).
final width  = MediaQuery.sizeOf(context).width;
final height = MediaQuery.sizeOf(context).height;
final isTablet = width >= 600;               // canonical refactor breakpoint (NOT 768)
final crossAxisCount = isTablet ? 3 : 2;     // grids: 3 on tablet, 2 on mobile
```

- In **widgets**, always `MediaQuery.sizeOf(context)` (reactive; preferred over the older
  `MediaQuery.of(context).size`).
- In **non-widget code** (ViewModels, helpers — no `BuildContext`), use the global getters
  `deviceWidth` / `deviceHeight` from `values_manager.dart`. They read a context snapshot, so
  they do **not** rebuild on resize — never use them for a widget's layout branch.
- **Sizing must stay responsive without screenutil.** Use the scaling getters in `font_manager.dart`
  (`extension ResponsiveSizing on num`) — the screenutil-free equivalents. **Do not redefine them:**
  - `FontSize.title.sp` ≈ `.sp` (font size)
  - `173.w` ≈ `.w` · `48.h` ≈ `.h` · `12.r` ≈ `.r` (dimensions)
  Prefer `k*` constants for padding/radius where a named one fits; reach for `.w/H/R` only for
  genuinely proportional dimensions.
  > ⚠️ `ResponsiveService` had near-zero prior adoption — **eyeball every screen on phone + tablet**
  > (it scales like `.sp`, ~2× on a wide tablet).
  > ⚠️ **Import gotcha:** `core/res/values_manager.dart` (via the `resources.dart` barrel) **and**
  > `core/theme/values_manager.dart` both define `kScreenPaddingNormal`, `kFormRadius`, … — importing
  > both and referencing a shared name is an **ambiguous-import error**. If a file already imports
  > `core/theme/values_manager.dart` (e.g. for `kScreenPadding` / `kCardPadding`), pull the scaling
  > getters from `core/res/font_manager.dart` directly instead of the full `resources.dart` barrel.

- **Colors**: only `AppColor.x.themeColor` (or `Theme.of(context)`). Canonical scales —
  `primary50/500/900`, `gray200/500/700/900`, `success/error/warning/blue 50/500/900`. The
  hundreds of legacy named aliases (`greyF4F4F4`, `redD32F2F`, …) exist but **prefer the
  canonical scale names** in new code. Never a raw `Color(0xFF…)` or `Colors.*` brand color.
- **Build text styles explicitly** with `FontWeightManager` + `FontSize` + `FontConstants.fontFamily`
  and color via `.themeColor`:
  ```dart
  GText(
    tr(LocaleKeys.title),
    style: TextStyle(
      fontSize: FontSize.title.sp,        // FontSize.title * ResponsiveService.scaleText()
      fontWeight: FontWeightManager.bold,
      fontFamily: FontConstants.fontFamily,
      color: AppColor.textPrimary.themeColor,
    ),
  )
  ```
  > ⚠️ The chained `TextStyle` helpers in `text_styles.dart` (`.regularStyle()`, `.titleStyle()`,
  > `.semiBoldStyle()`, …) bake in `flutter_screenutil` (`.sp`) **and** hardcoded `FontWeight`
  > values — both forbidden by the rules above. **Do not use them in new refactor code.** Their
  > non-size, non-weight color/decoration helpers (`.colorHint()`, `.underLineStyle()`,
  > `.ellipsisStyle()`, `.italic()`) are fine to chain onto an explicitly-built style.

### Localization note
**Always use `tr(LocaleKeys.key)`** for new refactor screens — this is the project standard and
aligns with the `/translators` agent. Do **not** use the typed `AppLocale.instance.x` accessor in
new code (it exists in a few older features but is not the standard going forward). **Never** add
keys yourself — delegate to `/translators` and report which keys are needed.

### Haptics
- `Haptics.tap()` — light taps, toggles, chips, quantity steps.
- `Haptics.select()` — picking from a list/filter.
- `Haptics.action()` — meaningful actions (add to cart).
- `Haptics.confirm()` — confirmations / destructive (delete, submit).

### Shared state & sheet widgets — reuse these, never rebuild them

The project already ships the loading / empty / error / unauth / sheet widgets. Use them.

| Widget | Import | Signature / use |
|---|---|---|
| `CustomScreenStateLayout` | `core/widgets/screen_state_layout.dart` | `(builder, {isLoading, error, isEmpty, loadingBuilder, errorBuilder, noDataBuilder, onRetry})`. When `onRetry` is set it wraps the body in a `RefreshIndicator`. |
| `ShimmerSkeleton` | `core/widgets/shimmer_skeleton.dart` | `(required child, required isLoading, containersColor?)` — skeletonizer-based. Wrap a real-shaped body fed `Entity.shimmerSeed`. |
| `CustomEmptyStateView` | `core/widgets/empty_state.dart` | `({title, desc, imageSvg = Assets.svgsLogout, image, onReload, onPrimaryAction, primaryActionLabel})`. `onReload` renders a retry button; default title is `context.locale.noResultFound`. |
| `CustomNotAuthStatusView` | `core/widgets/not_auth_status_layout.dart` | `(required child, {notAuthWidget, apiState, error, endpoint, onAuthStatusChanged})`. Checks `SharedPreferenceHelper.isUserLoggedIn()` + detects `GUnauthorizedFailure`; shows a default login prompt (→ `Routes.registerPage`) or your `notAuthWidget`. |
| `CustomModalSheet.showModalSheet<T>` | `base/presentation/sheet/custom_modal_sheet.dart` | `({required context, required screen, isScrollControlled = true})` — themed rounded bottom sheet. |
| `BaseSheetShell` | `base/presentation/sheet/widgets/base_sheet_shell.dart` | `({required title, required body, required onReset, required onApply, onCancel?, actionLabel?, onActionPress?, maxHeightFactor})` + `CustomSheetHeader/Divider/RadioItem/CheckboxItem/ContainerView` for filter/action sheets. |

> ⚠️ **Error gotcha:** `CustomScreenStateLayout`'s built-in error fallback is an empty
> `SizedBox()` (the real error view is commented out). So passing only `error:` shows **nothing**
> — **always pass `errorBuilder:`** (e.g. `CustomEmptyStateView(title: vm.error, onReload: vm.retry)`).
> Same for empty: pass `noDataBuilder:` with a feature-appropriate `imageSvg` + title rather than
> leaning on the generic default.

> **Auth-gated screens:** if the feature requires login, wrap the screen body in
> `CustomNotAuthStatusView(child: …, error: vm.error)` so a 401 / not-logged-in shows the shared
> login prompt instead of a broken error. Skip it for public screens.

### List / paginated screen pattern — `responseModel` (the standard for lists)

The VM exposes the whole response as **one typed `ApiResult`** plus a load-more flag — no separate
`loading`/`error`/`data` getters:

```dart
ApiResult<PaginationListEntity<XxxEntity>>? _responseModel;
ApiResult<PaginationListEntity<XxxEntity>>? get responseModel => _responseModel;
bool _isLoading = false;                 // load-more in flight
bool get isLoading => _isLoading;
Future<void> getList({bool isLoadMore = false}) async { /* sets _responseModel, _notify() */ }
```

The screen derives all four states from `responseModel`:

```dart
final responseModel = context.watch<XxxViewModel>().responseModel;
final isMoreLoading = context.watch<XxxViewModel>().isLoading;

return CustomScreenStateLayout(
  isLoading: responseModel == null,                                      // first load
  error: responseModel is Failure<PaginationListEntity<XxxEntity>>       // promotion OK out here
      ? responseModel.error.errorMessage
      : null,
  isEmpty: responseModel is Success<PaginationListEntity<XxxEntity>>
      && responseModel.data.list.isEmpty,
  onRetry: () => vm.getList(),
  loadingBuilder: (_) => const XxxListShimmer(),
  errorBuilder: (_) => CustomEmptyStateView(
    title: responseModel is Failure<PaginationListEntity<XxxEntity>>
        ? responseModel.error.errorMessage : null,
    onReload: () => vm.getList(),
  ),
  noDataBuilder: (_) =>
      CustomEmptyStateView(imageSvg: Assets.emptyStateXxx, title: tr(LocaleKeys.noXxxFound)),
  builder: (_) {
    // ⚠️ promotion does NOT carry into this closure — cast explicitly:
    final data = (responseModel as Success<PaginationListEntity<XxxEntity>>).data;
    return CustomPaginationGridview<XxxEntity>(        // products → CustomPaginationGalleryView
      list: data.list,
      currentPage: data.pagination.currentPage,
      hasMorePages: data.pagination.hasMorePages,
      isMoreLoading: isMoreLoading,
      onLoadMore: () => vm.getList(isLoadMore: true),
      builder: (ctx, i) => _XxxCard(item: data.list[i]),
    );
  },
);
```

> **Type-promotion gotcha:** `error:` / `isEmpty:` outside the closure promote fine, but inside
> `builder:` you must `as Success<…>` cast — promotion doesn't cross the closure boundary.

### Screen skeleton — single-object / detail screens (factory VM, 4-state, shimmer)

```dart
class XxxScreen extends StatefulWidget {
  const XxxScreen({super.key, this.routeExtra});

  final XxxRouteExtra? routeExtra;

  @override
  State<XxxScreen> createState() => _XxxScreenState();
}

class _XxxScreenState extends State<XxxScreen> {
  late final XxxViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = GetIt.instance<XxxViewModel>()
      ..configure(widget.routeExtra)
      ..load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final vm = _vm;
        return Scaffold(
          appBar: AppBar(title: GText(tr(LocaleKeys.xxx))),
          body: CustomScreenStateLayout(
            isLoading: vm.loading && vm.data == null,
            loadingBuilder: (_) => ShimmerSkeleton(
              isLoading: true,
              child: _XxxBody(data: XxxEntity.shimmerSeed),
            ),
            error: vm.error,
            onRetry: vm.retry,
            errorBuilder: (_) =>
                CustomEmptyStateView(title: vm.error, onReload: vm.retry),
            isEmpty: !vm.loading && vm.error == null && vm.isEmpty,
            noDataBuilder: (_) => CustomEmptyStateView(
              imageSvg: Assets.emptyStateXxx,
              title: tr(LocaleKeys.noXxxFound),
            ),
            builder: (_) => _XxxBody(data: vm.data!),
          ),
        );
      },
    );
  }
}
```

> **Provider & route-data rules (mandatory):**
>
> 1. **`ChangeNotifierProvider` lives only in `lib/providers.dart`** — each feature
>    contributes via `init<Feature>RefactorProvider()` in its `injection.dart`. Nothing
>    else in the refactor tree may declare `ChangeNotifierProvider` (not routes, not
>    screens, not dialogs/sheets).
> 2. **App-scoped VMs** (`registerLazySingleton` — e.g. `ProfileViewModel`,
>    `MenuViewModel`, `ShortcutsViewModel`, `WishlistViewModel`): registered in
>    `providers.dart`; screens/widgets read them with `context.watch` / `context.read`.
> 3. **Per-navigation VMs** (`registerFactory` — e.g. `MyRewardsViewModel`,
>    `CollectionsViewModel`): the **route** decodes `state.extra` / `arguments` and
>    passes them to the **screen constructor**; the **screen** resolves
>    `GetIt.instance<XxxViewModel>()`, calls `configure` / `init` with that data, owns
>    `dispose()`, and rebuilds via **`ListenableBuilder(listenable: _vm)`** or by passing
>    `_vm` down to child widgets — **never** `ChangeNotifierProvider`.
> 4. **Route generators return the bare screen** — decode args into constructor params
>    only. Mirror `MyRewardsRouteGenerator` + `MyRewardsScreen(routeExtra: extra)`.
>
> Canonical reference: `my_rewards/routs.dart` + `my_rewards_screen.dart`.

---

## Known migration debt (audit 2026-06-21)

These refactor files still violate the provider/route-data rules above and should be
migrated to match `my_rewards/routs.dart` + `my_rewards_screen.dart`:

| Violation | Files (representative) |
|---|---|
| `ChangeNotifierProvider` in route | *(fixed: `my_rewards/routs.dart`)* |
| `ChangeNotifierProvider` in screen | `collections_screen.dart`, `brands_grid_screen.dart`, `home_screen.dart`, `product_details_screen.dart`, `search_screen.dart`, `wishlist_screen.dart`, `offers_screen.dart`, `gym_products_screen.dart`, `browsing_history_screen.dart`, `brand_details_screen.dart`, `wc_challenge_detail_screen.dart`, profile/delete-account/edit screens, `add_address_screen.dart`, wheel/scratch/timer dialogs |
| `ChangeNotifierProvider` in widget/sheet | `products_list_view.dart`, `filter_sheet.dart`, `products_listing_filter_sheet.dart`, `checkout_address_selection_sheet.dart` |
| Factory VM in `init*RefactorProvider()` | `products/injection.dart` (keep only `WishlistViewModel`), `brands/injection.dart`, `categories/injection.dart`, `events/injection.dart`, `address/injection.dart` |
| Screen reads factory VM from global Provider | `categories_grid_screen.dart`, `address_list_screen.dart`, `wc_challenge_list_screen.dart` |

When touching any of these files, migrate them — do not copy the old pattern.

---

## Step 5 — Dependency Injection

Create `presentation/injection.dart` following the established pattern (idempotent guards):

```dart
final _getIt = GetIt.instance;

Future<void> initXxxRefactorFeatures() async {
  if (!_getIt.isRegistered<XxxRemoteDataSource>()) {
    _getIt.registerLazySingleton<XxxRemoteDataSource>(
      () => XxxRemoteDataSource(_getIt<DioClient>()),
    );
  }
  if (!_getIt.isRegistered<XxxRepository>()) {
    _getIt.registerLazySingleton<XxxRepository>(
      () => XxxRepositoryImp(_getIt<XxxRemoteDataSource>()),
    );
  }
  if (!_getIt.isRegistered<GetXxxUseCase>()) {
    _getIt.registerLazySingleton<GetXxxUseCase>(
      () => GetXxxUseCase(_getIt<XxxRepository>()),
    );
  }
  if (!_getIt.isRegistered<XxxViewModel>()) {
    _getIt.registerFactory<XxxViewModel>(            // VM = factory; repo/usecase = lazySingleton
      () => XxxViewModel(getXxx: _getIt<GetXxxUseCase>()),
    );
  }
}
```

Then wire it into the master orchestrator `lib/injection.dart` — add
`await xxx_refactor_di.initXxxRefactorFeatures();` alongside the other `init*RefactorFeatures()`
calls.

For app-scoped VMs only, add `initXxxRefactorProvider()` and spread it in
`lib/providers.dart`. **Do not** add factory VMs to `initXxxRefactorProvider()` — those are
owned by screens (see provider rules in Step 4).

---

## Step 6 — Routing (separate routes file + go_router generator)

1. `<feature>_routes.dart` — path constants:

```dart
abstract class XxxRoutes {
  XxxRoutes._();
  static const key = '/xxx';
  static const list = '/xxx';
  static const details = '/xxx/details';
}
```

2. `presentation/route_generator.dart` — expose `static List<GoRoute> get routes` returning the
   **bare screen**. Decode `state.extra` / `arguments` into **screen constructor parameters** —
   never wrap the route in `ChangeNotifierProvider`. Mirror `MyRewardsRouteGenerator`:

```dart
GoRoute(
  path: XxxRoutes.list,
  builder: (context, state) {
    final extra = state.extra as XxxRouteExtra?;
    return XxxScreen(routeExtra: extra);
  },
),
```

3. Spread into the master router `lib/core/routes/app_routes.dart`:
   `routes: [ ...XxxRouteGenerator.routes, ... ]`.

Use `go_router` (`context.go`/`context.push`/`context.pop`) — this project routes via GoRouter.

---

## Step 7 — Tests (delegate or write)

Every migrated feature gets tests. Either invoke `/test` for the feature, or follow
`test/TEST_GUIDE.md` directly: VM success/failure/initial-state, use-case delegation,
repository mapping, datasource endpoint + error handling. Put them under
`test/features/refactor/<feature>/`.

---

## Step 8 — Verify (mandatory)

```bash
flutter analyze lib/features/refactor/<feature>/
flutter test test/features/refactor/<feature>/
```

- Zero analyzer errors/warnings in the feature folder before reporting done.
- All feature tests green (or skipped with a stated reason).
- If anything fails, fix and re-run — do not report done until clean.

---

## Step 9 — Report

```
## Migrated: <feature>
Source: lib/features/<feature>/  →  lib/features/refactor/<feature>/

## Files written
data/        … (datasource, model(s), repository imp)
domain/      … (entity(ies), parameters, repository, usecase(s))
presentation/… (screen(s), view_model, widgets/dialogs, injection, route_generator)
<feature>_routes.dart

## Wiring
- lib/injection.dart           → initXxxRefactorFeatures() registered
- lib/core/routes/app_routes.dart → ...XxxRouteGenerator.routes spread

## Localization
- Keys needed (run /translators): <list, or "none">

## Verification
✅ flutter analyze: 0 errors / 0 warnings
✅ flutter test: N passed
```

---

## What this agent does NOT do

- Does not restore, uncomment, or copy legacy code verbatim — it ports logic and rewrites to spec.
- Does not use Cubit/Bloc, `flutter_screenutil`, hardcoded colors/strings, or raw `FontWeight.*`.
- Does not wrap routes, screens, or dialogs in `ChangeNotifierProvider` — only
  `lib/providers.dart` (via `init<Feature>RefactorProvider()`).
- Does not use the `.sp`/hardcoded-weight text-style helpers (`.regularStyle()`, `.titleStyle()`,
  `.semiBoldStyle()`, etc.) from `text_styles.dart` in new code.
- Does not create `LocaleKeys` / edit translation JSON — that is `/translators`' job.
- Does not touch `lib/base/` or unrelated `lib/core/` files (other than the two wiring points
  in Step 5 and Step 6).
