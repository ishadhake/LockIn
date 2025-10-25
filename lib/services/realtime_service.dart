import 'dart:async';
import 'dart:math';
import '../services/group_service.dart';
import '../models/group_models.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  Timer? _updateTimer;
  final GroupService _groupService = GroupService();
  final Random _random = Random();

  void startRealtimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _simulateRealtimeUpdates();
    });
  }

  void stopRealtimeUpdates() {
    _updateTimer?.cancel();
  }

  void _simulateRealtimeUpdates() {
    final currentGroup = _groupService.getCurrentGroup();
    if (currentGroup == null) return;

    // Simulate member status updates
    _updateMemberStatuses(currentGroup);
    
    // Simulate session progress updates
    _updateSessionProgress(currentGroup);
  }

  void _updateMemberStatuses(Group group) {
    // Simulate random member status changes
    for (final member in group.members) {
      if (_random.nextBool()) {
        // Randomly update online status
        final isOnline = _random.nextBool();
        _groupService.updateMemberStatus(
          group.id,
          member.id,
          isOnline: isOnline,
          lastActiveAt: DateTime.now(),
        );
      }

      // Simulate session participation
      if (group.hasActiveSession && _random.nextDouble() < 0.1) {
        _groupService.updateMemberStatus(
          group.id,
          member.id,
          isInSession: _random.nextBool(),
        );
      }
    }
  }

  void _updateSessionProgress(Group group) {
    if (!group.hasActiveSession) return;

    final session = group.activeSession!;
    
    // Check if session should end
    if (session.remainingTime <= Duration.zero) {
      _groupService.endGroupSession(group.id);
      return;
    }

    // Simulate random completion
    if (_random.nextDouble() < 0.05) {
      final incompleteMembers = session.participantIds
          .where((id) => !session.completedParticipants[id]!)
          .toList();
      
      if (incompleteMembers.isNotEmpty) {
        final randomMember = incompleteMembers[_random.nextInt(incompleteMembers.length)];
        _groupService.markSessionComplete(group.id, randomMember);
      }
    }
  }

  // Simulate member joining/leaving (for demo purposes)
  void simulateMemberJoin(String groupId, String memberName) {
    // This would normally come from a real-time backend
    // For now, we'll just simulate the effect
    final member = GroupMember(
      id: 'member_${DateTime.now().millisecondsSinceEpoch}',
      name: memberName,
      isOnline: true,
      joinedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    // Add to group (this would normally be handled by the backend)
    // For demo purposes, we'll trigger a UI update
    _notifyMemberChange('joined', memberName);
  }

  void simulateMemberLeave(String groupId, String memberName) {
    _notifyMemberChange('left', memberName);
  }

  void _notifyMemberChange(String action, String memberName) {
    // This would trigger a notification or update in the UI
    print('Member $memberName $action the group');
  }

  // Simulate session events
  void simulateSessionStart(String groupId, String sessionName) {
    _notifySessionEvent('started', sessionName);
  }

  void simulateSessionEnd(String groupId, String sessionName) {
    _notifySessionEvent('ended', sessionName);
  }

  void _notifySessionEvent(String action, String sessionName) {
    print('Session "$sessionName" $action');
  }

  void dispose() {
    stopRealtimeUpdates();
  }
}
