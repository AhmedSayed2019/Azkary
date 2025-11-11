import 'package:azkark/core/utils/helpers/extensions.dart';
import 'package:azkark/generated/assets.dart';
import 'package:flutter/material.dart';

class LocationFindingScreen extends StatelessWidget {
  const LocationFindingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Assets.adanLocationNa, width: 156,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Finding Location...", style: context.textTheme.headlineMedium,),
            ),
            const LinearProgressIndicator()
          ],
        ),
      ),
    );
  }
}
