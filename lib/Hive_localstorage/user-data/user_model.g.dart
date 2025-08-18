// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      
      userId: fields[0] as String,
      userName: fields[1] as String,
      isGoogleUser: fields[2] as bool,
      interestedTags: (fields[3] as List).cast<String>(),
      maskedName: fields[4] as String,
      canMaskMessage: fields[5] as bool,
      email: fields[6] as String,
      dob: fields[7] as String,
      phone: fields[8] as String,
      currency: fields[9] as String,
      coins: fields[10] as int,
      coupons: fields[11] as int,
      score: fields[12] as int,
      aboutMe: fields[13] as String,
      avatar: fields[14] as String,
      avatarBackGround: fields[15] as String,
      likedPosts: (fields[16] as List).cast<String>(),
      likedComments: (fields[17] as List).cast<String>(),
      likedProducts: (fields[18] as List).cast<String>(),
      expense: fields[19] as int,
      firstTimeLogin: fields[20] as bool,
      isBankAccountLinked: fields[21] as bool,
      fetchInProgress: fields[22] as bool,
      cupertinoPin: fields[23] as String,
      cupertinoAttemptCount: fields[24] as bool,
      selectedBank: fields[25] as String,
      firstFetchedDate: fields[26] as String,
      friendsList: (fields[27] as List).cast<dynamic>(),
      maskedConnections: (fields[28] as List).cast<dynamic>(),
      maskedConnected: (fields[29] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.isGoogleUser)
      ..writeByte(3)
      ..write(obj.interestedTags)
      ..writeByte(4)
      ..write(obj.maskedName)
      ..writeByte(5)
      ..write(obj.canMaskMessage)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.dob)
      ..writeByte(8)
      ..write(obj.phone)
      ..writeByte(9)
      ..write(obj.currency)
      ..writeByte(10)
      ..write(obj.coins)
      ..writeByte(11)
      ..write(obj.coupons)
      ..writeByte(12)
      ..write(obj.score)
      ..writeByte(13)
      ..write(obj.aboutMe)
      ..writeByte(14)
      ..write(obj.avatar)
      ..writeByte(15)
      ..write(obj.avatarBackGround)
      ..writeByte(16)
      ..write(obj.likedPosts)
      ..writeByte(17)
      ..write(obj.likedComments)
      ..writeByte(18)
      ..write(obj.likedProducts)
      ..writeByte(19)
      ..write(obj.expense)
      ..writeByte(20)
      ..write(obj.firstTimeLogin)
      ..writeByte(21)
      ..write(obj.isBankAccountLinked)
      ..writeByte(22)
      ..write(obj.fetchInProgress)
      ..writeByte(23)
      ..write(obj.cupertinoPin)
      ..writeByte(24)
      ..write(obj.cupertinoAttemptCount)
      ..writeByte(25)
      ..write(obj.selectedBank)
      ..writeByte(26)
      ..write(obj.firstFetchedDate)
      ..writeByte(27)
      ..write(obj.friendsList)
      ..writeByte(28)
      ..write(obj.maskedConnections)
      ..writeByte(29)
      ..write(obj.maskedConnected);
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
