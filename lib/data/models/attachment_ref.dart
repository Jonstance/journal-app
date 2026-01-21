import 'package:uuid/uuid.dart';

enum AttachmentType { photo, audio, handwriting }

class AttachmentRef {
  AttachmentRef({
    String? id,
    required this.path,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String path;
  final AttachmentType type;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'type': type.name,
    };
  }

  static AttachmentRef fromMap(Map<dynamic, dynamic> map) {
    return AttachmentRef(
      id: map['id'] as String?,
      path: map['path'] as String? ?? '',
      type: AttachmentType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => AttachmentType.photo,
      ),
    );
  }
}
