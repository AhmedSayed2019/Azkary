import 'package:azkark/core/utils/helpers/gps_location_helper.dart';
import 'package:azkark/features/adhan/location_finding_screen.dart';
import 'package:azkark/features/adhan/location_not_available_screen.dart';
import 'package:azkark/features/adhan/providers/location_provider.dart';
import 'package:azkark/features/adhan/unknown_error_screen.dart';
import 'package:azkark/features/qibla/qiblaAvailableScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


class QiblaScreen extends StatelessWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final locationState =
        context.watch<AdanLocationProvider>().locationState;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(tr('qibla')),
      ),
      body: SafeArea(
        child: (locationState is LocationAvailable)
            ? QiblaAvailableScreen(locationState.locationInfo)
            : (locationState is LocationFinding)
                ? const LocationFindingScreen()
                : (locationState is LocationNotAvailable)
                    ? LocationNotAvailableScreen(locationState)
                    : const UnknownErrorScreen(),
      ),
    );
  }
}
