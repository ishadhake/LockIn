import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/group_models.dart';

class GroupService {
  static const String _groupsKey = 'groups';
  static const String _currentGroupKey = 'current_group';
  static const String _userGroupsKey = 'user_groups';
  
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  final StreamController<List<Group>> _groupsController = StreamController<List<Group>>.broadcast();
  final StreamController<Group?> _currentGroupController = StreamController<Group?>.broadcast();
  final StreamController<GroupSession?> _activeSessionController = StreamController<GroupSession?>.broadcast();

  Stream<List<Group>> get groupsStream => _groupsController.stream;
  Stream<Group?> get currentGroupStream => _currentGroupController.stream;
  Stream<GroupSession?> get activeSessionStream => _activeSessionController.stream;

  List<Group> _groups = [];
  Group? _currentGroup;
  GroupSession? _activeSession;
  String? _currentUserId;

  void initialize(String userId) {
    _currentUserId = userId;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = prefs.getStringList(_groupsKey) ?? [];
    
    _groups = groupsJson
        .map((json) => Group.fromJson(jsonDecode(json)))
        .toList();

    // Load current group
    final currentGroupId = prefs.getString(_currentGroupKey);
    if (currentGroupId != null) {
      _currentGroup = _groups.firstWhere(
        (g) => g.id == currentGroupId,
        orElse: () => throw Exception('Current group not found'),
      );
      _currentGroupController.add(_currentGroup);
    }

    // Load active session
    if (_currentGroup?.activeSession != null) {
      _activeSession = _currentGroup!.activeSession;
      _activeSessionController.add(_activeSession);
    }

    _groupsController.add(_groups);
  }

  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = _groups.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_groupsKey, groupsJson);
    _groupsController.add(_groups);
  }

  Future<Group> createGroup({
    required String name,
    String description = '',
    bool isPrivate = false,
    int maxMembers = 10,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not initialized');
    }

    final joinCode = _generateJoinCode();
    final now = DateTime.now();
    
    final creator = GroupMember(
      id: _currentUserId!,
      name: 'You', // This should come from user profile
      isOnline: true,
      joinedAt: now,
      lastActiveAt: now,
    );

    final group = Group(
      id: _generateGroupId(),
      name: name,
      description: description,
      joinCode: joinCode,
      creatorId: _currentUserId!,
      members: [creator],
      createdAt: now,
      lastActivityAt: now,
      isPrivate: isPrivate,
      maxMembers: maxMembers,
    );

    _groups.add(group);
    await _saveGroups();

    return group;
  }

  Future<Group> joinGroup(String joinCode) async {
    if (_currentUserId == null) {
      throw Exception('User not initialized');
    }

    final group = _groups.firstWhere(
      (g) => g.joinCode == joinCode,
      orElse: () => throw Exception('Group not found'),
    );

    if (!group.canJoin) {
      throw Exception('Group is full');
    }

    if (group.members.any((m) => m.id == _currentUserId)) {
      throw Exception('Already a member of this group');
    }

    final member = GroupMember(
      id: _currentUserId!,
      name: 'You', // This should come from user profile
      isOnline: true,
      joinedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    final updatedMembers = List<GroupMember>.from(group.members)..add(member);
    final updatedGroup = group.copyWith(
      members: updatedMembers,
      lastActivityAt: DateTime.now(),
    );

    final groupIndex = _groups.indexWhere((g) => g.id == group.id);
    _groups[groupIndex] = updatedGroup;
    
    await _saveGroups();
    return updatedGroup;
  }

  Future<void> leaveGroup(String groupId) async {
    if (_currentUserId == null) return;

    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    final updatedMembers = group.members.where((m) => m.id != _currentUserId).toList();
    
    if (updatedMembers.isEmpty) {
      // Delete group if no members left
      _groups.removeWhere((g) => g.id == groupId);
    } else {
      final updatedGroup = group.copyWith(
        members: updatedMembers,
        lastActivityAt: DateTime.now(),
      );
      
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      _groups[groupIndex] = updatedGroup;
    }

    // Clear current group if leaving it
    if (_currentGroup?.id == groupId) {
      await setCurrentGroup(null);
    }

    await _saveGroups();
  }

  Future<void> setCurrentGroup(Group? group) async {
    _currentGroup = group;
    _activeSession = group?.activeSession;
    
    final prefs = await SharedPreferences.getInstance();
    if (group != null) {
      await prefs.setString(_currentGroupKey, group.id);
    } else {
      await prefs.remove(_currentGroupKey);
    }

    _currentGroupController.add(_currentGroup);
    _activeSessionController.add(_activeSession);
  }

  Future<GroupSession> startGroupSession({
    required String groupId,
    required String sessionName,
    required Duration duration,
    String? taskDescription,
    List<String> lockedApps = const [],
  }) async {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    if (group.hasActiveSession) {
      throw Exception('Group already has an active session');
    }

    final session = GroupSession(
      id: _generateSessionId(),
      groupId: groupId,
      name: sessionName,
      duration: duration,
      startTime: DateTime.now(),
      participantIds: group.members.map((m) => m.id).toList(),
      taskDescription: taskDescription,
      lockedApps: lockedApps,
    );

    final updatedGroup = group.copyWith(
      activeSession: session,
      lastActivityAt: DateTime.now(),
    );

    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    _groups[groupIndex] = updatedGroup;

    if (_currentGroup?.id == groupId) {
      _currentGroup = updatedGroup;
      _activeSession = session;
      _currentGroupController.add(_currentGroup);
      _activeSessionController.add(_activeSession);
    }

    await _saveGroups();
    return session;
  }

  Future<void> endGroupSession(String groupId) async {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    if (group.activeSession == null) {
      throw Exception('No active session found');
    }

    final sessionJson = group.activeSession!.toJson();
    sessionJson['endTime'] = DateTime.now().millisecondsSinceEpoch;
    final updatedSession = GroupSession.fromJson(sessionJson);

    final updatedGroup = group.copyWith(
      activeSession: updatedSession,
      lastActivityAt: DateTime.now(),
    );

    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    _groups[groupIndex] = updatedGroup;

    if (_currentGroup?.id == groupId) {
      _currentGroup = updatedGroup;
      _activeSession = null;
      _currentGroupController.add(_currentGroup);
      _activeSessionController.add(_activeSession);
    }

    await _saveGroups();
  }

  Future<void> updateMemberStatus(String groupId, String memberId, {
    bool? isOnline,
    bool? isInSession,
    DateTime? lastActiveAt,
  }) async {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    final memberIndex = group.members.indexWhere((m) => m.id == memberId);
    if (memberIndex == -1) return;

    final member = group.members[memberIndex];
    final updatedMember = member.copyWith(
      isOnline: isOnline,
      isInSession: isInSession,
      lastActiveAt: lastActiveAt,
    );

    final updatedMembers = List<GroupMember>.from(group.members);
    updatedMembers[memberIndex] = updatedMember;

    final updatedGroup = group.copyWith(
      members: updatedMembers,
      lastActivityAt: DateTime.now(),
    );

    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    _groups[groupIndex] = updatedGroup;

    if (_currentGroup?.id == groupId) {
      _currentGroup = updatedGroup;
      _currentGroupController.add(_currentGroup);
    }

    await _saveGroups();
  }

  Future<void> markSessionComplete(String groupId, String memberId) async {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw Exception('Group not found'),
    );

    if (group.activeSession == null) return;

    final session = group.activeSession!;
    final updatedCompletedParticipants = Map<String, bool>.from(session.completedParticipants);
    updatedCompletedParticipants[memberId] = true;

    final sessionJson = session.toJson();
    sessionJson['completedParticipants'] = updatedCompletedParticipants;
    final updatedSession = GroupSession.fromJson(sessionJson);

    final updatedGroup = group.copyWith(activeSession: updatedSession);

    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    _groups[groupIndex] = updatedGroup;

    if (_currentGroup?.id == groupId) {
      _currentGroup = updatedGroup;
      _activeSession = updatedSession;
      _currentGroupController.add(_currentGroup);
      _activeSessionController.add(_activeSession);
    }

    await _saveGroups();
  }

  List<Group> getUserGroups() {
    if (_currentUserId == null) return [];
    return _groups.where((g) => g.members.any((m) => m.id == _currentUserId)).toList();
  }

  Group? getCurrentGroup() => _currentGroup;
  GroupSession? getActiveSession() => _activeSession;

  String _generateJoinCode() {
    return (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
  }

  String _generateGroupId() {
    return 'group_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000)}';
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000)}';
  }

  void dispose() {
    _groupsController.close();
    _currentGroupController.close();
    _activeSessionController.close();
  }
}
