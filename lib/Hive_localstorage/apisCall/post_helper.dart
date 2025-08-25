
part of 'post_apis.dart';

class PostObj {

    static PostModels StorePost(PostModel element){
          AuthorModel auth=element.author;
         return PostModels(
          id: element.id,
          author: AuthorModels(id:auth.id, name: auth.name, maskedName: auth.maskedName, avatarType: auth.avatarType, avatarBackGround: auth.avatarBackGround),
          title: element.title,
          place: element.place,
          description: element.description,
          image: element.image,
          isItenary: element.isItenary,
          isPoll: element.isPoll,
          isSquareImage: element.isSquareImage,
          chartType: element.chartType,
          comments: element.comments,
          upvotes: element.upvotes,
          downvotes: element.downvotes,
          path: element.path,
          reportCount: element.reportCount,
          hideCount: element.hideCount,
          tag: element.tag,
          createdAt: element.createdAt,
          updatedAt: element.updatedAt,
          location: element.location,
          rating: element.rating,
          tripHighlights: element.tripHighlights,
          images: element.images,
          pollData: element.postType==PostType.poll?PollMapper.toHive(element.pollData!):null,
          postType: PostTypeMapper.toHive(element.postType),
          budget:  BudgetMapper.toHiveList(element.budget),
        );
    }

    static PostModel getPost(PostModels element){
         AuthorModels auth=element.author;
        return PostModel(
          id: element.id,
          author:  AuthorModel(id:auth.id, name: auth.name, maskedName: auth.maskedName, avatarType: auth.avatarType, avatarBackGround: auth.avatarBackGround),
          title: element.title,
          place: element.place,
          description: element.description,
          image: element.image,
          isItenary: element.isItenary,
          isPoll: element.isPoll,
          isSquareImage: element.isSquareImage,
          chartType: element.chartType,
          comments: element.comments,
          upvotes: element.upvotes,
          downvotes: element.downvotes,
          path: element.path,
          reportCount: element.reportCount,
          hideCount: element.hideCount,
          tag: element.tag,
          createdAt: element.createdAt,
          updatedAt: element.updatedAt,
          location: element.location,
          rating: element.rating,
          tripHighlights: element.tripHighlights,
          images: element.images,
          budget: BudgetMapper.fromHiveList(element.budget),
          postType: PostTypeMapper.toApp(element.postType),
          pollData: element.postType==PostTypes.poll?PollMapper.fromHive(element.pollData!):null,
        );
    }

}

class BudgetMapper {
  /// Convert List<BudgetModel> → List<BudgetModels> (for Hive store)
  static List<BudgetModels> toHiveList(List<BudgetModel> budgets) {
    return budgets
        .map((b) => BudgetModels(
              id: b.id,
              category: b.category,
              amount: b.amount,
            ))
        .toList();
  }

  /// Convert List<BudgetModels> (Hive) → List<BudgetModel>
  static List<BudgetModel> fromHiveList(List<BudgetModels> budgets) {
    return budgets
        .map((b) => BudgetModel(
              id: b.id,
              category: b.category,
              amount: b.amount,
            ))
        .toList();
  }
}

class PostTypeMapper {
  static const _map = {
    PostTypes.exploria: PostType.exploria,
    PostTypes.poll: PostType.poll,
    PostTypes.write: PostType.write,
    PostTypes.image: PostType.image,
    PostTypes.unknown: PostType.unknown,
  };

  /// Hive enum → App enum
  static PostType toApp(PostTypes hiveType) {
    return _map[hiveType] ?? PostType.unknown;
  }

  /// App enum → Hive enum
  static PostTypes toHive(PostType appType) {
    return _map.entries
        .firstWhere(
          (entry) => entry.value == appType,
          orElse: () => const MapEntry(PostTypes.unknown, PostType.unknown),
        )
        .key;
  }
}


class PollMapper {
  /// Convert Hive PollModels → PollModel
  static PollModel fromHive(PollModels hivePoll) {
    return PollModel(
      question: hivePoll.question,
      options: PollOptionMapper.fromHiveList(hivePoll.options),
    );
  }

  /// Convert PollModel → Hive PollModels
  static PollModels toHive(PollModel poll) {
    return PollModels(
      question: poll.question,
      options: PollOptionMapper.toHiveList(poll.options),
    );
  }
}


class PollOptionMapper {
  /// PollOptionModel → PollOptionModels (Hive)
  static List<PollOptionModels> toHiveList(List<PollOptionModel> options) {
    return options
        .map((opt) => PollOptionModels(
              option: opt.option,
              votes: List<String>.from(opt.votes),
            ))
        .toList();
  }

  /// PollOptionModels (Hive) → PollOptionModel
  static List<PollOptionModel> fromHiveList(List<PollOptionModels> options) {
    return options
        .map((opt) => PollOptionModel(
              option: opt.option,
              votes: List<String>.from(opt.votes),
            ))
        .toList();
  }
}
