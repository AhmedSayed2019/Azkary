import 'package:azkark/data/models/adhan.dart';
import 'package:azkark/data/models/locationInfo.dart';
import 'package:azkark/features/adhan/providers/adhan_dependency_provider.dart';
import 'package:azkark/features/adhan/providers/adhan_provider.dart';
import 'package:azkark/localization/app_localizations.dart';

class AdhanNotificationProvider extends AdhanProvider {
  AdhanNotificationProvider(AdhanDependencyProvider adhanDependencyProvider,
      LocationInfo locationInfo,)
      : super(adhanDependencyProvider, locationInfo);

  Adhan? get notificationAdhan {
    final list = getAdhanData(DateTime.now())
      ..forEach((element) {
        element.modifyForNotification();
      });

    return list.firstWhere(
        (element) =>
            element.isCurrent &&
            (adhanDependencyProvider.showPersistant ||
                adhanDependencyProvider.notifyID(element.type) != 0),
        orElse: () => null as Adhan);
  }

  Adhan? get nextNotifcationAdhan {
    final List<Adhan> fullList = [];
    final currentTime = DateTime.now();
    fullList.addAll(getAdhanData(currentTime));
    fullList.addAll(getAdhanData(DateTime.now().add(const Duration(days: 1))));
    fullList.addAll(getAdhanData(DateTime.now().add(const Duration(days: 2))));

    fullList.forEach((element) {
      element.modifyForNotification();
    });

    final filteredList = fullList
        .where((element) =>
            element.startTime.isAfter(currentTime) &&
            (adhanDependencyProvider.showPersistant || adhanDependencyProvider.notifyID(element.type) != 0))
        .toList();

    if (filteredList.length > 0) {
      return filteredList[0];
    } else {
      return null;
    }
  }
}
