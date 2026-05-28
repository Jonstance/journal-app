import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'attachment_ref.dart';

enum EntryType {
  freeform,
  bullets,
  gratitude,
  wins,
}

extension EntryTypeX on EntryType {
  String get label {
    switch (this) {
      case EntryType.freeform:
        return 'Freeform';
      case EntryType.bullets:
        return 'Bullet Notes';
      case EntryType.gratitude:
        return 'Gratitude';
      case EntryType.wins:
        return 'Wins';
    }
  }

  String get description {
    switch (this) {
      case EntryType.freeform:
        return 'Let it flow naturally.';
      case EntryType.bullets:
        return 'Quick capture, point by point.';
      case EntryType.gratitude:
        return 'Small moments worth keeping.';
      case EntryType.wins:
        return 'Celebrate the progress.';
    }
  }
}

class JournalEntry {
  JournalEntry({
    String? id,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.moodColor,
    this.tags = const [],
    this.attachments = const [],
    this.location,
    this.weatherSummary,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final EntryType type;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Color? moodColor;
  final List<String> tags;
  final List<AttachmentRef> attachments;
  final String? location;
  final String? weatherSummary;

  JournalEntry copyWith({
    EntryType? type,
    String? content,
    DateTime? updatedAt,
    Color? moodColor,
    List<String>? tags,
    List<AttachmentRef>? attachments,
    String? location,
    String? weatherSummary,
  }) {
    return JournalEntry(
      id: id,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moodColor: moodColor ?? this.moodColor,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      location: location ?? this.location,
      weatherSummary: weatherSummary ?? this.weatherSummary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'moodColor': moodColor?.toARGB32(),
      'tags': tags,
      'attachments': attachments.map((attachment) => attachment.toMap()).toList(),
      'location': location,
      'weatherSummary': weatherSummary,
    };
  }

  static JournalEntry fromMap(Map<dynamic, dynamic> map) {
    final rawAttachments = map['attachments'] as List? ?? const [];
    final attachments = rawAttachments.map((item) {
      if (item is Map) return AttachmentRef.fromMap(item);
      if (item is String) {
        return AttachmentRef(path: item, type: AttachmentType.photo);
      }
      return null;
    }).whereType<AttachmentRef>().toList();

    return JournalEntry(
      id: map['id'] as String?,
      type: EntryType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => EntryType.freeform,
      ),
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      moodColor: map['moodColor'] != null ? Color(map['moodColor'] as int) : null,
      tags: List<String>.from(map['tags'] as List? ?? const []),
      attachments: attachments,
      location: map['location'] as String?,
      weatherSummary: map['weatherSummary'] as String?,
    );
  }
}
