# Gomla Refactor — Code Review Guide

This document is the single source of truth for reviewing any code submitted to `lib/features/refactor/` or `lib/core/`. Every item is a hard requirement unless explicitly marked *(advisory)*. Reviewers must block a PR if any hard requirement is violated.

---

## Table of Contents

1. [Feature Folder Structure](#1-feature-folder-structure)
2. [Domain Layer](#2-domain-layer)
3. [Data Layer](#3-data-layer)
4. [Presentation Layer](#4-presentation-layer)
5. [Dependency Injection](#5-dependency-injection)
6. [Provider & ViewModel](#6-provider--viewmodel)
7. [Localization](#7-localization)
8. [Code Style & Comments](#8-code-style--comments)
9. [Testing](#9-testing)
10. [Performance](#10-performance)
11. [Anti-Patterns — Reject Immediately](#11-anti-patterns--reject-immediately)
12. [Pre-Merge Checklist](#12-pre-merge-checklist)

---

## 1. Feature Folder Structure

Every feature under `lib/features/refactor/<feature>/` must follow this exact layout:

```
<feature>/
├── <feature>_routes.dart          # route name constants
├── data/
│   ├── datasource/
│   │   ├── remote/
│   │   │   └── <feature>_remote_datasource.dart
│   │   └── local/                 # only if local caching exists
│   │       └── <feature>_local_datasource.dart
│   ├── model/
│   │   ├── <entity>_model.dart    # one file per model
│   │   └── <entity>_mapper.dart   # one file per mapper
│   └── repository/
│       └── <feature>_repository_imp.dart
├── domain/
│   ├── entity/
│   │   └── <entity>_entity.dart   # one file per entity
│   ├── parameters/                # only if usecases take structured input
│   │   └── <action>_parameters.dart
│   ├── repository/
│   │   └── <feature>_repository.dart   # abstract interface
│   └── usecase/
│       └── <verb>_<noun>_use_case.dart  # one file per usecase
└── presentation/
    ├── injection.dart             # DI + Provider registration
    ├── route_generator.dart       # route factory (if feature has screens)
    ├── <feature>_view_model.dart  # or per-screen ViewModels in subfolders
    ├── screens/
    │   └── <feature>_screen.dart
    └── widgets/
        └── <widget_name>.dart
```

**Rules:**

- `data/` never imports from `presentation/`. `presentation/` never imports from `data/`. Both communicate through `domain/`.
- A feature's `presentation/` may only import its own `domain/entity/` and other features' `domain/entity/` — never another feature's `data/` or `presentation/`.
- Cross-cutting utilities belong in `lib/core/`, never duplicated across features.
- Static/hardcoded mock data inside a `domain/` subfolder must go in `domain/static/`, not `domain/data/` (the latter implies a real data layer).
- Demo features (non-production) go under `lib/features/refactor/demo/<feature>/`.

---

## 2. Domain Layer

### 2.1 Entities

```dart
// CORRECT
class BrandEntity extends Equatable {
  const BrandEntity({
    required int id,
    required String name,
    required String image,
    String status = 'active',
  })  : _id = id,
        _name = name,
        _image = image,
        _status = status;

  final int _id;
  final String _name;
  final String _image;
  final String _status;

  int get id => _id;
  String get name => _name;
  String get image => _image;
  String get status => _status;

  @override
  List<Object?> get props => [_id, _name, _image, _status];
}
```

**Rules:**

- All fields are `final` and private (`_fieldName`). Public access only through getters.
- Constructor is `const`.
- Extend `Equatable` and implement `props`.
- No `fromJson` / `toMap` / `copyWith` inside entities. Entities are pure domain objects.
- No Flutter imports. Entities must be framework-independent.
- Default values for optional fields use `const` literals (`const []`, `''`, `false`).
- One entity per file.

### 2.2 Repository Interfaces

```dart
// CORRECT
abstract interface class BrandsRepository {
  Future<ApiResult<List<BrandEntity>>> getBrands();
  Future<ApiResult<List<BrandEntity>>> getBrandsByCategory({required int categoryId});
}
```

**Rules:**

- Use `abstract interface class` (Dart 3). Not `abstract class`.
- Returns `Future<ApiResult<T>>` — never `Future<T>` that can throw.
- Lives in `domain/repository/`. One file per repository.
- No implementation detail, no import from `data/`.

### 2.3 Use Cases

```dart
// CORRECT
class GetBrandsUseCase {
  final BrandsRepository _repository;
  GetBrandsUseCase(this._repository);

  Future<ApiResult<List<BrandEntity>>> call() => _repository.getBrands();
}

// CORRECT — with parameters
class GetProductsUseCase {
  final ProductsRepository _repository;
  GetProductsUseCase(this._repository);

  Future<ApiResult<ProductsListPageEntity>> call({
    required ProductFilterParameters parameters,
  }) => _repository.getProducts(parameters);
}
```

**Rules:**

- One class, one operation. Do not merge two operations into one use case.
- Public method is named `call()` (makes it callable like a function).
- Constructor takes the repository through its interface, not the implementation.
- No business logic beyond delegation. Transformation belongs in datasource or mapper.
- Parameters are domain-level objects (`ProductFilterParameters`), never raw `Map` or HTTP types.
- Lives in `domain/usecase/`. Filename: `<verb>_<noun>_use_case.dart`.

### 2.4 `ApiResult<T>`

The sealed class `ApiResult<T>` is the universal error contract:

```dart
// Setting state in ViewModel
_result = await _useCase.call();
notifyListeners();

// Reading state (pattern matching)
bool get isLoading => _result == null;

List<BrandEntity> get brands => _result is Success<List<BrandEntity>>
    ? (_result as Success<List<BrandEntity>>).data
    : const [];

String? get error => _result is Failure<List<BrandEntity>>
    ? (_result as Failure<List<BrandEntity>>).error.errorMessage
    : null;
```

**Rules:**

- Never `throw` across the data→domain boundary. Wrap exceptions in `Failure(ErrorModel(...))` inside the datasource.
- ViewModels pattern-match with `is Success<T>` / `is Failure<T>` — or use `.when()`.
- `_result == null` means loading (not started or cleared before reload).
- Never expose raw `ErrorModel` to widgets. Expose `String? error` or a typed state.

---

## 3. Data Layer

### 3.1 Models

```dart
// CORRECT
class BrandModel {
  const BrandModel({
    required int id,
    required String name,
    required String image,
    String status = 'active',
  })  : _id = id,
        _name = name,
        _image = image,
        _status = status;

  final int _id;
  final String _name;
  final String _image;
  final String _status;

  int get id => _id;
  String get name => _name;
  String get image => _image;
  String get status => _status;

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
        id: asInt(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        image: asImageUrl(json['image']),
        status: json['status']?.toString() ?? 'active',
      );

  Map<String, dynamic> toMap() => {
        'id': _id,
        'name': _name,
        'image': _image,
        'status': _status,
      };
}
```

**Rules:**

- Same immutability pattern as entities (private fields + getters + `const` constructor).
- `fromJson` is a `factory` constructor, not a static method.
- `toMap()` only if the model is persisted locally (e.g. cached with SharedPreferences or SQLite). If no persistence, omit it.
- JSON field names match the API exactly — do not rename in `fromJson`.
- Use helpers from `lib/base/data/json_helpers.dart` (`asInt`, `asBool`, `asImageUrl`, etc.) for type-safe parsing. Do not use raw casts (`json['id'] as int`) — they throw on null or wrong type.
- One model per file. One file per API object.

### 3.2 Mappers

```dart
// CORRECT
// File: brand_mapper.dart
import 'brand_model.dart';
import '../../../domain/entity/brand_entity.dart';

extension BrandModelToEntity on BrandModel {
  BrandEntity toEntity() => BrandEntity(
        id: id,
        name: name,
        image: image,
        status: status,
      );
}
```

**Rules:**

- Mappers are extensions on data models. Never put mapping logic inside the entity or the model.
- File lives in `data/model/` alongside the model. Named `<entity>_mapper.dart`.
- Extension name: `<Model>ToEntity on <Model>`.
- Add a nullable variant (`on <Model>?`) when null cases exist in practice.
- Bidirectional mapper (`toModel()`) only if the entity is sent back to the API. Delete dead directions.
- No mapper between two entities or two models — only data↔domain boundary.

### 3.3 Datasources

```dart
// CORRECT
class BrandsRemoteDataSource {
  BrandsRemoteDataSource(this._dio);

  final DioClient _dio;

  Future<ApiResult<List<BrandEntity>>> getBrands() {
    return _dio.get(
      ApiConstants.brands,
      onConvert: (json) {
        final list = (json['data'] as List? ?? const [])
            .whereType<Map>()
            .map((m) => BrandModel.fromJson(m.cast<String, dynamic>()).toEntity())
            .toList();
        return list;
      },
    );
  }
}
```

**Rules:**

- Datasources call the network via `DioClient` (never raw `Dio`).
- The `onConvert` lambda parses JSON → model → entity. Entity is returned, model stays inside the lambda.
- `ApiResult<T>` is returned. Exceptions from `DioClient` are caught at the `ApiHelper` level.
- Local datasources persist/read via `SharedPreferences` or a local DB abstraction — never raw file I/O.
- No business logic in datasources. If a calculation is needed before returning, it belongs in a use case.

### 3.4 Repository Implementations

```dart
// CORRECT — thin wrapper
class BrandsRepositoryImp implements BrandsRepository {
  BrandsRepositoryImp(this._remote);

  final BrandsRemoteDataSource _remote;

  @override
  Future<ApiResult<List<BrandEntity>>> getBrands() => _remote.getBrands();
}
```

**Rules:**

- Repository implementations are thin pass-throughs. A body with more than ~3 lines of logic is a smell.
- If caching is needed, the repository chooses between local and remote datasource — that is its only logic.
- Named `<Feature>RepositoryImp`, implements `<Feature>Repository`.
- Never called directly by a ViewModel. ViewModels talk to use cases.

---

## 4. Presentation Layer

### 4.1 What Widgets May Import

| Allowed | Forbidden |
|---------|-----------|
| `domain/entity/*.dart` | `data/model/*.dart` |
| `presentation/` files of the same feature | `data/datasource/*.dart` |
| `domain/entity/` of *other* features | Another feature's `presentation/` screens |
| `core/` utilities | `data/repository/` |
| `lib/core/res/`, `lib/core/widgets/` | Anything from `legacy/` subfolder |

If a widget needs a color, size, or name from a badge, it receives a `ProductBadgeEntity` — not a `ProductBadge` model. **No data model may appear in a widget file.**

### 4.2 Screens vs Widgets

- **Screens** (`screens/`) are route targets. They hold `StatefulWidget` when lifecycle (`initState`, `dispose`) is needed.
- **Factory VMs:** screen resolves `getIt<XxxViewModel>()` in `initState`, passes route
  constructor params to `vm.configure` / `vm.init`, calls `load()`, disposes the VM in
  `dispose()`, rebuilds with `ListenableBuilder` — **no** `ChangeNotifierProvider`.
- **App-scoped VMs:** screen reads `context.watch<XxxViewModel>()` — VM comes from
  `lib/providers.dart` only.
- **Widgets** (`widgets/`) receive data through constructor parameters — they do not call `getIt` directly unless given a VM reference by the parent screen.
- No screen imports another screen directly. Use named routes via `NavigationService`.

### 4.3 Reading ViewModel State

```dart
// CORRECT — in build()
final vm = context.watch<BrandsGridViewModel>();

// CORRECT — in callbacks / event handlers
context.read<BrandsGridViewModel>().loadBrands();

// WRONG — watch in a callback
onTap: () => context.watch<BrandsGridViewModel>().loadBrands(), // NEVER
```

**Rules:**

- `context.watch<T>()` only inside `build()` — causes rebuild on every `notifyListeners()`.
- `context.read<T>()` only in callbacks, `initState`, or outside `build()`.
- Never call `getIt<XxxViewModel>()` inside a widget's `build()`.

### 4.4 Localization

```dart
// CORRECT
Text(tr(LocaleKeys.brands))
Text(tr(LocaleKeys.noProductsFound))

// WRONG
Text(AppLocalizations.of(context)!.brands)   // forbidden
Text(context.l10n.brands)                     // forbidden
Text('Brands')                                // hardcoded — forbidden
```

Every user-visible string must use `tr(LocaleKeys.<key>)`. No exceptions. The key must exist in the locale files before the PR is merged. Never pass raw strings to UI components.

---

## 5. Dependency Injection

### 5.1 Feature Injection File

Every feature has exactly one `presentation/injection.dart`:

```dart
// CORRECT
import 'package:get_it/get_it.dart';
// ... feature imports

final _getIt = GetIt.instance;

Future<void> initBrandsRefactorFeatures() async {
  // 1. Datasource
  if (!_getIt.isRegistered<BrandsRemoteDataSource>()) {
    _getIt.registerLazySingleton<BrandsRemoteDataSource>(
      () => BrandsRemoteDataSource(_getIt<DioClient>()),
    );
  }
  // 2. Repository (by interface, not implementation)
  if (!_getIt.isRegistered<BrandsRepository>()) {
    _getIt.registerLazySingleton<BrandsRepository>(
      () => BrandsRepositoryImp(_getIt<BrandsRemoteDataSource>()),
    );
  }
  // 3. Use cases
  if (!_getIt.isRegistered<GetBrandsUseCase>()) {
    _getIt.registerLazySingleton<GetBrandsUseCase>(
      () => GetBrandsUseCase(_getIt<BrandsRepository>()),
    );
  }
  // 4. ViewModel — factory for per-screen VMs; lazySingleton only if app-scoped
  if (!_getIt.isRegistered<BrandsGridViewModel>()) {
    _getIt.registerFactory<BrandsGridViewModel>(
      () => BrandsGridViewModel(
        getBrands: _getIt<GetBrandsUseCase>(),
        getBrandsByCategory: _getIt<GetBrandsByCategoryUseCase>(),
      ),
    );
  }
}

// Only app-scoped lazySingleton VMs — factory VMs are owned by screens.
List<SingleChildWidget> initBrandsRefactorProvider() {
  return const [];
}
```

**Registration order (mandatory):** Datasource → Repository → Use Cases → ViewModels. A registration may not reference a type registered later.

**Rules:**

- Every registration is guarded with `if (!_getIt.isRegistered<T>())`.
- Register the **interface** type for repositories: `_getIt.registerLazySingleton<BrandsRepository>(...)` — not the impl type.
- `registerLazySingleton` for shared state (datasources, repos, use cases, singleton VMs).
- `registerFactory` for per-screen ViewModels that must be fresh per navigation.
- The private `final _getIt = GetIt.instance;` alias is used throughout — never `GetIt.I` or raw `GetIt.instance` inline.

### 5.2 Wiring into `lib/injection.dart`

After creating the feature injection file, add one line to `lib/injection.dart`:

```dart
await brands_refactor_di.initBrandsRefactorFeatures();
```

Position matters: place it after any features yours depends on.

Import alias must follow the naming pattern:
```dart
import 'package:gomla_app/features/refactor/brands/presentation/injection.dart'
    as brands_refactor_di;
```

### 5.3 Wiring into `lib/providers.dart`

Add the provider spread to `GenerateMultiProvider`:

```dart
...brands_refactor_di.initBrandsRefactorProvider(),
```

Order matters: if ViewModel A depends on ViewModel B, B's provider must appear before A's.

### 5.4 Core Helpers

Utilities that are not features (no use case, no repository) live in `lib/core/helpers/`. They get their own `lib/core/helpers/injection.dart` registered once via `initCoreHelpers()`. Do not add core helper registration inside a feature's injection file.

---

## 6. Provider & ViewModel

### 6.1 ViewModel Structure

```dart
class BrandsGridViewModel extends ChangeNotifier {
  BrandsGridViewModel({
    required GetBrandsUseCase getBrands,
    required GetBrandsByCategoryUseCase getBrandsByCategory,
  })  : _getBrands = getBrands,
        _getBrandsByCategory = getBrandsByCategory;

  final GetBrandsUseCase _getBrands;
  final GetBrandsByCategoryUseCase _getBrandsByCategory;

  ApiResult<List<BrandEntity>>? _result;

  // ── Computed state ───────────────────────────────────────────────────────
  bool get isLoading => _result == null;

  List<BrandEntity> get brands => _result is Success<List<BrandEntity>>
      ? (_result as Success<List<BrandEntity>>).data
      : const [];

  String? get error => _result is Failure<List<BrandEntity>>
      ? (_result as Failure<List<BrandEntity>>).error.errorMessage
      : null;

  // ── Actions ──────────────────────────────────────────────────────────────
  Future<void> load() async {
    _result = null;
    notifyListeners();
    _result = await _getBrands.call();
    notifyListeners();
  }

  Future<void> retry() => load();
}
```

**Rules:**

- Extends `ChangeNotifier`. Never `extends ChangeNotifier with SomeMixin` unless the mixin is reviewed.
- Constructor injects use cases, never repositories or datasources directly.
- State is one `ApiResult<T>?` field per data domain. `null` means loading.
- Computed getters (`bool get isLoading`, `List<T> get items`, `String? get error`) derive all UI state from the result field.
- No `setState`-style boolean flags (`bool _isLoading = false`). Derive from `_result == null`.
- `notifyListeners()` called exactly twice per load: once when clearing (shows shimmer), once when result arrives.
- Never call `notifyListeners()` when the value didn't change:

```dart
// CORRECT
void setSelectedLetter(String? letter) {
  if (_selectedLetter == letter) return;  // guard
  _selectedLetter = letter;
  notifyListeners();
}
```

### 6.2 ViewModel Composition (Proxy Pattern)

When a ViewModel depends on another ViewModel's data (e.g. `MenuViewModel` needs `ProfileViewModel`):

```dart
class MenuViewModel extends ChangeNotifier {
  MenuViewModel({
    required ProfileViewModel profileViewModel,
    required ShortcutsViewModel shortcutsViewModel,
  })  : _profileVm = profileViewModel,
        _shortcutsVm = shortcutsViewModel {
    _profileVm.addListener(_onProfileChanged);
  }

  final ProfileViewModel _profileVm;
  final ShortcutsViewModel _shortcutsVm;

  ProfileEntity? get profile => _profileVm.data;
  bool get loading => _profileVm.loading;
  String? get error => _profileVm.error;

  void _onProfileChanged() => notifyListeners();

  @override
  void dispose() {
    _profileVm.removeListener(_onProfileChanged);
    super.dispose();
  }
}
```

**Rules:**

- The dependent ViewModel registers a listener in its constructor and removes it in `dispose()`.
- `dispose()` must call `super.dispose()` as its last line.
- Widgets must NOT watch two ViewModels and merge their state manually. Use the proxy pattern instead.

### 6.3 Provider Registration — `lib/providers.dart` only

`ChangeNotifierProvider` may appear **only** in feature `init<Feature>RefactorProvider()`
functions, which are spread into `lib/providers.dart` via `GenerateMultiProvider`. It must
**never** appear in route generators, screen `build()` methods, dialogs, or bottom sheets.

**App-scoped singleton VMs** (`registerLazySingleton`):

```dart
// injection.dart — only lazySingleton VMs belong here
List<SingleChildWidget> initProfileRefactorProvider() {
  return [
    ChangeNotifierProvider<ProfileViewModel>.value(
      value: _getIt<ProfileViewModel>(),
    ),
  ];
}
```

Screens and widgets read these with `context.watch<T>()` / `context.read<T>()`.

**Per-navigation factory VMs** (`registerFactory`):

- **Not** registered in `init<Feature>RefactorProvider()`.
- Route decodes `state.extra` / `arguments` → passes to **screen constructor**.
- Screen creates the VM in `initState`, seeds it, disposes it, rebuilds with
  `ListenableBuilder(listenable: _vm)` or passes `_vm` to children.

```dart
// CORRECT — route passes data to screen
GoRoute(
  path: MyRewardsRoutes.myRewards,
  builder: (_, state) {
    final extra = state.extra as MyRewardsRouteExtra?;
    return MyRewardsScreen(routeExtra: extra);
  },
),

// CORRECT — screen owns factory VM
class _MyRewardsScreenState extends State<MyRewardsScreen> {
  late final MyRewardsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<MyRewardsViewModel>()
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
      builder: (context, _) { /* use _vm */ },
    );
  }
}
```

```dart
// WRONG — provider in route
builder: (_, state) => ChangeNotifierProvider(
  create: (_) => getIt<MyRewardsViewModel>()..configure(extra),
  child: const MyRewardsScreen(),
),

// WRONG — provider in screen for factory VM
return ChangeNotifierProvider<MyRewardsViewModel>.value(
  value: _vm,
  child: ...,
);

// WRONG — factory VM in providers.dart
ChangeNotifierProvider<CollectionsViewModel>(
  create: (_) => GetIt.instance<CollectionsViewModel>(),
),
```

- Use `.value` when GetIt holds a singleton (already constructed).
- Never register a `registerFactory` ViewModel in `init<Feature>RefactorProvider()`.
- Never wrap a factory VM in both GetIt factory resolution **and** a global provider.

### 6.4 Route Data Flow

| Step | Responsibility |
|------|----------------|
| Route / `route_generator` | Decode `state.extra` or `settings.arguments` into typed params |
| Screen constructor | Accept route params as `final` fields (`routeExtra`, `initialFilters`, …) |
| Screen `initState` | `getIt<VM>()` → `vm.configure(params)` / `vm.init(...)` → `vm.load()` |
| Screen `dispose` | `_vm.dispose()` |
| Child widgets | Receive `_vm` via constructor **or** read app-scoped VM via `context.watch` |

**Rules:**

- Routes never call `vm.configure()` or `vm.load()` — that is the screen's job.
- Screens never read factory VM state via `context.watch<FactoryVm>()` unless that VM is
  intentionally app-scoped (must be `registerLazySingleton` + in `providers.dart`).
- When migrating legacy code, remove `ChangeNotifierProvider` from the route first, then from
  the screen — replace with `ListenableBuilder` or explicit `_vm` passing.

---

## 7. Localization

| Requirement | Rule |
|-------------|------|
| String source | `tr(LocaleKeys.<key>)` only |
| Import | `package:easy_localization/easy_localization.dart` |
| Hardcoded strings | Forbidden in any user-visible widget |
| `AppLocalizations` | Forbidden |
| `context.l10n` | Forbidden |
| `context.locale` | Forbidden (use `context.locale` only for locale detection, never for string lookup) |
| New key | Must be added to all locale `.json` files before merge |
| RTL support | Test all new screens in RTL layout (Arabic) |

---

## 8. Code Style & Comments

### 8.1 Comments

Comments must answer **WHY**, never **WHAT**. Good identifiers already say what.

```dart
// CORRECT — explains a non-obvious constraint
// Google Play and the App Store do not expose whether the user submitted a
// rating, so all eligibility is tracked locally.

// CORRECT — explains a workaround
// height: hasArabic ? 1.45 : 1.05,  ← disabled: causes clipping on Noto Nastaliq

// WRONG — states what the code does
/// Fetches the list of brands from the API.    // DELETE
// Increment counter
_count++;                                        // DELETE
```

**Rules:**

- No docstrings on methods/classes unless the WHY is genuinely non-obvious to the next developer.
- No `// TODO` unless a linked ticket is included (`// TODO: GOM-1234`).
- No commented-out code. Use git history.
- No section dividers like `// ─── Getters ───────`.

### 8.2 `const`

- All widget constructors must be `const` where possible.
- All entity/model constructors must be `const`.
- Empty list/map defaults must be `const []` / `const {}`.
- `const` for any literal that is widget-level (icons, colors, paddings).

### 8.3 General

- One public class per file. Private helpers in the same file are allowed.
- No unused imports. No unused variables or parameters.
- Prefer `final` over `var`. Prefer `late final` over nullable `T?` when the value is set once in `initState`.
- No `dynamic` except inside `fromJson` where JSON structure is genuinely dynamic.
- No `as` casts on external data (use `asInt`, `asBool`, etc. from `json_helpers.dart`).
- Max method length: ~30 lines. Extract named helpers for anything longer.
- Private top-level helpers go at the bottom of the file, below the last public class.

---

## 9. Testing

### 9.1 What Must Be Tested

| Component | Required Tests |
|-----------|----------------|
| ViewModel | load success, load failure, retry, guard (no double notify), dispose |
| UseCase | delegation to repository (verify call), parameter forwarding |
| Mapper | model→entity field mapping, null/empty edge cases |
| Repository impl | delegates to datasource (no logic test needed if trivial) |
| AppReviewHelper / core helpers | eligibility rules, threshold boundaries |

### 9.2 Test Structure

```dart
// CORRECT
class _MockGetBrandsUseCase extends Mock implements GetBrandsUseCase {}

void main() {
  late _MockGetBrandsUseCase getBrands;
  late BrandsGridViewModel vm;

  setUp(() {
    getBrands = _MockGetBrandsUseCase();
    vm = BrandsGridViewModel(getBrands: getBrands, getBrandsByCategory: ...);
  });

  tearDown(() async {
    vm.dispose();
    await GetIt.instance.reset();  // only if GetIt was used
  });

  group('BrandsGridViewModel.loadBrands', () {
    test('exposes brands on success', () async {
      when(() => getBrands.call()).thenAnswer((_) async => Success([_brand(1)]));

      await vm.loadBrands();

      expect(vm.isLoading, isFalse);
      expect(vm.brands, hasLength(1));
      expect(vm.error, isNull);
    });

    test('exposes error message on failure', () async {
      when(() => getBrands.call()).thenAnswer(
        (_) async => Failure<List<BrandEntity>>(
          const ErrorModel(code: ErrorEnum.connectTimeout, errorMessage: 'net error'),
        ),
      );

      await vm.loadBrands();

      expect(vm.brands, isEmpty);
      expect(vm.error, 'net error');
    });
  });
}
```

**Rules:**

- Use `mocktail` (not `mockito`) for mocking.
- Mocks are private classes (`_MockXxx extends Mock implements Xxx`).
- Test file location: `test/features/refactor/<feature>/<feature_component>_test.dart`.
- Each `group` describes one method/behavior. Each `test` describes one scenario.
- Test file must not import from `data/` layer — test the ViewModel through its public API only.
- `GetIt.instance.reset()` in `tearDown` when GetIt is touched.
- Never use `sleep` or `Future.delayed` in tests. Use fake async or mock return values.

### 9.3 Coverage Expectations

- ViewModels: every public method and every computed getter that has a branch.
- Mappers: every field, plus null input.
- Helpers (`AppReviewHelper`): every eligibility rule with boundary values.

---

## 10. Performance

### 10.1 DI

- `registerLazySingleton` for objects with shared state or expensive construction (datasources, repos, use cases, singleton VMs). Created once, reused forever.
- `registerFactory` for per-screen ViewModels that need fresh state per navigation. Created each time `getIt<T>()` is called.
- Never `registerSingleton` (eager — creates immediately at startup). Always prefer lazy.

### 10.2 ViewModel

- Only call `notifyListeners()` when state actually changes. Add equality guards before assignment:

```dart
void setQuery(String q) {
  if (_query == q) return;
  _query = q;
  notifyListeners();
}
```

- If multiple fields change atomically, make all assignments, then call `notifyListeners()` once.
- `addListener` / `removeListener` must be symmetric. Every `addListener` in the constructor has a matching `removeListener` in `dispose()`.

### 10.3 Widgets

- Prefer `const` widget constructors wherever the inputs are compile-time constants.
- Do not call `context.watch<T>()` in a large widget tree if only a small sub-tree rebuilds. Extract the sub-tree to its own `StatelessWidget` with `context.watch` inside.
- Avoid `ListView` without `.builder` for lists longer than 20 items. Use `ListView.builder` or `SliverList`.
- Do not embed `context.watch` in a deeply nested subtree — pull it up to the nearest widget boundary.

### 10.4 Images

- All images go through `AppImageWidget` (caching + error handling included).
- Never use `Image.network` directly in refactor widgets.
- URLs come from `asImageUrl(json['image'])` inside the datasource, not from raw string concatenation.

---

## 11. Anti-Patterns — Reject Immediately

The following patterns are automatic PR blockers.

### Architecture violations

```dart
// BLOCKER: Data model in presentation
import 'package:gomla_app/.../data/model/product_badge_model.dart';
class _ProductBadgeWidget extends StatelessWidget {
  final ProductBadge badge; // should be ProductBadgeEntity
}

// BLOCKER: Repository called from ViewModel
class ProductsViewModel extends ChangeNotifier {
  final ProductsRepositoryImp _repo; // should be a use case
}

// BLOCKER: context.l10n / AppLocalizations in refactor code
Text(context.l10n.brands)

// BLOCKER: UI imports data layer
import 'package:gomla_app/.../data/datasource/remote/products_remote_datasource.dart';
```

### DI violations

```dart
// BLOCKER: Missing isRegistered guard
_getIt.registerLazySingleton<BrandsRepository>(
  () => BrandsRepositoryImp(_getIt<BrandsRemoteDataSource>()),
); // forgot the if (!_getIt.isRegistered<BrandsRepository>()) guard

// BLOCKER: Registering impl type instead of interface
_getIt.registerLazySingleton<BrandsRepositoryImp>(...); // use BrandsRepository
```

### ViewModel violations

```dart
// BLOCKER: Separate isLoading flag
bool _isLoading = false; // derive from _result == null

// BLOCKER: notifyListeners in a loop / at every keypress without guard
void onQueryChanged(String q) {
  _query = q;
  notifyListeners(); // no equality guard — triggers rebuild on every keystroke
}

// BLOCKER: Missing removeListener in dispose
@override
void dispose() {
  // _profileVm.removeListener(_onProfileChanged);  ← missing → memory leak
  super.dispose();
}
```

### Presentation violations

```dart
// BLOCKER: ChangeNotifierProvider outside lib/providers.dart
GoRoute(
  builder: (_, state) => ChangeNotifierProvider(
    create: (_) => getIt<MyRewardsViewModel>(),
    child: const MyRewardsScreen(),
  ),
)

// BLOCKER: ChangeNotifierProvider in screen for factory VM
return ChangeNotifierProvider<CollectionsViewModel>.value(
  value: _vm,
  child: ...,
);

// BLOCKER: factory VM registered in initFeatureRefactorProvider()
ChangeNotifierProvider<BrandsGridViewModel>(
  create: (_) => GetIt.instance<BrandsGridViewModel>(),
);

// BLOCKER: route configures VM instead of passing data to screen
create: (_) => getIt<XxxViewModel>()..configure(state.extra as Extra),

// BLOCKER: context.watch in a callback
onTap: () {
  final vm = context.watch<ProductsViewModel>(); // use context.read
  vm.load();
}

// BLOCKER: getIt inside widget build
Widget build(BuildContext context) {
  final vm = getIt<ProductsViewModel>(); // must come from context.watch
}

// BLOCKER: Hardcoded string
Text('Search products')  // use tr(LocaleKeys.searchProducts)
```

### Code quality violations

```dart
// BLOCKER: dynamic cast on JSON
final id = json['id'] as int; // use asInt(json['id'])

// BLOCKER: Entity with fromJson
class BrandEntity {
  factory BrandEntity.fromJson(Map<String, dynamic> json) { ... } // belongs in model
}

// BLOCKER: Dead code (unreachable branch, unused import, unused parameter)

// BLOCKER: toModel() / reverse mapper with no call site
extension ProductBadgeEntityToModel on ProductBadgeEntity {
  ProductBadge toModel() => ... // delete if unused
}
```

---

## 12. Pre-Merge Checklist

The PR author completes this before requesting review. The reviewer verifies each item.

### Architecture

- [ ] Feature follows the canonical folder structure (`data/`, `domain/`, `presentation/`)
- [ ] No imports cross the layer boundary (presentation↔data)
- [ ] No feature imports another feature's `data/` or `presentation/`
- [ ] Entities are immutable (private fields, const constructor, Equatable)
- [ ] Repository interface uses `abstract interface class`
- [ ] Repository impl is a thin wrapper
- [ ] Use cases have one `call()` method each
- [ ] Data models have `fromJson` / `toMap`; entities do not
- [ ] Mappers are extensions in `data/model/` — no mapping logic in entity or model
- [ ] `ApiResult<T>` is used everywhere; no uncaught exceptions cross data→domain

### DI

- [ ] `presentation/injection.dart` exists with `init<Feature>RefactorFeatures()` and `init<Feature>RefactorProvider()`
- [ ] Registration order: datasource → repository (by interface) → use cases → ViewModels
- [ ] Every registration guarded with `if (!_getIt.isRegistered<T>())`
- [ ] `lib/injection.dart` calls `await feature_di.init<Feature>RefactorFeatures()` in correct order
- [ ] `init<Feature>RefactorProvider()` registers **only** `registerLazySingleton` VMs
- [ ] No `ChangeNotifierProvider` in routes, screens, dialogs, or sheets
- [ ] Factory VMs: route passes params to screen constructor; screen owns VM lifecycle
- [ ] `lib/providers.dart` spreads `...feature_di.init<Feature>RefactorProvider()`
- [ ] `registerLazySingleton` for shared objects, `registerFactory` for per-screen ViewModels

### ViewModel

- [ ] Extends `ChangeNotifier`, no separate `isLoading` boolean
- [ ] State derived from a single `ApiResult<T>?` field per data domain
- [ ] `notifyListeners()` called exactly twice per load (before and after)
- [ ] Equality guard on every setter before calling `notifyListeners()`
- [ ] `addListener` / `removeListener` are symmetric; `dispose()` calls `super.dispose()`
- [ ] ViewModel only depends on use cases — not repositories or datasources

### Presentation

- [ ] No `data/model/` import in any widget or screen file
- [ ] App-scoped VMs: `context.watch<T>()` in `build()`, `context.read<T>()` in callbacks
- [ ] Factory VMs: `ListenableBuilder(listenable: _vm)` or `_vm` passed to children — not Provider
- [ ] Route data flows route → screen constructor → `vm.configure` / `vm.init` in `initState`
- [ ] `getIt<T>()` not called inside widget `build()` methods
- [ ] `tr(LocaleKeys.xxx)` used for all user-visible strings; no hardcoded text
- [ ] New locale keys added to all locale JSON files

### Code Quality

- [ ] All entity/model constructors are `const`
- [ ] All widget constructors are `const` where inputs allow
- [ ] No `dynamic` casts on JSON — uses `json_helpers.dart` functions
- [ ] No comments that state WHAT; only WHY (hidden constraint, workaround, invariant)
- [ ] No commented-out code
- [ ] No unused imports, variables, or parameters
- [ ] Dead code removed (unreachable branches, reverse mappers with no callers)

### Testing

- [ ] ViewModel tests cover: load success, load failure, retry, `notifyListeners` guard
- [ ] Mapper tests cover: all fields, null input
- [ ] Core helper tests cover: eligibility boundary values
- [ ] Tests use `mocktail`, not real network or real SharedPreferences
- [ ] `GetIt.instance.reset()` in `tearDown` when GetIt is touched
- [ ] Test file lives in `test/features/refactor/<feature>/`

### Performance

- [ ] No `ListView` without `.builder` for variable-length lists
- [ ] All images use `AppImageWidget`, not `Image.network`
- [ ] No `notifyListeners()` inside a loop or called repeatedly without a guard

### RTL / Arabic

- [ ] New screens tested visually in RTL (Arabic locale)
- [ ] No hard-coded `TextDirection.ltr` overrides
- [ ] Images and icons flip correctly under `Directionality`

---

*Last updated: 2026-06-21. Maintainer: raise a PR against this file to propose changes — do not edit directly on main.*
