import 'dart:async';
import 'dart:math' show pi;
import 'package:azkark/generated/assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import '../../util/background.dart';
import '../../util/colors.dart';
import '../../util/helpers.dart';
import 'widget/location_error_widget.dart';


class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({Key? key}) : super(key: key);

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  final _locationStreamController =
  StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;

  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Background(),

        Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            title: Text(
              translate(context, 'compass'),
              style: new TextStyle(
                color: teal[50],
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
              stream: stream,
              builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CupertinoActivityIndicator();
                }
                if (snapshot.data!.enabled == true) {
                  switch (snapshot.data!.status) {
                    case LocationPermission.always:
                    case LocationPermission.whileInUse:
                      return QiblahCompassWidget();

                    case LocationPermission.denied:
                      return LocationErrorWidget(
                        error: "Location service permission denied",
                        callback: _checkLocationStatus,
                      );
                    case LocationPermission.deniedForever:
                      return LocationErrorWidget(
                        error: "Location service Denied Forever !",
                        callback: _checkLocationStatus,
                      );
                  // case GeolocationStatus.unknown:
                  //   return LocationErrorWidget(
                  //     error: "Unknown Location service error",
                  //     callback: _checkLocationStatus,
                  //   );
                    default:
                      return Container();
                  }
                } else {
                  return LocationErrorWidget(
                    error: "Please enable Location service",
                    callback: _checkLocationStatus,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _locationStreamController.close();
    FlutterQiblah().dispose();
  }
}

class QiblahCompassWidget extends StatelessWidget {
  final _kaabaSvg = SvgPicture.asset(Assets.campass4);

  QiblahCompassWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var platformBrightness = Theme.of(context).brightness;
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoActivityIndicator();
        }

        final qiblahDirection = snapshot.data!;
        var angle = ((qiblahDirection.qiblah) * (pi / 180) * -1);

        // if (_angle < 5 && _angle > -5) print('IN RANGE');

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.rotate(
              angle: angle,
              child: SvgPicture.asset(Assets.campass5, // compass
                  color: platformBrightness == Brightness.dark ? Colors.yellow : teal),
            ),
            _kaabaSvg,
            SvgPicture.asset(Assets.campass3, //needle
                color: platformBrightness == Brightness.dark ? Colors.yellow : teal),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "قم بمحاذاة رأسي السهمين\nلا تضع الجهاز بالقرب من جسم معدني.\قم بمعايرة البوصلة في كل مرة تستخدمها فيها.",
                textAlign: TextAlign.center,
              ),
            )
          ],
        );
      },
    );
  }
}