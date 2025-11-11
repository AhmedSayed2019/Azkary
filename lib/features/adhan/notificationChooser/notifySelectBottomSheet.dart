import 'package:azkark/core/utils/helpers/extensions.dart';
import 'package:azkark/data/models/adhan.dart';
import 'package:azkark/features/adhan/providers/adhan_dependency_provider.dart';
import 'package:azkark/features/adhan/providers/adhan_play_back_provider.dart';
import 'package:azkark/features/adhan/widgets/dragger.dart';
import 'package:azkark/features/adhan/widgets/number_spinner.dart';
import 'package:azkark/features/adhan/widgets/settings_section.dart';
import 'package:azkark/features/adhan/widgets/settings_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class NotifySelectBottomSheet extends StatelessWidget {
  final Adhan _adhan;

  const NotifySelectBottomSheet(this._adhan);
  @override
  Widget build(BuildContext context) {
    // final appLocale = context.appLocale;
    final adhanDependency = context.watch<AdhanDependencyProvider>();
    final notifyDelay = adhanDependency.getNotifyBefore(_adhan.type);
    final adhanPlayback = context.watch<AdhanPlayBackProvider>();
    final playing = adhanPlayback.playing;
    final currentNotify = adhanDependency.notifyID(_adhan.type);

    SettingsClickable _notificationSamplePlayer({
      required String title,
      required int notifyID,
    }) {
      return SettingsClickable(
        onClick: () => adhanDependency.changeNotifyType(_adhan.type, notifyID),
        title: title,
        leading: Icon(
            notifyID == 0 ? Icons.notifications_off : notifyID == 1 ? Icons
                .notifications : Icons.volume_up,),
        selected: currentNotify == notifyID,
        trailing: notifyID >= 2 ? IconButton(
          onPressed: () => adhanPlayback.playBack(notifyID),
          icon: Icon(playing == notifyID ? Icons.stop : Icons.play_arrow),
        ) : null,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          minChildSize: 0.4,
          builder: (_, controller) =>
              Container(
                margin: const EdgeInsets.only(top: 32),
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20),),),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Dragger(),
                      const SizedBox(height: 8),
                      Text(
                        '${_adhan.title} ${tr('notification')}', style: context.textTheme.headlineMedium?.copyWith(color: context.textTheme.headlineMedium?.color,),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SettingsSection(title: tr("type"), tiles: [
                        _notificationSamplePlayer(title: tr("silentAdhan"), notifyID: 0),
                        _notificationSamplePlayer(title: tr("notificationOnly"), notifyID: 1),
                        _notificationSamplePlayer(title: tr("alarm"), notifyID: 2),
                        _notificationSamplePlayer(title: tr("ringtone"), notifyID: 3),
                        _notificationSamplePlayer(title: tr("adhanMecca"), notifyID: 4),
                        _notificationSamplePlayer(title: tr("inexactNotify"), notifyID: 5),
                      ],),
                      SettingsSection(title:  tr("timing"), tiles: [
                        SettingsToggle(
                          onToggle: (val) =>
                          val
                              ? adhanDependency.changeNotifyDelay(
                            _adhan.type, -5,)
                              : adhanDependency.changeNotifyDelay(
                            _adhan.type, 0,),
                          title: tr("inexactNotify"),
                          value: notifyDelay != 0,
                        ),
                        if (notifyDelay != 0)
                          SettingsClickable(
                            onClick: () {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    NumberSpinner(
                                      title: tr('clickToChange'),
                                      initialIndex: notifyDelay,
                                      start: -59,
                                      end: (_adhan.timeOfWaqt.inMinutes - 2) > 59 ? 59 : (_adhan.timeOfWaqt.inMinutes - 2),
                                      onChanged: (val) {adhanDependency.changeNotifyDelay(_adhan.type, val,);},
                                    ),
                              );
                            },
                            title: notifyDelay < 0
                                ? tr('notifyMeBefore',namedArgs: {'min': NumberFormat('00', context.locale.languageCode).format(notifyDelay * -1)},)
                                : tr('notifyMeAfter',namedArgs: {'min': NumberFormat('00', context.locale.languageCode).format(notifyDelay * -1)},),
                            subtitle: tr('clickToChange'),
                          )
                      ],),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
