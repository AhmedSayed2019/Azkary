import 'package:azkark/core/utils/helpers/extensions.dart';
import 'package:azkark/core/utils/helpers/gps_location_helper.dart';
import 'package:azkark/features/adhan/providers/location_provider.dart';
import 'package:azkark/generated/assets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationNotAvailableScreen extends StatelessWidget {
  final LocationNotAvailable _locationNotAvailable;

  const LocationNotAvailableScreen(this._locationNotAvailable);

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.read<AdanLocationProvider>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Assets.adanLocationNa,
                width: 128,
              ),
               Text(tr("noLocationAvailable")),
              Text(
                '${_locationNotAvailable.cause}',
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              TextButton(
                  onPressed: () =>
                      locationProvider.updateLocationWithGPS(background: false),
                  child:  Text(tr("tryAgain")),)
            ],
          ),
        ),
      ),
    );
  }
}
