# LockIn Group Features

## Overview
The LockIn app now includes comprehensive group functionality that allows users to create and join focus groups, participate in synchronized focus sessions, and track group progress together.

## Features Implemented

### 1. Group Management
- **Create Groups**: Users can create new focus groups with custom names, descriptions, and member limits
- **Join Groups**: Users can join existing groups using 6-digit join codes
- **Group Settings**: Configurable privacy settings and member limits (2-20 members)
- **Leave Groups**: Users can leave groups they no longer want to participate in

### 2. Real-time Updates
- **Member Status**: Real-time tracking of member online/offline status
- **Session Participation**: Live updates of who is currently in a focus session
- **Session Progress**: Real-time updates of session completion status
- **Group Activity**: Automatic updates when members join/leave or complete sessions

### 3. Synchronized Focus Sessions
- **Group Sessions**: Start focus sessions that all group members can participate in
- **Session Management**: Track session duration, remaining time, and completion status
- **Task Description**: Add descriptions for group focus sessions
- **App Locking**: Configure which apps to lock during group sessions

### 4. Data Storage
- **Persistent Storage**: All group data is stored locally using SharedPreferences
- **Group State**: Maintains current group membership and session state
- **Member Data**: Stores member information, XP, and activity status
- **Session History**: Tracks completed sessions and participant completion

### 5. User Interface
- **Group Dashboard**: Comprehensive view of current group and members
- **Member List**: Visual representation of all group members with status indicators
- **Session Controls**: Easy-to-use interface for starting and managing group sessions
- **Invite System**: Simple code-based invitation system for adding new members

## Technical Implementation

### Architecture
- **Models**: `Group`, `GroupMember`, `GroupSession` data models
- **Services**: `GroupService` for group operations, `RealtimeService` for live updates
- **Storage**: Local persistence using SharedPreferences
- **UI**: Material Design components with custom styling

### Key Components

#### GroupService
- Manages all group operations (create, join, leave, update)
- Handles session management and member status updates
- Provides streams for real-time UI updates
- Implements local data persistence

#### RealtimeService
- Simulates real-time updates for member status and session progress
- Handles automatic session completion and member activity tracking
- Provides demo functionality for testing group features

#### UI Screens
- `GroupLockScreen`: Main group dashboard
- `GroupCreationScreen`: Create new groups
- `GroupJoinScreen`: Join existing groups using codes

### Data Models

#### Group
```dart
class Group {
  final String id;
  final String name;
  final String description;
  final String joinCode;
  final String creatorId;
  final List<GroupMember> members;
  final GroupSession? activeSession;
  final DateTime createdAt;
  final bool isPrivate;
  final int maxMembers;
}
```

#### GroupMember
```dart
class GroupMember {
  final String id;
  final String name;
  final bool isOnline;
  final bool isInSession;
  final int xp;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
}
```

#### GroupSession
```dart
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
}
```

## Usage

### Creating a Group
1. Navigate to Group Focus screen
2. Tap "Create Group"
3. Enter group name and description
4. Set member limit and privacy settings
5. Tap "Create Group"

### Joining a Group
1. Navigate to Group Focus screen
2. Tap "Join Group"
3. Enter the 6-digit group code
4. Tap "Join Group"

### Starting a Group Session
1. Ensure you're in a group
2. Tap "Start Together" on the group dashboard
3. All group members will be notified of the session
4. Session progress is tracked in real-time

### Managing Group Members
- View all members and their status
- See who's online and currently in a session
- Track member XP and activity
- Invite new members using the group code

## Future Enhancements

### Potential Improvements
- **Real Backend Integration**: Replace local storage with cloud database
- **Push Notifications**: Notify members of group events
- **Chat System**: Allow group members to communicate during sessions
- **Advanced Analytics**: Detailed group performance metrics
- **Group Challenges**: Special group-focused challenges and achievements
- **Video Calls**: Integration with video calling for group sessions

### Scalability Considerations
- **Database Design**: Optimize for large groups and frequent updates
- **Caching Strategy**: Implement efficient data caching
- **Offline Support**: Handle offline scenarios gracefully
- **Performance**: Optimize for real-time updates with many members

## Testing

### Demo Data
The app includes demo data functionality for testing:
- Pre-created groups with sample members
- Demo sessions for testing group functionality
- Simulated real-time updates

### Manual Testing
1. Create a new group
2. Join the group from another device/session
3. Start a group session
4. Verify real-time updates work correctly
5. Test leaving and rejoining groups

## Conclusion

The group functionality provides a comprehensive solution for collaborative focus sessions, enabling users to work together towards their productivity goals. The implementation is scalable, user-friendly, and ready for further enhancement with backend integration and additional features.
