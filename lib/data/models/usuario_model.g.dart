// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Adaptador escrito a mano con la misma forma que produce `hive_generator`.
// Si ejecutas `dart run build_runner build --delete-conflicting-outputs`
// se regenerará con un contenido equivalente.

part of 'usuario_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsuarioModelAdapter extends TypeAdapter<UsuarioModel> {
  @override
  final int typeId = 0;

  @override
  UsuarioModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UsuarioModel(
      nombre: fields[0] as String,
      balanceInicial: (fields[1] as num).toDouble(),
      creadoEn: fields[2] as DateTime,
      moneda: fields[3] as String,
      onboardingCompletado: fields[4] as bool,
      temaOscuro: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UsuarioModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.balanceInicial)
      ..writeByte(2)
      ..write(obj.creadoEn)
      ..writeByte(3)
      ..write(obj.moneda)
      ..writeByte(4)
      ..write(obj.onboardingCompletado)
      ..writeByte(5)
      ..write(obj.temaOscuro);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
