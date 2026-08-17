import 'package:azkark/features/refactor/compass/domain/entity/qibla_direction_entity.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart' show QiblahDirection;

/// Data-layer DTO wrapping `flutter_qiblah`'s [QiblahDirection] plugin type.
class QiblaDirectionModel {
  const QiblaDirectionModel({
    required double qiblah,
    required double direction,
    required double offset,
  })  : _qiblah = qiblah,
        _direction = direction,
        _offset = offset;

  factory QiblaDirectionModel.fromPlugin(QiblahDirection direction) =>
      QiblaDirectionModel(
        qiblah: direction.qiblah,
        direction: direction.direction,
        offset: direction.offset,
      );

  final double _qiblah;
  final double _direction;
  final double _offset;

  double get qiblah => _qiblah;

  double get direction => _direction;

  double get offset => _offset;

  QiblaDirectionEntity toEntity() => QiblaDirectionEntity(
        qiblah: _qiblah,
        direction: _direction,
        offset: _offset,
      );
}
