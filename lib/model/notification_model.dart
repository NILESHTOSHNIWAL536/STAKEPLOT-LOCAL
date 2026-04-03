class NotificationAction {
  final String key;
  final String label;

  const NotificationAction({
    required this.key,
    required this.label,
  });

  factory NotificationAction.fromMap(Map<String, dynamic> map) {
    return NotificationAction(
      key: map['key'] as String,
      label: map['label'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'key': key,
        'label': label,
      };
}

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? icon;
  final String time;
  final String dateGroup;
  final Map<String, dynamic> payload;
  final List<NotificationAction> actions;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.icon,
    required this.time,
    required this.dateGroup,
    required this.payload,
    required this.actions,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      icon: map['icon'] as String?,
      time: map['time'] as String,
      dateGroup: map['dateGroup'] as String? ?? 'Others',
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
      actions: (map['actions'] as List? ?? [])
          .map((a) => NotificationAction.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'title': title,
        'message': message,
        'icon': icon,
        'time': time,
        'dateGroup': dateGroup,
        'payload': payload,
        'actions': actions.map((a) => a.toMap()).toList(),
      };
}