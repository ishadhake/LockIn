import '../services/group_service.dart';
import '../models/group_models.dart';

class DemoDataService {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  final GroupService _groupService = GroupService();

  Future<void> createDemoData() async {
    try {
      // Create a demo group
      final demoGroup = await _groupService.createGroup(
        name: 'Study Buddies',
        description: 'Let\'s focus together and achieve our goals!',
        isPrivate: false,
        maxMembers: 8,
      );

      // Add some demo members
      final demoMembers = [
        GroupMember(
          id: 'demo_user_1',
          name: 'Alex',
          isOnline: true,
          xp: 250,
          joinedAt: DateTime.now().subtract(const Duration(days: 2)),
          lastActiveAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        GroupMember(
          id: 'demo_user_2',
          name: 'Sarah',
          isOnline: true,
          xp: 180,
          joinedAt: DateTime.now().subtract(const Duration(days: 1)),
          lastActiveAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        GroupMember(
          id: 'demo_user_3',
          name: 'Mike',
          isOnline: false,
          xp: 320,
          joinedAt: DateTime.now().subtract(const Duration(hours: 12)),
          lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      // Update the group with demo members
      for (final member in demoMembers) {
        await _groupService.updateMemberStatus(
          demoGroup.id,
          member.id,
          isOnline: member.isOnline,
          lastActiveAt: member.lastActiveAt,
        );
      }

      print('Demo data created successfully');
    } catch (e) {
      print('Failed to create demo data: $e');
    }
  }

  Future<void> createDemoSession(String groupId) async {
    try {
      await _groupService.startGroupSession(
        groupId: groupId,
        sessionName: 'Morning Study Session',
        duration: const Duration(minutes: 25),
        taskDescription: 'Complete chapter 5 of the textbook',
        lockedApps: const ['Instagram', 'YouTube', 'TikTok'],
      );
      print('Demo session created successfully');
    } catch (e) {
      print('Failed to create demo session: $e');
    }
  }
}
