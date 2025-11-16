class DiaryItem {
  final int? id;
  final int type;
  final int position;
  final String content;
  final int diaryId;

  DiaryItem({
    this.id,
    required this.type,
    required this.position,
    required this.content,
    required this.diaryId,
  });

  // Item types
  static const int typeText = 0;
  static const int typePhoto = 1;
  static const int typeWebBlock = 2;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'diary_item_type': type,
      'diary_item_position': position,
      'diary_item_content': content,
      'item_ref_diary_id': diaryId,
    };
  }

  factory DiaryItem.fromMap(Map<String, dynamic> map) {
    return DiaryItem(
      id: map['id']?.toInt(),
      type: map['diary_item_type']?.toInt() ?? 0,
      position: map['diary_item_position']?.toInt() ?? 0,
      content: map['diary_item_content'] ?? '',
      diaryId: map['item_ref_diary_id']?.toInt() ?? 0,
    );
  }

  DiaryItem copyWith({
    int? id,
    int? type,
    int? position,
    String? content,
    int? diaryId,
  }) {
    return DiaryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      content: content ?? this.content,
      diaryId: diaryId ?? this.diaryId,
    );
  }

  @override
  String toString() {
    return 'DiaryItem{id: $id, type: $type, position: $position, content: $content, diaryId: $diaryId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          position == other.position &&
          content == other.content &&
          diaryId == other.diaryId;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      position.hashCode ^
      content.hashCode ^
      diaryId.hashCode;
}