class Contact {
  final int? id;
  final String name;
  final String? phoneNumber;
  final String? photo;
  final int topicId;

  Contact({
    this.id,
    required this.name,
    this.phoneNumber,
    this.photo,
    required this.topicId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contacts_name': name,
      'contacts_phone_number': phoneNumber,
      'contacts_photo': photo,
      'contacts_ref_topic_id': topicId,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id']?.toInt(),
      name: map['contacts_name'] ?? '',
      phoneNumber: map['contacts_phone_number'],
      photo: map['contacts_photo'],
      topicId: map['contacts_ref_topic_id']?.toInt() ?? 0,
    );
  }

  Contact copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? photo,
    int? topicId,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photo: photo ?? this.photo,
      topicId: topicId ?? this.topicId,
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, phoneNumber: $phoneNumber, photo: $photo, topicId: $topicId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          photo == other.photo &&
          topicId == other.topicId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      photo.hashCode ^
      topicId.hashCode;
}