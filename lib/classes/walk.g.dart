// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalkAdapter extends TypeAdapter<Walk> {
  @override
  final int typeId = 1;

  @override
  Walk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Walk()
      ..walkTitle = fields[1] as String
      ..waypoints = (fields[2] as List).cast<LatLngAdapter>()
      ..walkStartTime = fields[3] as DateTime
      ..walkEndTime = fields[4] as DateTime
      ..totalTravelDistanceMetres = fields[5] as double
      ..totalTravelDistanceMiles = fields[6] as double
      ..maxDistanceFromStartMetres = fields[7] as double
      ..maxDistanceFromStartMiles = fields[8] as double
      ..totalElevationChangeMetres = fields[9] as double
      ..walkPhotos = (fields[10] as List).cast<File>();
  }

  @override
  void write(BinaryWriter writer, Walk obj) {
    writer
      ..writeByte(10)
      ..writeByte(1)
      ..write(obj.walkTitle)
      ..writeByte(2)
      ..write(obj.waypoints)
      ..writeByte(3)
      ..write(obj.walkStartTime)
      ..writeByte(4)
      ..write(obj.walkEndTime)
      ..writeByte(5)
      ..write(obj.totalTravelDistanceMetres)
      ..writeByte(6)
      ..write(obj.totalTravelDistanceMiles)
      ..writeByte(7)
      ..write(obj.maxDistanceFromStartMetres)
      ..writeByte(8)
      ..write(obj.maxDistanceFromStartMiles)
      ..writeByte(9)
      ..write(obj.totalElevationChangeMetres)
      ..writeByte(10)
      ..write(obj.walkPhotos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
