
class GroupMember {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;
  final bool isInSession;
  final int xp;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;

  GroupMember({
    required this.id,
    required this.name,
    this.avatar = '',
    this.isOnline = false,
    this.isInSession = false,
    this.xp = 0,
    required this.joinedAt,
    this.lastActiveAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'isOnline': isOnline,
      'isInSession': isInSession,
      'xp': xp,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'lastActiveAt': lastActiveAt?.millisecondsSinceEpoch,
    };
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isInSession: json['isInSession'] ?? false,
      xp: json['xp'] ?? 0,
      joinedAt: DateTime.fromMillisecondsSinceEpoch(json['joinedAt'] ?? 0),
      lastActiveAt: json['lastActiveAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastActiveAt'])
          : null,
    );
  }

  GroupMember copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isOnline,
    bool? isInSession,
    int? xp,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
  }) {
    return GroupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      isInSession: isInSession ?? this.isInSession,
      xp: xp ?? this.xp,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

class GroupSession {
  final String id;
  final String groupId;
  final String name;
  final Duration duration;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> participantIds;
  final Map<String, bool> completedParticipants;
  final String? taskDescription;
  final List<String> lockedApps;

  GroupSession({
    required this.id,
    required this.groupId,
    required this.name,
    required this.duration,
    required this.startTime,
    this.endTime,
    this.participantIds = const [],
    this.completedParticipants = const {},
    this.taskDescription,
    this.lockedApps = const [],
  });

  bool get isActive => endTime == null;
  Duration get remainingTime {
    if (endTime != null) return Duration.zero;
    final elapsed = DateTime.now().difference(startTime);
    return duration - elapsed;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'duration': duration.inMilliseconds,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'participantIds': participantIds,
      'completedParticipants': completedParticipants,
      'taskDescription': taskDescription,
      'lockedApps': lockedApps,
    };
  }

  factory GroupSession.fromJson(Map<String, dynamic> json) {
    return GroupSession(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      name: json['name'] ?? '',
      duration: Duration(milliseconds: json['duration'] ?? 0),
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] ?? 0),
      endTime: json['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'])
          : null,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      completedParticipants: Map<String, bool>.from(json['completedParticipants'] ?? {}),
      taskDescription: json['taskDescription'],
      lockedApps: List<String>.from(json['lockedApps'] ?? []),
    );
  }
}

class Group {
  final String id;
  final String name;
  final String description;
  final String joinCode;
  final String creatorId;
  final List<GroupMember> members;
  final GroupSession? activeSession;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final bool isPrivate;
  final int maxMembers;

  Group({
    required this.id,
    required this.name,
    this.description = '',
    required this.joinCode,
    required this.creatorId,
    this.members = const [],
    this.activeSession,
    required this.createdAt,
    this.lastActivityAt,
    this.isPrivate = false,
    this.maxMembers = 10,
  });

  bool get hasActiveSession => activeSession != null && activeSession!.isActive;
  int get memberCount => members.length;
  bool get canJoin => memberCount < maxMembers;
  bool get isEmpty => memberCount == 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'joinCode': joinCode,
      'creatorId': creatorId,
      'members': members.map((m) => m.toJson()).toList(),
      'activeSession': activeSession?.toJson(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActivityAt': lastActivityAt?.millisecondsSinceEpoch,
      'isPrivate': isPrivate,
      'maxMembers': maxMembers,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      joinCode: json['joinCode'] ?? '',
      creatorId: json['creatorId'] ?? '',
      members: (json['members'] as List<dynamic>?)
          ?.map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
      activeSession: json['activeSession'] != null 
          ? GroupSession.fromJson(json['activeSession'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      lastActivityAt: json['lastActivityAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastActivityAt'])
          : null,
      isPrivate: json['isPrivate'] ?? false,
      maxMembers: json['maxMembers'] ?? 10,
    );
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? joinCode,
    String? creatorId,
    List<GroupMember>? members,
    GroupSession? activeSession,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    bool? isPrivate,
    int? maxMembers,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      joinCode: joinCode ?? this.joinCode,
      creatorId: creatorId ?? this.creatorId,
      members: members ?? this.members,
      activeSession: activeSession ?? this.activeSession,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      isPrivate: isPrivate ?? this.isPrivate,
      maxMembers: maxMembers ?? this.maxMembers,
    );
  }
}
