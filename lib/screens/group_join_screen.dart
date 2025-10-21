import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components.dart';
import '../theme.dart';
import '../services/group_service.dart';
import '../models/group_models.dart';

class GroupJoinScreen extends StatefulWidget {
  const GroupJoinScreen({super.key});

  @override
  State<GroupJoinScreen> createState() => _GroupJoinScreenState();
}

class _GroupJoinScreenState extends State<GroupJoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final GroupService _groupService = GroupService();
  
  bool _isLoading = false;
  Group? _foundGroup;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _searchGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // In a real app, this would search for groups by code
      // For now, we'll simulate finding a group
      await Future.delayed(const Duration(seconds: 1));
      
      // This would be replaced with actual group search logic
      setState(() => _foundGroup = null);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group not found. Please check the code.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
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

  Future<void> _joinGroup(String joinCode) async {
    setState(() => _isLoading = true);

    try {
      final group = await _groupService.joinGroup(joinCode);
      await _groupService.setCurrentGroup(group);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/group');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined "${group.name}"!'),
            backgroundColor: kSuccessColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join group: $e'),
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
        title: const Text('Join Group'),
        backgroundColor: const Color(0xFF121622),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Group Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask your friend for the 6-digit group code',
                  style: TextStyle(color: kTextSubtleColor),
                ),
                const SizedBox(height: 16),
                
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Group Code',
                      hintText: '123456',
                      prefixIcon: Icon(Icons.group),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a group code';
                      }
                      if (value.length != 6) {
                        return 'Group code must be 6 digits';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.length == 6) {
                        _searchGroup();
                      } else {
                        setState(() => _foundGroup = null);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: kAccentColor),
                  )
                else if (_foundGroup != null)
                  _buildGroupPreview(_foundGroup!)
                else
                  GradientButton(
                    label: 'Search Group',
                    icon: Icons.search,
                    onPressed: _searchGroup,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.help_outline, color: kAccentColor),
                    SizedBox(width: 8),
                    Text(
                      'How to Join',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _StepItem(
                  step: '1',
                  title: 'Get the Code',
                  description: 'Ask your friend for the 6-digit group code',
                ),
                const _StepItem(
                  step: '2',
                  title: 'Enter Code',
                  description: 'Type the code in the field above',
                ),
                const _StepItem(
                  step: '3',
                  title: 'Join & Focus',
                  description: 'Start focusing together with your group',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.group, color: kAccentColor),
                    SizedBox(width: 8),
                    Text(
                      'Don\'t have a group?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create your own group and invite friends to join you in focused sessions.',
                  style: TextStyle(color: kTextSubtleColor),
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Create Group',
                  icon: Icons.add,
                  isPrimary: false,
                  onPressed: () => Navigator.pushNamed(context, '/group-create'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupPreview(Group group) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: kRadiusMedium,
        border: Border.all(color: kAccentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kAccentColor.withOpacity(0.2),
                  borderRadius: kRadiusSmall,
                ),
                child: const Icon(Icons.group, color: kAccentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${group.memberCount}/${group.maxMembers} members',
                      style: const TextStyle(color: kTextSubtleColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              group.description,
              style: const TextStyle(color: kTextSubtleColor),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Join Group',
                  icon: Icons.login,
                  onPressed: _isLoading ? null : () => _joinGroup(group.joinCode),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String step;
  final String title;
  final String description;

  const _StepItem({
    required this.step,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: kAccentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
