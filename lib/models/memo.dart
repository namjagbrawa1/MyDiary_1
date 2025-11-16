class Memo {
  final int? id;
  final int order;
  final String content;
  final bool checked;
  final int topicId;

  Memo({
    this.id,
    required this.order,
    required this.content,
    required this.checked,
    required this.topicId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memo_order': order,
      'memo_content': content,
      'memo_checked': checked ? 1 : 0,
      'memo_ref_topic_id': topicId,
    };
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id']?.toInt(),
      order: map['memo_order']?.toInt() ?? 0,
      content: map['memo_content'] ?? '',
      checked: (map['memo_checked']?.toInt() ?? 0) == 1,
      topicId: map['memo_ref_topic_id']?.toInt() ?? 0,
    );
  }

  Memo copyWith({
    int? id,
    int? order,
    String? content,
    bool? checked,
    int? topicId,
  }) {
    return Memo(
      id: id ?? this.id,
      order: order ?? this.order,
      content: content ?? this.content,
      checked: checked ?? this.checked,
      topicId: topicId ?? this.topicId,
    );
  }

  @override
  String toString() {
    return 'Memo{id: $id, order: $order, content: $content, checked: $checked, topicId: $topicId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Memo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          order == other.order &&
          content == other.content &&
          checked == other.checked &&
          topicId == other.topicId;

  @override
  int get hashCode =>
      id.hashCode ^
      order.hashCode ^
      content.hashCode ^
      checked.hashCode ^
      topicId.hashCode;
}