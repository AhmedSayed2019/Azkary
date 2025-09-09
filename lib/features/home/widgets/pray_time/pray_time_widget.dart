// mq_salaah_time_widget.dart
import 'package:azkark/features/home/widgets/pray_time/provider/location_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'show/alerts.dart';
import 'widgets/mq_salaah_card.dart';

class MqSalaahTimeWidget extends StatelessWidget {
  const MqSalaahTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, provider, _) {
        if (provider.eventState is LocationEventNewLocation) {
          final name = provider.locationName;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onEventNewLocation(context, name);
          });
        }

        final pos = provider.position; // may be null initially
        return MqSalaahCard(
          fajrLabel: tr( '_fajr'),
          zuhrLabel: tr('_zuhr'),
          asrLabel: tr('_asr'),
          maghribLabel: tr('_maghrib'),
          ishaLabel: tr('_isya'),
          locationLabel: provider.locationName,
          location: provider.timeZoneLocation,
          onLocationPressed: () {},

          // Guard against null before the first fix:
          lat: pos.latitude ?? 0.0,
          lon: pos.longitude ?? 0.0,
        );
      },
    );
  }

  void _onEventNewLocation(BuildContext context, String newLocation) {
    AppAlert.showUpdateLocation(
      context: context,
      newLocation: newLocation,
      onConfirm: (ctx) {
        context.read<LocationProvider>().updateLocation(); // ⬅️ see step 2
        Navigator.pop(ctx);
      },
      onCancel: Navigator.pop,
    );
  }
}

// import 'package:azkark/features/home/widgets/pray_time/cubit/location_cubit.dart';
// import 'package:azkark/features/home/widgets/pray_time/l10n/l10.dart';
// import 'package:azkark/features/home/widgets/pray_time/show/alerts.dart';
// import 'package:azkark/features/home/widgets/pray_time/widgets/mq_salaah_card.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
//
// class MqSalaahTimeWidget extends StatelessWidget {
//   const MqSalaahTimeWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: BlocConsumer<LocationCubit, LocationState>(
//         listener: (BuildContext context, LocationState state) {
//           final eventState = state.eventState;
//           if (eventState is LocationEventNewLocation) {
//             _onEventNewLocation(context, eventState.newLocationName);
//           }
//         },
//         builder: (context, state) {
//           return MqSalaahCard(
//             fajrLabel: tr('fajr'),
//             zuhrLabel: tr('zuhr'),
//             asrLabel: tr('asr'),
//             maghribLabel: tr('maghrib'),
//             ishaLabel: tr('isya'),
//             locationLabel: state.locationName,
//             location: state.timeZoneLocation,
//             onLocationPressed: () {},
//             lat: state.position.latitude,
//             lon: state.position.longitude,
//           );
//         },
//       ),
//     );
//   }
//
//   void _onEventNewLocation(BuildContext context, String newLocation) {
//     AppAlert.showUpdateLocation(
//       context: context,
//       newLocation: newLocation,
//       onConfirm: (ctx) {
//         context.read<LocationCubit>().updateLocation();
//         Navigator.pop(ctx);
//       },
//       onCancel: Navigator.pop,
//     );
//   }
// }
