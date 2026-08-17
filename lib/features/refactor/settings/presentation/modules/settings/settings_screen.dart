import 'package:azkark/core/res/resources.dart';
import 'package:azkark/features/refactor/settings/domain/entity/settings_entity.dart';
import 'package:azkark/features/refactor/settings/presentation/settings_view_model.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/util/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/setting_font_size.dart';
import 'widgets/setting_font_type.dart';
import 'widgets/settings_item.dart';

/// Replaces the legacy `Settings` page (`lib/pages/settings/settings_page.dart`).
///
/// `SettingsViewModel` is an app-scoped VM (`registerLazySingleton`, exposed
/// via `ChangeNotifierProvider` in `lib/providers.dart`), so this screen
/// reads it with `context.watch` rather than resolving a factory VM from
/// GetIt.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SettingsViewModel>().load();
    });
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          topLeft: Radius.circular(20)),
      border: Border.all(color: teal[600]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final settings = vm.settings;

    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            tr('settings_bar'),
            style: TextStyle(
              color: teal[50],
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: settings == null
            ? Center(
                child: vm.error != null
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(vm.error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: vm.retry,
                              child: Text(tr('tryAgain')),
                            ),
                          ],
                        ),
                      )
                    : const CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    _buildPublicSettings(context, settings, vm),
                    _buildAzkarSettingsCard(context, settings, vm),
                  ],
                ),
              ),
      ),
    ]);
  }

  Widget _buildAzkarSettingsCard(
    BuildContext context,
    SettingsEntity settings,
    SettingsViewModel vm,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: _buildTitle(context, 'إعدادات الأذكار'),
          ),
          Container(
            decoration: _decoration(context),
            child: Column(
              children: <Widget>[
                SettingsItem(
                  activeTitle: tr('popup_menu_counter_true'),
                  inactiveTitle: tr('popup_menu_counter_false'),
                  value: settings.counter,
                  onChanged: vm.updateCounter,
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(20)),
                ),
                SettingsItem(
                  activeTitle: tr('popup_menu_diacritics_true'),
                  inactiveTitle: tr('popup_menu_diacritics_false'),
                  value: settings.diacritics,
                  onChanged: vm.updateDiacritics,
                ),
                SettingsItem(
                  activeTitle: tr('popup_menu_sanad_true'),
                  inactiveTitle: tr('popup_menu_sanad_false'),
                  value: settings.sanad,
                  onChanged: vm.updateSanad,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicSettings(
    BuildContext context,
    SettingsEntity settings,
    SettingsViewModel vm,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: _buildTitle(context, 'الإعدادات العامة')),
          Container(
            decoration: _decoration(context),
            child: Column(
              children: <Widget>[
                SettingFontType(
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(20)),
                  fontType: settings.fontFamily,
                  onChanged: vm.updateFontFamily,
                ),
                SettingFontSize(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  fontSize: settings.fontSize,
                  onChangedEnd: vm.updateFontSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String text) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: Text(
          text,
          style: const TextStyle().semiBoldStyle(fontSize: 16).primaryTextColor(),
        ),
      ),
    );
  }
}
