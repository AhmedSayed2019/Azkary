import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

class SensorNotSupported extends StatelessWidget {
  const SensorNotSupported({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('sensors_not_supported'.tr()),
    );
  }
}
