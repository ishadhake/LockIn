import 'package:flutter/material.dart';
import '../components.dart';
import '../theme.dart';
import '../services/group_service.dart';

class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final GroupService _groupService = GroupService();

  bool _isPrivate = false;
  int _maxMembers = 10;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final group = await _groupService.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isPrivate: _isPrivate,
        maxMembers: _maxMembers,
      );

      await _groupService.setCurrentGroup(group);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/group');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group "${group.name}" created successfully!'),
            backgroundColor: kSuccessColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        backgroundColor: const Color(0xFF121622),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Group Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g., Study Buddies',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a group name';
                      }
                      if (value.trim().length < 3) {
                        return 'Group name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'What is this group for?',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Max Members',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _maxMembers > 2
                                      ? () => setState(() => _maxMembers--)
                                      : null,
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.2),
                                    borderRadius: kRadiusMedium,
                                  ),
                                  child: Text(
                                    '$_maxMembers',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _maxMembers < 20
                                      ? () => setState(() => _maxMembers++)
                                      : null,
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Private Group',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Switch(
                              value: _isPrivate,
                              onChanged: (value) =>
                                  setState(() => _isPrivate = value),
                              activeThumbColor: kAccentColor,
                            ),
                            const Text(
                              'Requires approval to join',
                              style: TextStyle(
                                color: kTextSubtleColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  GradientButton(
                    label: _isLoading ? 'Creating...' : 'Create Group',
                    icon: Icons.group_add,
                    onPressed: _isLoading ? null : _createGroup,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: kAccentColor),
                    SizedBox(width: 8),
                    Text(
                      'Group Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _FeatureItem(
                  icon: Icons.timer,
                  title: 'Synchronized Sessions',
                  description: 'Start focus sessions together',
                ),
                const _FeatureItem(
                  icon: Icons.leaderboard,
                  title: 'Group Leaderboard',
                  description: 'Compete with your friends',
                ),
                const _FeatureItem(
                  icon: Icons.chat,
                  title: 'Motivation & Support',
                  description: 'Encourage each other',
                ),
                const _FeatureItem(
                  icon: Icons.security,
                  title: 'Privacy Controls',
                  description: 'Keep your group private',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kTextSubtleColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: const TextStyle(color: kTextSubtleColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
