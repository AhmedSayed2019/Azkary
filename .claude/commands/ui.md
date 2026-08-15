# /ui — UI Builder Agent

User request: $ARGUMENTS

---

## Step 1 — Read context before writing a single line of code

Run these reads in parallel, every time:

1. Read `ui.md` (project root) — design-system rules.
2. Read `lib/features/refactor/products/presentation/modules/collections/collections_screen.dart` — canonical simple-screen example.
3. Read `lib/features/refactor/products/presentation/shared/widgets/products_list_view.dart` — canonical shared-widget example.

If `$ARGUMENTS` names an existing file, read that file too before touching it.

---

## Step 2 — Parse the request

From `$ARGUMENTS` extract:
- **Action**: `create` / `update` / `new widget` / `fix`
- **Screen or widget name**: e.g. `DiscountsScreen`, `ProductCard`
- **Feature folder**: e.g. `refactor/products`, `refactor/categories`
- **VM fields needed** (if creating a screen): loading, error, list, any extra state
- **API mode** (if using `ProductsListView`): `catalog`, `discounts`, `search`, etc.

If any of these are missing and cannot be inferred from context, ask **one focused question** with all missing items listed together. Do not ask multiple rounds.

---

## Step 3 — Determine output files

| Scenario | Files to create / update |
|---|---|
| New screen (uses `ProductsListView`) | `<screen>_screen.dart` only |
| New screen (custom list / no VM) | `<screen>_screen.dart` + widget classes in same file |
| New screen (owns VM) | `<screen>_screen.dart` + `<screen>_view_model.dart` in `view_models/` |
| New shared widget | `lib/features/refactor/products/presentation/shared/widgets/<name>.dart` |
| Update existing screen | Edit only the target file; no new files unless explicitly requested |

Exact path pattern:
```
lib/features/refactor/<feature>/presentation/modules/<screen_name>/<screen_name>_screen.dart
lib/features/refactor/<feature>/presentation/shared/view_models/<screen_name>_view_model.dart
lib/features/refactor/<feature>/presentation/shared/widgets/<widget_name>.dart
```

---

## Step 4 — Write complete files

Write every file in full — no `// TODO`, no `// implement later`, no stub bodies.

### Non-negotiable rules (break any of these → the code is wrong)

| Rule | ✓ Correct | ✗ Wrong |
|---|---|---|
| Text widget | `GText(tr(LocaleKeys.x))` | `Text('...')` |
| Colors | `AppColor.primary500.themeColor` | `GColors.*`, `context.colors.*`, `Color(0xFF...)` |
| Sizes | `AppSize.s16`, `kScreenPadding`, `kCardRadius` | `16.w`, `12.r`, raw doubles |
| Localization | `tr(LocaleKeys.key)` | any hard-coded English string |
| Widget structure | Separate `StatelessWidget` class | `Widget _buildXxx()` method |
| State management | `context.watch<VM>()` inside `Builder` | `BlocBuilder`, `Consumer<VM>` |
| Lists / grids | `CustomPaginationGridview` / `CustomPaginationListView` | `ListView.builder` |
| 3-state UI | `CustomScreenStateLayout(...)` | raw `if (isLoading)` / `if (error != null)` |
| VM lifecycle | `GetIt.instance<VM>()` in `initState`, `dispose()` | `context.read<VM>()` in `initState` |

### Screen template (owns VM)

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gomla_app/core/res/color.dart';
import 'package:gomla_app/core/widgets/g_text.dart';
import 'package:gomla_app/generated/locale_keys.g.dart';
import 'package:provider/provider.dart';
// ... feature imports

class XxxScreen extends StatefulWidget {
  const XxxScreen({super.key});
  @override State<XxxScreen> createState() => _XxxScreenState();
}

class _XxxScreenState extends State<XxxScreen> {
  late final XxxViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = GetIt.instance<XxxViewModel>()..loadData();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<XxxViewModel>.value(
      value: _vm,
      child: Builder(builder: (context) {
        final vm = context.watch<XxxViewModel>();
        return Scaffold(
          appBar: AppBar(
            title: GText(tr(LocaleKeys.xxx)),
            backgroundColor: AppColor.gray50.themeColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(child: _XxxBody(vm: vm)),
        );
      }),
    );
  }
}

// Each section is a separate class — no _buildXxx() methods
class _XxxBody extends StatelessWidget {
  const _XxxBody({required this.vm});
  final XxxViewModel vm;

  @override
  Widget build(BuildContext context) {
    return CustomScreenStateLayout(
      isLoading: vm.isLoading && vm.items.isEmpty,
      isEmpty:   !vm.isLoading && vm.items.isEmpty && vm.error == null,
      error:     vm.error,
      onRetry:   vm.loadData,
      builder:   (_) => _XxxContent(items: vm.items),
    );
  }
}

class _XxxContent extends StatelessWidget {
  const _XxxContent({required this.items});
  final List<XxxEntity> items;

  @override
  Widget build(BuildContext context) {
    // ... content
  }
}
```

### Responsive tablet rule (always include)

```dart
final isTablet = MediaQuery.of(context).size.width >= 768;
final crossAxisCount = isTablet ? 3 : 2;
// For layout constraining:
ConstrainedBox(constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity), ...)
```

### `ApiResult<PaginationListEntity<T>>` state wiring

```dart
// Outside closure — type promotion works:
isEmpty:   responseModel is Success<PaginationListEntity<T>> && responseModel.data.list.isEmpty,
error:     responseModel is Failure<PaginationListEntity<T>> ? responseModel.error.errorMessage : null,

// Inside closure — cast required (promotion doesn't carry over):
builder: (_) {
  final data = (responseModel as Success<PaginationListEntity<T>>).data;
  return CustomPaginationGridview<T>(
    list:         data.list,
    currentPage:  data.pagination.currentPage,
    hasMorePages: data.pagination.hasMorePages,
    isMoreLoading: vm.isLoading,
    onLoadMore:   () => vm.getList(isLoadMore: true),
    builder:      (ctx, i) => _ItemCard(item: data.list[i]),
  );
},
```

---

## Step 5 — Verify (mandatory, not optional)

After writing all files:

```bash
flutter analyze lib/features/refactor/<feature>/
```

- If **zero errors/warnings**: report ✅ clean.
- If **errors found**: fix them immediately, re-run, do not report done until clean.
- Warnings about pre-existing issues in OTHER files are OK to note but not required to fix.

---

## Step 6 — Report

```
## Files written
- lib/features/refactor/.../xxx_screen.dart   (new)
- lib/features/refactor/.../xxx_view_model.dart  (new)

## Analysis
✅ 0 errors, 0 warnings in feature folder.

## Usage
Navigator.push(context, MaterialPageRoute(builder: (_) => const XxxScreen()));
// or via route_generator: ProductsRoutes.xxx
```

---

## What this agent does NOT do

- Does not update `injection.dart` or `route_generator.dart` unless the user explicitly asks.
- Does not modify test files.
- Does not touch `lib/base/` or `lib/core/`.
- Does not create new `LocaleKeys` — use `/translators` for that.
