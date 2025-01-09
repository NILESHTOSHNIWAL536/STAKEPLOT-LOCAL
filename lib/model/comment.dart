class Comments {
  String? _sId;
  PostDetails? _postDetails;
  Author? _author;
  String? _commentText;
  List<Replies>? _replies;
  int? _upvotes;
  int? _downvotes;

  Comments(
      {String? sId,
      PostDetails? postDetails,
      Author? author,
      String? commentText,
      List<Replies>? replies,
      int? upvotes,
      int? downvotes}) {
    if (sId != null) {
      this._sId = sId;
    }
    if (postDetails != null) {
      this._postDetails = postDetails;
    }
    if (author != null) {
      this._author = author;
    }
    if (commentText != null) {
      this._commentText = commentText;
    }
    if (replies != null) {
      this._replies = replies;
    }
    if (upvotes != null) {
      this._upvotes = upvotes;
    }
    if (downvotes != null) {
      this._downvotes = downvotes;
    }
  }

  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;
  PostDetails? get postDetails => _postDetails;
  set postDetails(PostDetails? postDetails) => _postDetails = postDetails;
  Author? get author => _author;
  set author(Author? author) => _author = author;
  String? get commentText => _commentText;
  set commentText(String? commentText) => _commentText = commentText;
  List<Replies>? get replies => _replies;
  set replies(List<Replies>? replies) => _replies = replies;
  int? get upvotes => _upvotes;
  set upvotes(int? upvotes) => _upvotes = upvotes;
  int? get downvotes => _downvotes;
  set downvotes(int? downvotes) => _downvotes = downvotes;

  Comments.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _postDetails = json['postDetails'] != null
        ? new PostDetails.fromJson(json['postDetails'])
        : null;
    _author =
        json['author'] != null ? new Author.fromJson(json['author']) : null;
    _commentText = json['commentText'];
    if (json['replies'] != null) {
      _replies = <Replies>[];
      json['replies'].forEach((v) {
        _replies!.add(new Replies.fromJson(v));
      });
    }
    _upvotes = json['upvotes'];
    _downvotes = json['downvotes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    if (this._postDetails != null) {
      data['postDetails'] = this._postDetails!.toJson();
    }
    if (this._author != null) {
      data['author'] = this._author!.toJson();
    }
    data['commentText'] = this._commentText;
    if (this._replies != null) {
      data['replies'] = this._replies!.map((v) => v.toJson()).toList();
    }
    data['upvotes'] = this._upvotes;
    data['downvotes'] = this._downvotes;
    return data;
  }
}

class PostDetails {
  String? _id;
  String? _authorId;
  String? _name;

  PostDetails({String? id, String? authorId, String? name}) {
    if (id != null) {
      this._id = id;
    }
    if (authorId != null) {
      this._authorId = authorId;
    }
    if (name != null) {
      this._name = name;
    }
  }

  String? get id => _id;
  set id(String? id) => _id = id;
  String? get authorId => _authorId;
  set authorId(String? authorId) => _authorId = authorId;
  String? get name => _name;
  set name(String? name) => _name = name;

  PostDetails.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _authorId = json['authorId'];
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['authorId'] = this._authorId;
    data['name'] = this._name;
    return data;
  }
}

class Author {
  String? _id;
  String? _name;
  String? _avatar;

  Author({String? id, String? name,String? avatar}) {
    if (id != null) {
      this._id = id;
    }
    if (name != null) {
      this._name = name;
    }
    if (avatar != null) {
      this._avatar = avatar;
    }
  }

  String? get id => _id;
  set id(String? id) => _id = id;

  String? get name => _name;
  set name(String? name) => _name = name;

  String? get avatar => _avatar;
  set avatar(String? avatar) => _avatar = avatar;

  Author.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _avatar= json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['name'] = this._name;
    data['avatar'] = this._avatar;
    return data;
  }
}

class Replies {
  String? _commentId;
  Author? _author;
  String? _replyText;
  String? _sId;
  String? _avatar;

  Replies({String? commentId, Author? author, String? replyText, String? sId,String? avatar}) {
    if (commentId != null) {
      this._commentId = commentId;
    }
    if (author != null) {
      this._author = author;
    }
    if (replyText != null) {
      this._replyText = replyText;
    }
    if (sId != null) {
      this._sId = sId;
    }
    if (avatar != null)
    {
      this._avatar = avatar;
    }
  }

  String? get commentId => _commentId;
  set commentId(String? commentId) => _commentId = commentId;
  Author? get author => _author;
  set author(Author? author) => _author = author;
  String? get replyText => _replyText;
  set replyText(String? replyText) => _replyText = replyText;

  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;

  String? get avatar => _avatar;
  set avatar(String? avatar) => _avatar = avatar;

  Replies.fromJson(Map<String, dynamic> json) {
    _commentId = json['commentId'];
    _author =
        json['author'] != null ? new Author.fromJson(json['author']) : null;
    _replyText = json['replyText'];
    _sId = json['_id'];
    _avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['commentId'] = this._commentId;
    if (this._author != null) {
      data['author'] = this._author!.toJson();
    }
    data['replyText'] = this._replyText;
    data['_id'] = this._sId;
    data['avatar'] = this._avatar;
    return data;
  }
}
