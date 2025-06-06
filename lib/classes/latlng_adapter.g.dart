// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latlng_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LatLngAdapterAdapter extends TypeAdapter<LatLngAdapter> {
  @override
  final int typeId = 2;

  @override
  LatLngAdapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LatLngAdapter(
      fields[0] as double,
      fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LatLngAdapter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLngAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
