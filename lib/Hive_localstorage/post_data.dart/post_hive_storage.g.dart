// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_hive_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PollOptionModelAdapter extends TypeAdapter<PollOptionModels> {
  @override
  final int typeId = 12;

  @override
  PollOptionModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PollOptionModels(
      option: fields[0] as String,
      votes: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PollOptionModels obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.option)
      ..writeByte(1)
      ..write(obj.votes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollOptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PollModelAdapter extends TypeAdapter<PollModels> {
  @override
  final int typeId = 13;

  @override
  PollModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PollModels(
      question: fields[0] as String,
      options: (fields[1] as List).cast<PollOptionModels>(),
    );
  }

  @override
  void write(BinaryWriter writer, PollModels obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.options);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AuthorModelAdapter extends TypeAdapter<AuthorModels> {
  @override
  final int typeId = 14;

  @override
  AuthorModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthorModels(
      id: fields[0] as String,
      name: fields[1] as String,
      maskedName: fields[2] as String,
      avatarType: fields[3] as String,
      avatarBackGround: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AuthorModels obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.maskedName)
      ..writeByte(3)
      ..write(obj.avatarType)
      ..writeByte(4)
      ..write(obj.avatarBackGround);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BudgetModelAdapter extends TypeAdapter<BudgetModels> {
  @override
  final int typeId = 15;

  @override
  BudgetModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetModels(
      id: fields[0] as String,
      category: fields[1] as String,
      amount: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModels obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostModelAdapter extends TypeAdapter<PostModels> {
  @override
  final int typeId = 16;

  @override
  PostModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostModels(
      id: fields[0] as String,
      author: fields[1] as AuthorModels,
      title: fields[2] as String,
      place: fields[3] as String,
      description: fields[4] as dynamic,
      image: fields[5] as String,
      postType: fields[6] as PostTypes,
      isItenary: fields[7] as bool,
      isPoll: fields[8] as bool,
      isSquareImage: fields[9] as bool,
      pollData: fields[10] as PollModels?,
      chartType: fields[11] as String,
      comments: fields[12] as int,
      upvotes: fields[13] as int,
      downvotes: fields[14] as int,
      path: fields[15] as String,
      reportCount: fields[16] as int,
      hideCount: fields[17] as int,
      tag: (fields[18] as List).cast<String>(),
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
      location: fields[21] as String,
      budget: (fields[22] as List).cast<BudgetModels>(),
      rating: fields[23] as int,
      tripHighlights: (fields[24] as List).cast<String>(),
      images: (fields[25] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PostModels obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.author)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.place)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.image)
      ..writeByte(6)
      ..write(obj.postType)
      ..writeByte(7)
      ..write(obj.isItenary)
      ..writeByte(8)
      ..write(obj.isPoll)
      ..writeByte(9)
      ..write(obj.isSquareImage)
      ..writeByte(10)
      ..write(obj.pollData)
      ..writeByte(11)
      ..write(obj.chartType)
      ..writeByte(12)
      ..write(obj.comments)
      ..writeByte(13)
      ..write(obj.upvotes)
      ..writeByte(14)
      ..write(obj.downvotes)
      ..writeByte(15)
      ..write(obj.path)
      ..writeByte(16)
      ..write(obj.reportCount)
      ..writeByte(17)
      ..write(obj.hideCount)
      ..writeByte(18)
      ..write(obj.tag)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(21)
      ..write(obj.location)
      ..writeByte(22)
      ..write(obj.budget)
      ..writeByte(23)
      ..write(obj.rating)
      ..writeByte(24)
      ..write(obj.tripHighlights)
      ..writeByte(25)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostTypeAdapter extends TypeAdapter<PostTypes> {
  @override
  final int typeId = 11;

  @override
  PostTypes read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PostTypes.exploria;
      case 1:
        return PostTypes.poll;
      case 2:
        return PostTypes.write;
      case 3:
        return PostTypes.image;
      case 4:
        return PostTypes.unknown;
      default:
        return PostTypes.exploria;
    }
  }

  @override
  void write(BinaryWriter writer, PostTypes obj) {
    switch (obj) {
      case PostTypes.exploria:
        writer.writeByte(0);
        break;
      case PostTypes.poll:
        writer.writeByte(1);
        break;
      case PostTypes.write:
        writer.writeByte(2);
        break;
      case PostTypes.image:
        writer.writeByte(3);
        break;
      case PostTypes.unknown:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
