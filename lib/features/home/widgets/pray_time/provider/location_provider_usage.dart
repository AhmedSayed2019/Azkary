// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:mq_prayer_time/mq_prayer_time.dart';
// import 'location_provider.dart';
//
// // Example of how to set up the LocationProvider in your app
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => LocationProvider(MqLocationClient()),
//       child: MaterialApp(
//         title: 'Location Provider Example',
//         home: const LocationScreen(),
//       ),
//     );
//   }
// }
//
// // Example of how to consume the LocationProvider in a widget
// class LocationScreen extends StatefulWidget {
//   const LocationScreen({super.key});
//
//   @override
//   State<LocationScreen> createState() => _LocationScreenState();
// }
//
// class _LocationScreenState extends State<LocationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the location provider
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<LocationProvider>().init();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Location Provider Example'),
//       ),
//       body: Consumer<LocationProvider>(
//         builder: (context, locationProvider, child) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Current Location:',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 8),
//                 Text('Name: ${locationProvider.locationName}'),
//                 Text('Timezone: ${locationProvider.timeZoneLocation}'),
//                 Text('Latitude: ${locationProvider.position.latitude}'),
//                 Text('Longitude: ${locationProvider.position.longitude}'),
//                 const SizedBox(height: 16),
//
//                 // Handle different event states
//                 _buildEventStateWidget(locationProvider.eventState),
//
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     locationProvider.updateLocation();
//                   },
//                   child: const Text('Update Location'),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildEventStateWidget(LocationEventState eventState) {
//     switch (eventState) {
//       case LocationEventInitial():
//         return const Text('Location initialized');
//
//       case LocationEventKeepLocation():
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Keeping current location:'),
//             Text('Name: ${eventState.keepLocationName}'),
//             Text('Timezone: ${eventState.keepTimeZoneLocation}'),
//           ],
//         );
//
//       case LocationEventNewLocation():
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('New location detected:'),
//             Text('Name: ${eventState.newLocationName}'),
//             Text('Timezone: ${eventState.newTimeZoneLocation}'),
//           ],
//         );
//     }
//   }
// }
//
// // Alternative way to access the provider using context.watch
// class LocationInfoWidget extends StatelessWidget {
//   const LocationInfoWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final locationProvider = context.watch<LocationProvider>();
//
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Location: ${locationProvider.locationName}'),
//             Text('Timezone: ${locationProvider.timeZoneLocation}'),
//             Text('Position: ${locationProvider.position.latitude}, ${locationProvider.position.longitude}'),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Example of using Selector for performance optimization
// class LocationNameWidget extends StatelessWidget {
//   const LocationNameWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Selector<LocationProvider, String>(
//       selector: (context, provider) => provider.locationName,
//       builder: (context, locationName, child) {
//         return Text('Current Location: $locationName');
//       },
//     );
//   }
// }
//
