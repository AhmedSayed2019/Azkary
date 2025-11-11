import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/utils/helpers/gps_location_helper.dart';
import 'package:azkark/features/adhan/location_finding_screen.dart';
import 'package:azkark/features/adhan/location_not_available_screen.dart';
import 'package:azkark/features/adhan/providers/adhan_dependency_provider.dart';
import 'package:azkark/features/adhan/providers/adhan_provider.dart';
import 'package:azkark/features/adhan/providers/location_provider.dart';
import 'package:azkark/features/adhan/unknown_error_screen.dart';
import 'package:azkark/features/adhan/widgets/AdhanAvailableScreen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class AdhanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adhanDep = context.watch<AdhanDependencyProvider>();
    final locationState = context.watch<AdanLocationProvider>().locationState;

    return Scaffold(
      body: SafeArea(
        child: (locationState is LocationAvailable)
            ? ChangeNotifierProvider(
                create: (_) => AdhanProvider(adhanDep, locationState.locationInfo),
                child: AdhanAvailableScreen(locationState.locationInfo))
            : (locationState is LocationFinding)
                ? const LocationFindingScreen()
                : (locationState is LocationNotAvailable)
                    ? LocationNotAvailableScreen(locationState)
                    : const UnknownErrorScreen(),
      ),
    );
  }

  const AdhanScreen();
}
