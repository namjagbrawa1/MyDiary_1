class Topic {
  final int? id;
  final String name;
  final int type;
  final String? subtitle;
  final int color;
  final int order;
  int count;

  Topic({
    this.id,
    required this.name,
    required this.type,
    this.subtitle,
    required this.color,
    required this.order,
    this.count = 0,
  });

  // Topic types
  static const int typeDiary = 0;
  static const int typeMemo = 1;
  static const int typeContacts = 2;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic_name': name,
      'topic_type': type,
      'topic_subtitle': subtitle,
      'topic_color': color,
      'topic_order': order,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id']?.toInt(),
      name: map['topic_name'] ?? '',
      type: map['topic_type']?.toInt() ?? 0,
      subtitle: map['topic_subtitle'],
      color: map['topic_color']?.toInt() ?? 0,
      order: map['topic_order']?.toInt() ?? 0,
    );
  }

  Topic copyWith({
    int? id,
    String? name,
    int? type,
    String? subtitle,
    int? color,
    int? order,
    int? count,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subtitle: subtitle ?? this.subtitle,
      color: color ?? this.color,
      order: order ?? this.order,
      count: count ?? this.count,
    );
  }

  @override
  String toString() {
    return 'Topic{id: $id, name: $name, type: $type, subtitle: $subtitle, color: $color, order: $order, count: $count}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Topic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          subtitle == other.subtitle &&
          color == other.color &&
          order == other.order;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      subtitle.hashCode ^
      color.hashCode ^
      order.hashCode;
}