class DiaryEntry {
  final int? id;
  final DateTime time;
  final String title;
  final int mood;
  final int weather;
  final String? attachment;
  final int topicId;
  final String? location;

  DiaryEntry({
    this.id,
    required this.time,
    required this.title,
    required this.mood,
    required this.weather,
    this.attachment,
    required this.topicId,
    this.location,
  });

  // Mood types
  static const int moodHappy = 0;
  static const int moodNeutral = 1;
  static const int moodSad = 2;

  // Weather types
  static const int weatherSunny = 0;
  static const int weatherCloudy = 1;
  static const int weatherRainy = 2;
  static const int weatherSnowy = 3;
  static const int weatherFoggy = 4;
  static const int weatherWindy = 5;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'diary_time': time.millisecondsSinceEpoch,
      'diary_title': title,
      'diary_mood': mood,
      'diary_weather': weather,
      'diary_attachment': attachment,
      'diary_ref_topic_id': topicId,
      'diary_location': location,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id']?.toInt(),
      time: DateTime.fromMillisecondsSinceEpoch(map['diary_time']),
      title: map['diary_title'] ?? '',
      mood: map['diary_mood']?.toInt() ?? 0,
      weather: map['diary_weather']?.toInt() ?? 0,
      attachment: map['diary_attachment'],
      topicId: map['diary_ref_topic_id']?.toInt() ?? 0,
      location: map['diary_location'],
    );
  }

  DiaryEntry copyWith({
    int? id,
    DateTime? time,
    String? title,
    int? mood,
    int? weather,
    String? attachment,
    int? topicId,
    String? location,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      time: time ?? this.time,
      title: title ?? this.title,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
      attachment: attachment ?? this.attachment,
      topicId: topicId ?? this.topicId,
      location: location ?? this.location,
    );
  }

  @override
  String toString() {
    return 'DiaryEntry{id: $id, time: $time, title: $title, mood: $mood, weather: $weather, attachment: $attachment, topicId: $topicId, location: $location}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          time == other.time &&
          title == other.title &&
          mood == other.mood &&
          weather == other.weather &&
          attachment == other.attachment &&
          topicId == other.topicId &&
          location == other.location;

  @override
  int get hashCode =>
      id.hashCode ^
      time.hashCode ^
      title.hashCode ^
      mood.hashCode ^
      weather.hashCode ^
      attachment.hashCode ^
      topicId.hashCode ^
      location.hashCode;
}