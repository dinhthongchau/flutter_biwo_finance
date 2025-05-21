import 'package:hive/hive.dart';
import 'package:finance_management/data/model/user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0; // Choose a unique ID (0-223)

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as int,
      fullName: fields[1] as String,
      email: fields[2] as String,
      mobile: fields[3] as String,
      dob: fields[4] as String,
      password: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(6) // Number of fields
      ..writeByte(0) // Field ID for 'id'
      ..write(obj.id)
      ..writeByte(1) // Field ID for 'fullName'
      ..write(obj.fullName)
      ..writeByte(2) // Field ID for 'email'
      ..write(obj.email)
      ..writeByte(3) // Field ID for 'mobile'
      ..write(obj.mobile)
      ..writeByte(4) // Field ID for 'dob'
      ..write(obj.dob)
      ..writeByte(5) // Field ID for 'password'
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}