// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Adaptador escrito a mano con la misma forma que produce `hive_generator`.
// Si ejecutas `dart run build_runner build --delete-conflicting-outputs`
// se regenerará con un contenido equivalente.

part of 'objetivo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ObjetivoModelAdapter extends TypeAdapter<ObjetivoModel> {
  @override
  final int typeId = 2;

  @override
  ObjetivoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ObjetivoModel(
      id: fields[0] as String,
      nombre: fields[1] as String,
      montoObjetivo: (fields[2] as num).toDouble(),
      montoAhorrado: (fields[3] as num).toDouble(),
      creadoEn: fields[4] as DateTime,
      iconoIndex: fields[5] as int,
      colorValor: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ObjetivoModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.montoObjetivo)
      ..writeByte(3)
      ..write(obj.montoAhorrado)
      ..writeByte(4)
      ..write(obj.creadoEn)
      ..writeByte(5)
      ..write(obj.iconoIndex)
      ..writeByte(6)
      ..write(obj.colorValor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObjetivoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
