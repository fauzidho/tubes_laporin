import 'report_status.dart';

class ReportTimeline {
  final ReportStatus status;
  final String note;
  final DateTime timestamp;

  const ReportTimeline({
    required this.status,
    required this.note,
    required this.timestamp,
  });

  factory ReportTimeline.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate = DateTime.now();
    if (map['timestamp'] != null) {
      if (map['timestamp'] is String) {
        parsedDate = DateTime.parse(map['timestamp']);
      } else if (map['timestamp'] is DateTime) {
        parsedDate = map['timestamp'];
      } else {
        parsedDate = map['timestamp'].toDate();
      }
    }

    return ReportTimeline(
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      note: map['note'] ?? '',
      timestamp: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'note': note,
      'timestamp': timestamp,
    };
  }
}

class ReportComment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const ReportComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory ReportComment.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.parse(val);
      if (val is DateTime) return val;
      return val.toDate();
    }

    return ReportComment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      content: map['content'] ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt,
    };
  }
}

class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final String userNim;
  final String title;
  final ReportCategory category;
  final String location;
  final String description;
  final String? photoPath; // local file path atau URL
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminNotes;
  final List<ReportTimeline> timeline;
  final List<ReportComment> comments;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userNim,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    this.photoPath,
    this.status = ReportStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.adminNotes,
    this.timeline = const [],
    this.comments = const [],
  });

  ReportModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userNim,
    String? title,
    ReportCategory? category,
    String? location,
    String? description,
    String? photoPath,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminNotes,
    List<ReportTimeline>? timeline,
    List<ReportComment>? comments,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userNim: userNim ?? this.userNim,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      timeline: timeline ?? this.timeline,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userNim': userNim,
      'title': title,
      'category': category.name,
      'location': location,
      'description': description,
      'photoPath': photoPath,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'adminNotes': adminNotes,
      'timeline': timeline.map((x) => x.toMap()).toList(),
      'comments': comments.map((x) => x.toMap()).toList(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.parse(val);
      if (val is DateTime) return val;
      return val.toDate(); // Firestore Timestamp handling fallback
    }

    return ReportModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userNim: map['userNim'] ?? '',
      title: map['title'] ?? '',
      category: ReportCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ReportCategory.lainnya,
      ),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      photoPath: map['photoPath'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      adminNotes: map['adminNotes'],
      timeline: (map['timeline'] as List?)
              ?.map<ReportTimeline>((x) => ReportTimeline.fromMap(x as Map<String, dynamic>))
              ?.toList() ??
          <ReportTimeline>[],
      comments: (map['comments'] as List?)
              ?.map<ReportComment>((x) => ReportComment.fromMap(x as Map<String, dynamic>))
              ?.toList() ??
          <ReportComment>[],
    );
  }
}
