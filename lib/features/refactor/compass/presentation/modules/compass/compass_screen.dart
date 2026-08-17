import 'package:azkark/features/refactor/compass/domain/entity/compass_location_status_entity.dart';
import 'package:azkark/features/refactor/compass/presentation/modules/compass/compass_view_model.dart';
import 'package:azkark/features/refactor/compass/presentation/modules/compass/widgets/compass_status_message.dart';
import 'package:azkark/features/refactor/compass/presentation/modules/compass/widgets/qibla_dial.dart';
import 'package:azkark/providers.dart';
import 'package:azkark/util/background.dart';
import 'package:azkark/util/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Replaces the legacy `QiblaCompassScreen` (`lib/features/compass/` and its
/// byte-for-byte duplicate `lib/pages/compass/`) — the qibla compass, backed
/// by [CompassViewModel] (a factory VM resolved from GetIt, not a
/// `ChangeNotifierProvider`).
class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  late final CompassViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = getIt<CompassViewModel>()..init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Background(),
      Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            tr('compass'),
            style: TextStyle(
              color: teal[50],
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: ListenableBuilder(
            listenable: _vm,
            builder: (context, _) => _buildBody(context),
          ),
        ),
      ),
    ]);
  }

  Widget _buildBody(BuildContext context) {
    if (_vm.isLoading && _vm.status == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vm.error != null) {
      return CompassStatusMessage(message: _vm.error!, onRetry: _vm.retry);
    }

    final status = _vm.status;
    if (status == null) {
      return const SizedBox.shrink();
    }

    if (!status.serviceEnabled) {
      return CompassStatusMessage(
        message: 'Please enable Location service',
        onRetry: _vm.retry,
      );
    }

    switch (status.permission) {
      case CompassPermissionStatus.granted:
        break;
      case CompassPermissionStatus.denied:
        return CompassStatusMessage(
          message: 'Location service permission denied',
          onRetry: _vm.retry,
        );
      case CompassPermissionStatus.deniedForever:
        return CompassStatusMessage(
          message: 'Location service denied forever',
          onRetry: _vm.retry,
        );
      case CompassPermissionStatus.unavailable:
        return CompassStatusMessage(
          message: 'Unknown location service error',
          onRetry: _vm.retry,
        );
    }

    if (_vm.sensorError != null && _vm.direction == null) {
      return CompassStatusMessage(
        message: _vm.sensorError!,
        onRetry: _vm.retry,
      );
    }

    final direction = _vm.direction;
    if (direction == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: QiblaDial(direction: direction)),
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'قم بمحاذاة رأسي السهمين\nلا تضع الجهاز بالقرب من جسم معدني.\nقم بمعايرة البوصلة في كل مرة تستخدمها فيها.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
