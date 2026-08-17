import 'package:equatable/equatable.dart';

/// A single live reading from the device's compass sensor, combined with the
/// calculated Qibla offset.
///
/// - [direction]: device heading in degrees, 0-360, 0 = north.
/// - [qiblah]: qibla bearing in degrees, 0-360, offset from north.
/// - [offset]: raw great-circle offset of the Kaaba from true north at the
///   user's current position.
class QiblaDirectionEntity extends Equatable {
  const QiblaDirectionEntity({
    required double qiblah,
    required double direction,
    required double offset,
  })  : _qiblah = qiblah,
        _direction = direction,
        _offset = offset;

  final double _qiblah;
  final double _direction;
  final double _offset;

  double get qiblah => _qiblah;

  double get direction => _direction;

  double get offset => _offset;

  @override
  List<Object?> get props => [_qiblah, _direction, _offset];
}
