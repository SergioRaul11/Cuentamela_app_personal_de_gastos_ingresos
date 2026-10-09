// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Adaptador escrito a mano con la misma forma que produce `hive_generator`.
// Si ejecutas `dart run build_runner build --delete-conflicting-outputs`
// se regenerará con un contenido equivalente.

part of 'transaccion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransaccionModelAdapter extends TypeAdapter<TransaccionModel> {
  @override
  final int typeId = 1;

  @override
  TransaccionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransaccionModel(
      id: fields[0] as String,
      tipoCodigo: fields[1] as String,
      descripcion: fields[2] as String,
      monto: (fields[3] as num).toDouble(),
      fecha: fields[4] as DateTime,
      creadoEn: fields[5] as DateTime,
      objetivoId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransaccionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tipoCodigo)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.monto)
      ..writeByte(4)
      ..write(obj.fecha)
      ..writeByte(5)
      ..write(obj.creadoEn)
      ..writeByte(6)
      ..write(obj.objetivoId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransaccionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
