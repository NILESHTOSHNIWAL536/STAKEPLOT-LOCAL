class CollectionDraft {
  String? name;
  String? type; // shared / personal
  List<Map<String, dynamic>> members = [];
  Map<String, String> roles = {};
  String? duration;
  String? description;
}

final CollectionDraft collectionDraft = CollectionDraft();
