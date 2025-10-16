import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components.dart';
import 'theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Placeholders with structure for 10 screens. Fill in progressively.

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // particle accents
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ParticlePainter())
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    duration: const Duration(seconds: 3),
                    colors: const [
                      Color(0x113BA3FF),
                      Color(0x333BA3FF),
                      Color(0x117B61FF),
                    ],
                  ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: kSurfaceColor),
            width: double.infinity,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentColor.withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ).animate().scale(
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lock distractions. Unlock focus.',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: kTextSubtleColor),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(
                        label: 'Get Started',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => Navigator.pushNamed(context, '/auth'),
                      ),
                      const SizedBox(width: 16),
                      GradientButton(
                        label: 'Login',
                        isPrimary: false,
                        onPressed: () => Navigator.pushNamed(context, '/auth'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: GestureDetector(
                      onTap: () => showForgotPasswordDialog(context),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: kTextSubtleColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'Login',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/user-type'),
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Register',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/user-type'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose User Type')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/dashboard'),
                child: SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.person, size: 48),
                      SizedBox(height: 8),
                      Text('Individual'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  '/parent-dashboard',
                ),
                child: SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.family_restroom, size: 48),
                      SizedBox(height: 8),
                      Text('Parent'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isChildDevice = false;
  bool _isLocked = false;
  List<String> _lockedApps = [];

  @override
  void initState() {
    super.initState();
    _checkChildStatus();
  }

  Future<void> _checkChildStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChildDevice = prefs.getBool('isChildDevice') ?? false;
      _isLocked = prefs.getBool('isLocked') ?? false;
      _lockedApps = prefs.getStringList('lockedApps') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('LockIn'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isChildDevice && _isLocked) ...[
            SoftCard(
              child: Column(
                children: [
                  const Icon(Icons.lock, color: kAccentColor, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'Parent Lock Active',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Locked Apps: ${_lockedApps.join(', ')}',
                    style: const TextStyle(color: kTextSubtleColor),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: 'Emergency Unlock',
                    icon: Icons.lock_open,
                    onPressed: _showEmergencyUnlock,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (!_isChildDevice) ...[
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Join Parent Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter parent code to connect your device',
                    style: TextStyle(color: kTextSubtleColor),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: 'Join as Child',
                    icon: Icons.child_care,
                    onPressed: () =>
                        Navigator.pushNamed(context, '/join-child'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SoftCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Stay focused ✨',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '“Lock distractions. Unlock focus.”',
                        style: TextStyle(color: kTextSubtleColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GradientButton(
                  label: 'Start Focus',
                  icon: Icons.play_arrow,
                  onPressed: () => Navigator.pushNamed(context, '/focus'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Active Session'),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: Center(
                        child: FocusProgressRing(
                          progress: 0.35,
                          centerLabel: '15:23',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'XP: 120',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Streak: 3 days',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Total: 12h',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    GradientButton(
                      label: 'Achievements',
                      isPrimary: false,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/achievements'),
                    ),
                    GradientButton(
                      label: 'Join Group',
                      isPrimary: false,
                      onPressed: () => Navigator.pushNamed(context, '/group'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _RecentSessionsStrip(),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Focus Task'),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'Write Task & Select Apps',
                  icon: Icons.add_task,
                  onPressed: () => Navigator.pushNamed(context, '/task-create'),
                ),
                const SizedBox(height: 16),
                const Text('Select apps to lock'),
                const SizedBox(height: 8),
                const _AppLockChips(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    final emergencyPin = prefs.getString('emergencyPin') ?? '';

    if (emergencyPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No emergency PIN set. Contact parent.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xCC1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: kRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Emergency Unlock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter emergency PIN provided by parent',
                style: TextStyle(color: kTextSubtleColor),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Emergency PIN'),
                onSubmitted: (pin) async {
                  if (pin == emergencyPin) {
                    await prefs.setBool('isLocked', false);
                    await prefs.remove('lockedApps');
                    setState(() {
                      _isLocked = false;
                      _lockedApps.clear();
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Device unlocked!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid PIN')),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: 'Unlock',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FocusLockScreen extends StatefulWidget {
  const FocusLockScreen({super.key});
  @override
  State<FocusLockScreen> createState() => _FocusLockScreenState();
}

class _FocusLockScreenState extends State<FocusLockScreen> {
  // Pomodoro settings
  static const Duration _focusBlock = Duration(minutes: 25);
  static const Duration _breakBlock = Duration(minutes: 5);
  static const int _maxBreaks =
      3; // standard Pomodoro: 4 focus blocks, 3 breaks

  Duration _total = _focusBlock;
  Duration _remaining = _focusBlock;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;
  int _completedFocusBlocks = 0; // completed focus blocks
  int _breaksTaken = 0; // short breaks taken
  bool _isInBreak = false;
  bool _isChildDevice =
      false; // used to decide Emergency Unlock visibility (hidden in Individual mode)

  // AI Coach reminder cadence bookkeeping
  final Set<int> _reminderSecondsShown = <int>{};

  double get _progress =>
      1 - (_remaining.inSeconds / _total.inSeconds).clamp(0.0, 1.0);
  String get _label {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void initState() {
    super.initState();
    _loadDeviceMode();
  }

  Future<void> _loadDeviceMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChildDevice = prefs.getBool('isChildDevice') ?? false;
    });
  }

  void _startSession() {
    if (_isFinished) return;
    _timer?.cancel();
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining.inSeconds <= 0) {
        // Transition between phases
        if (_isInBreak) {
          // Break ended → start next focus block
          setState(() {
            _isInBreak = false;
            _total = _focusBlock;
            _remaining = _focusBlock;
          });
          _coachNotify("Break over. Let's get back to focus ✨");
        } else {
          // Focus block ended
          _completedFocusBlocks += 1;
          if (_breaksTaken < _maxBreaks) {
            // Start a short break automatically
            setState(() {
              _isInBreak = true;
              _breaksTaken += 1;
              _total = _breakBlock;
              _remaining = _breakBlock;
            });
            _coachNotify("Great job! Take a short 5-minute break.");
          } else {
            // Session complete after last focus block
            t.cancel();
            setState(() {
              _isRunning = false;
              _isFinished = true;
              _remaining = Duration.zero;
            });
            _showCompletedDialogWithTips();
          }
        }
      } else {
        setState(
          () => _remaining = Duration(seconds: _remaining.inSeconds - 1),
        );
        _maybeCoachReminder();
      }
    });
    _coachNotify(
      _isInBreak
          ? 'Break started. Breathe and relax.'
          : 'Focus started. One small step now.',
    );
  }

  void _maybeCoachReminder() {
    // Show subtle reminders at certain remaining times (per phase)
    final sec = _remaining.inSeconds;
    // trigger at phase mid-point and near end; ensure once per phase-second
    final triggerPoints = <int>{(_total.inSeconds * 0.5).round(), 60};
    if (triggerPoints.contains(sec) && !_reminderSecondsShown.contains(sec)) {
      _reminderSecondsShown.add(sec);
      if (_isInBreak) {
        _coachNotify('Break almost over. Prepare your next step.');
      } else {
        _coachNotify('Stay with it. Write one line or solve one sub-step.');
      }
    }
    if (sec == _total.inSeconds - 1) {
      // reset per-phase markers at phase start
      _reminderSecondsShown.clear();
    }
  }

  void _showCompletedDialogWithTips() {
    final tips = [
      'Note 1 insight you gained this session.',
      'List the next 3 actions for tomorrow.',
      'Close unused tabs and silence 1 notification source.',
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF262626),
        title: const Text(
          'Session Complete',
          style: TextStyle(color: kSuccessColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Great work! +20 XP earned.'),
            const SizedBox(height: 12),
            const Text(
              'AI Coach Tips',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final t in tips)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16, color: kSuccessColor),
                    const SizedBox(width: 6),
                    Expanded(child: Text(t)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _coachNotify(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _childEmergencyUnlock() async {
    if (!_isChildDevice) return;
    final prefs = await SharedPreferences.getInstance();
    final emergencyPin = prefs.getString('emergencyPin') ?? '';
    if (emergencyPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No emergency PIN set by parent.')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xCC1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: kRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Emergency Unlock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter parent PIN to unlock',
                style: TextStyle(color: kTextSubtleColor),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Parent PIN'),
                onSubmitted: (pin) async {
                  if (pin == emergencyPin) {
                    await prefs.setBool('isLocked', false);
                    await prefs.remove('lockedApps');
                    if (mounted) Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unlocked by parent PIN.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid PIN')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final taskName = (args?['task'] as String?)?.trim();
    final lockedApps = (args?['apps'] as List?)?.cast<String>() ?? const [];
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: FocusProgressRing(progress: _progress, centerLabel: _label),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurfaceColor.withOpacity(0.6),
                borderRadius: kRadiusLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (taskName != null && taskName.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.flag_rounded,
                          size: 18,
                          color: kTextSubtleColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            taskName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (lockedApps.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Locked: ${lockedApps.join(', ')}',
                          style: const TextStyle(color: kTextSubtleColor),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 18,
                          color: kTextSubtleColor,
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Focus Session',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isFinished
                              ? 'Session Finished'
                              : _isRunning
                              ? (_isInBreak ? 'On Break' : 'Focusing')
                              : 'Ready',
                          style: const TextStyle(color: kTextSubtleColor),
                        ),
                      ),
                      if (!_isRunning && !_isFinished)
                        GradientButton(
                          label: 'Start Session',
                          icon: Icons.play_arrow,
                          onPressed: _startSession,
                        ),
                      if (_isFinished)
                        GradientButton(
                          label: 'End Session',
                          icon: Icons.check,
                          onPressed: () => Navigator.pop(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isChildDevice)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GradientButton(
                        label: 'Emergency Unlock',
                        isPrimary: false,
                        icon: Icons.lock_open,
                        onPressed: _childEmergencyUnlock,
                      ),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    'Focus Tools:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kTextSubtleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: 'AI Coach',
                          isPrimary: false,
                          icon: Icons.psychology,
                          onPressed: () => _openCoach(context, taskName),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GradientButton(
                          label: 'Motivate',
                          isPrimary: false,
                          icon: Icons.bolt,
                          onPressed: () => _showMotivation(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCoach(BuildContext context, String? task) {
    final tips = <String>[
      'Break it into 3 small steps. Do step 1 now.',
      'Silence one notification source for this session.',
      'Write a one-sentence goal for this block.',
      'Stand, stretch 10 seconds, then resume.',
      'Close the biggest distraction app you use most.',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171B25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: kAccentColor),
                const SizedBox(width: 8),
                const Text(
                  'AI Coach',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            if (task != null && task.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Task: $task',
                style: const TextStyle(color: kTextSubtleColor),
              ),
            ],
            const SizedBox(height: 12),
            ...tips.map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: kSuccessColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GradientButton(
                label: 'Got it',
                onPressed: () => Navigator.pop(context),
                isPrimary: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMotivation(BuildContext context) {
    const quotes = [
      'Small progress is still progress.',
      'Focus on the next minute.',
      'Your future self will thank you.',
      'Deep work beats scattered effort.',
    ];
    final q = quotes[DateTime.now().second % quotes.length];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(q)));
  }
}

// Custom duration dialog removed per spec: no manual duration selection in Individual mode

class GroupLockScreen extends StatefulWidget {
  const GroupLockScreen({super.key});
  @override
  State<GroupLockScreen> createState() => _GroupLockScreenState();
}

class _GroupLockScreenState extends State<GroupLockScreen> {
  static const Duration _focusBlock = Duration(minutes: 25);
  static const Duration _breakBlock = Duration(minutes: 5);

  bool _isLeader = false;
  String? _groupCode; // simple link/code simulation
  final TextEditingController _joinController = TextEditingController();

  Duration _total = _focusBlock;
  Duration _remaining = _focusBlock;
  bool _isRunning = false;
  bool _isInBreak = false;
  Timer? _timer;

  final List<_GroupMember> _members = [];
  final List<String> _coachFeed = [];

  @override
  void dispose() {
    _timer?.cancel();
    _joinController.dispose();
    super.dispose();
  }

  String get _label {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _createGroup() {
    setState(() {
      _isLeader = true;
      _groupCode = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
          .toString();
      _members.clear();
      _members.addAll([
        _GroupMember(
          name: 'You (Leader)',
          isSelf: true,
          status: _MemberStatus.idle,
        ),
      ]);
      _coach('Group created. Share the link to invite members.');
    });
  }

  void _joinGroup() {
    if (_joinController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a session link/code')),
      );
      return;
    }
    setState(() {
      _isLeader = false;
      _groupCode = _joinController.text.trim();
      _members.clear();
      _members.addAll([
        _GroupMember(name: 'Leader', isSelf: false, status: _MemberStatus.idle),
        _GroupMember(name: 'You', isSelf: true, status: _MemberStatus.idle),
      ]);
      _coach('Joined group. Waiting for leader to start.');
    });
  }

  void _startForAll() {
    if (!_isLeader) return;
    _timer?.cancel();
    setState(() {
      _isRunning = true;
      _isInBreak = false;
      _total = _focusBlock;
      _remaining = _focusBlock;
      for (final m in _members) {
        m.status = _MemberStatus.focusing;
      }
    });
    _coach('Focus started for everyone.');
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining.inSeconds <= 0) {
        // toggle between focus and break, leader-controlled
        setState(() {
          _isInBreak = !_isInBreak;
          _total = _isInBreak ? _breakBlock : _focusBlock;
          _remaining = _total;
          for (final m in _members) {
            if (_isInBreak) {
              m.status = _MemberStatus.onBreak;
            } else {
              // pending requests remain pending; others focus
              if (m.status != _MemberStatus.pendingBreak) {
                m.status = _MemberStatus.focusing;
              }
            }
          }
        });
        _coach(
          _isInBreak
              ? 'Short break. Breathe and reset.'
              : 'Back to focus. One small step.',
        );
      } else {
        setState(
          () => _remaining = Duration(seconds: _remaining.inSeconds - 1),
        );
        if (_remaining.inSeconds == (_total.inSeconds / 2).round()) {
          _coach(
            _isInBreak
                ? 'Break halfway. Prepare your next action.'
                : 'Halfway there. Stay with it.',
          );
        }
      }
    });
  }

  void _endForAll() {
    if (!_isLeader) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isInBreak = false;
      _remaining = Duration.zero;
      for (final m in _members) {
        m.status = _MemberStatus.idle;
      }
    });
    _coach('Session ended by leader. Great work team!');
  }

  void _requestBreak() {
    // member requests break → status pendingBreak
    final me = _members.firstWhere(
      (m) => m.isSelf,
      orElse: () => _GroupMember(name: 'You', isSelf: true),
    );
    if (me.status == _MemberStatus.pendingBreak) return;
    setState(() => me.status = _MemberStatus.pendingBreak);
    _coach('Break request sent to leader.');
  }

  void _approveBreak(_GroupMember m) {
    if (!_isLeader) return;
    setState(() => m.status = _MemberStatus.onBreak);
    _coach('Leader approved a break for ${m.name}.');
  }

  void _denyBreak(_GroupMember m) {
    if (!_isLeader) return;
    setState(() => m.status = _MemberStatus.focusing);
    _coach('Leader denied break for ${m.name}. Stay focused.');
  }

  void _giveManualBreak(_GroupMember m) {
    if (!_isLeader) return;
    setState(() => m.status = _MemberStatus.onBreak);
    _coach('Leader granted a manual break to ${m.name}.');
  }

  void _coach(String msg) {
    setState(() {
      _coachFeed.insert(0, msg);
      if (_coachFeed.length > 6) _coachFeed.removeLast();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Focus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_groupCode == null) ...[
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: 'Create Group',
                    icon: Icons.group_add,
                    onPressed: _createGroup,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Join via Link',
                    icon: Icons.link,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => Dialog(
                          backgroundColor: const Color(0xCC1E1E1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: kRadiusLarge,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Join Group Session',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _joinController,
                                  decoration: const InputDecoration(
                                    labelText: 'Paste link or code',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GradientButton(
                                  label: 'Join',
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _joinGroup();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link, color: kAccentColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Session Link/Code: $_groupCode')),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isInBreak
                              ? kAccentColor.withOpacity(0.2)
                              : kPrimaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isInBreak
                              ? 'BREAK'
                              : (_isRunning ? 'FOCUS' : 'IDLE'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: FocusProgressRing(
                      progress: _total.inSeconds == 0
                          ? 0
                          : 1 - (_remaining.inSeconds / _total.inSeconds),
                      centerLabel: _label,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLeader)
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: _isRunning ? 'End Session' : 'Start Session',
                            icon: _isRunning ? Icons.stop : Icons.play_arrow,
                            onPressed: _isRunning ? _endForAll : _startForAll,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Request Break',
                            isPrimary: false,
                            icon: Icons.free_breakfast,
                            onPressed: _requestBreak,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Members',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ..._members.map(
                    (m) => ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          m.isSelf ? Icons.person : Icons.person_outline,
                        ),
                      ),
                      title: Text(m.name),
                      subtitle: Text(_statusLabel(m.status)),
                      trailing: _isLeader ? _leaderActionsFor(m) : null,
                    ),
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
                    children: [
                      const Icon(Icons.psychology, color: kAccentColor),
                      const SizedBox(width: 8),
                      const Text('AI Coach'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_coachFeed.isEmpty)
                    const Text('Motivational tips will appear here...')
                  else
                    ..._coachFeed.map(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('• $m'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(_MemberStatus s) {
    switch (s) {
      case _MemberStatus.idle:
        return 'Idle';
      case _MemberStatus.focusing:
        return 'Focusing';
      case _MemberStatus.pendingBreak:
        return 'Break requested';
      case _MemberStatus.onBreak:
        return 'On break';
    }
  }

  Widget _leaderActionsFor(_GroupMember m) {
    if (m.isSelf) return const SizedBox.shrink();
    if (m.status == _MemberStatus.pendingBreak) {
      return Wrap(
        spacing: 8,
        children: [
          GradientButton(
            label: 'Approve',
            isPrimary: false,
            onPressed: () => _approveBreak(m),
          ),
          GradientButton(
            label: 'Deny',
            isPrimary: false,
            onPressed: () => _denyBreak(m),
          ),
        ],
      );
    }
    return GradientButton(
      label: 'Give Break',
      isPrimary: false,
      onPressed: () => _giveManualBreak(m),
    );
  }
}

enum _MemberStatus { idle, focusing, pendingBreak, onBreak }

class _GroupMember {
  String name;
  bool isSelf;
  _MemberStatus status;
  _GroupMember({
    required this.name,
    this.isSelf = false,
    this.status = _MemberStatus.idle,
  });
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: 6,
        itemBuilder: (_, i) => SoftCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: kAccentColor, size: 40),
              const SizedBox(height: 8),
              Text(
                'Streak Badge',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text('+50 XP', style: TextStyle(color: kSuccessColor)),
              const SizedBox(height: 12),
              GradientButton(
                label: 'Upload Photo',
                isPrimary: false,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Streaks & Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: TableCalendar(
              firstDay: DateTime(now.year - 1, 1, 1),
              lastDay: DateTime(now.year + 1, 12, 31),
              focusedDay: now,
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: kTextColor),
                weekendTextStyle: TextStyle(color: kTextColor),
                todayDecoration: BoxDecoration(
                  color: kAccentColor,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: kPrimaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              selectedDayPredicate: (d) => false,
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final i = v.toInt();
                            return Text(
                              i >= 0 && i < labels.length ? labels[i] : '',
                              style: const TextStyle(color: kTextSubtleColor),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: kAccentColor,
                        barWidth: 4,
                        dotData: const FlDotData(show: false),
                        spots: const [
                          FlSpot(0, 2),
                          FlSpot(1, 3),
                          FlSpot(2, 1),
                          FlSpot(3, 4),
                          FlSpot(4, 5),
                          FlSpot(5, 3),
                          FlSpot(6, 4),
                        ],
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              kAccentColor.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Global'),
              Tab(text: 'Group'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LeaderboardList(title: 'Global'),
            _LeaderboardList(title: 'Group'),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: const Center(
        child: Text('Profile card, preferences, accessibility'),
      ),
    );
  }
}

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});
  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final List<Map<String, dynamic>> _childDevices = [];
  final _pinController = TextEditingController();
  String _linkCode = '123456';

  @override
  void initState() {
    super.initState();
    _loadChildDevices();
  }

  Future<void> _loadChildDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devicesJson = prefs.getStringList('childDevices') ?? [];
    setState(() {
      _childDevices.clear();
      for (final deviceJson in devicesJson) {
        final deviceData = prefs.getString(deviceJson);
        if (deviceData != null) {
          try {
            _childDevices.add(
              Map<String, dynamic>.from({
                'id': deviceJson,
                'name': 'Child Device ${_childDevices.length + 1}',
                'lockedApps': <String>[],
                'isLocked': false,
              }),
            );
          } catch (e) {
            // Handle parsing error
          }
        }
      }
    });
  }

  Future<void> _saveChildDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceIds = <String>[];
    for (final device in _childDevices) {
      final id = device['id'] as String;
      deviceIds.add(id);
      await prefs.setString(id, device.toString());
    }
    await prefs.setStringList('childDevices', deviceIds);
  }

  void _addChildDevice() {
    final List<String> availableApps = [
      'Instagram',
      'YouTube',
      'TikTok',
      'Twitter',
      'Facebook',
      'Snapchat',
      'Discord',
      'Games',
    ];
    List<String> selectedApps = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => Dialog(
          backgroundColor: const Color(0xCC1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: kRadiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Child Device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Share this code with your child:',
                  style: TextStyle(color: kTextSubtleColor),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    borderRadius: kRadiusMedium,
                  ),
                  child: Text(
                    _linkCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select apps to lock:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableApps.map((app) {
                    return FilterChip(
                      label: Text(app),
                      selected: selectedApps.contains(app),
                      onSelected: (val) {
                        setStateDialog(() {
                          if (val) {
                            selectedApps.add(app);
                          } else {
                            selectedApps.remove(app);
                          }
                        });
                      },
                      selectedColor: Colors.deepPurple.shade200,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Generate New Code',
                  onPressed: () {
                    setState(
                      () => _linkCode =
                          (100000 +
                                  DateTime.now().millisecondsSinceEpoch %
                                      900000)
                              .toString(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: selectedApps.isEmpty
                          ? null
                          : () async {
                              // Save the child device with selected apps
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final deviceId = _linkCode;
                              // Save selection and locked state
                              final deviceData = {
                                'id': deviceId,
                                'lockedApps': selectedApps,
                                'isLocked': false,
                              };
                              await prefs.setString(
                                deviceId,
                                deviceData.toString(),
                              );

                              // Add to childDevices list
                              final childDevices =
                                  prefs.getStringList('childDevices') ?? [];
                              if (!childDevices.contains(deviceId)) {
                                childDevices.add(deviceId);
                                await prefs.setStringList(
                                  'childDevices',
                                  childDevices,
                                );
                              }
                              setState(() {
                                _childDevices.add(deviceData);
                                _linkCode =
                                    (100000 +
                                            DateTime.now()
                                                    .millisecondsSinceEpoch %
                                                900000)
                                        .toString();
                              });
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Child added with locked apps'),
                                ),
                              );
                            },
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _manageChildDevice(Map<String, dynamic> device) {
    Navigator.pushNamed(context, '/child-management', arguments: device);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.family_restroom, color: kAccentColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Child Devices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    GradientButton(
                      label: 'Add Child',
                      icon: Icons.add,
                      onPressed: _addChildDevice,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_childDevices.isEmpty)
                  const Center(
                    child: Text(
                      'No child devices added yet',
                      style: TextStyle(color: kTextSubtleColor),
                    ),
                  )
                else
                  ..._childDevices.map(
                    (device) => ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.child_care),
                      ),
                      title: Text(device['name'] ?? 'Child Device'),
                      subtitle: Text(
                        'Apps locked: ${(device['lockedApps'] as List?)?.length ?? 0}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _manageChildDevice(device),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Screen Time Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'View Reports',
                  icon: Icons.analytics,
                  onPressed: () => Navigator.pushNamed(context, '/reports'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency PIN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Set Emergency PIN',
                  ),
                ),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'Save PIN',
                  onPressed: () async {
                    if (_pinController.text.length >= 4) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                        'emergencyPin',
                        _pinController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Emergency PIN saved')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JoinChildScreen extends StatefulWidget {
  const JoinChildScreen({super.key});
  @override
  State<JoinChildScreen> createState() => _JoinChildScreenState();
}

class _JoinChildScreenState extends State<JoinChildScreen> {
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join as Child')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.child_care, size: 64, color: kAccentColor),
                const SizedBox(height: 16),
                const Text(
                  'Enter Parent Link Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask your parent for the 6-digit code',
                  style: TextStyle(color: kTextSubtleColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '6-digit code'),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Join',
                  onPressed: () async {
                    if (_codeController.text.length == 6) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isChildDevice', true);
                      await prefs.setString('parentCode', _codeController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Device registered as Child'),
                        ),
                      );
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a 6-digit code'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChildManagementScreen extends StatefulWidget {
  const ChildManagementScreen({super.key});
  @override
  State<ChildManagementScreen> createState() => _ChildManagementScreenState();
}

class _ChildManagementScreenState extends State<ChildManagementScreen> {
  Map<String, dynamic>? _childDevice;
  final List<String> _availableApps = [
    'Instagram',
    'YouTube',
    'TikTok',
    'Twitter',
    'Facebook',
    'Snapchat',
    'Discord',
    'Games',
  ];
  final Map<String, bool> _selectedApps = {};
  Duration _lockDuration = const Duration(hours: 2);
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _loadChildDevice();
    for (final app in _availableApps) {
      _selectedApps[app] = false;
    }
  }

  void _loadChildDevice() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _childDevice = args;
        _isLocked = args['isLocked'] ?? false;
        final lockedApps = args['lockedApps'] as List<String>? ?? [];
        for (final app in lockedApps) {
          if (_selectedApps.containsKey(app)) {
            _selectedApps[app] = true;
          }
        }
      });
    }
  }

  Future<void> _lockApps() async {
    final selectedApps = _selectedApps.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selectedApps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one app to lock')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final deviceId = _childDevice!['id'] as String;
    final updatedDevice = Map<String, dynamic>.from(_childDevice!);
    updatedDevice['lockedApps'] = selectedApps;
    updatedDevice['isLocked'] = true;
    updatedDevice['lockUntil'] = DateTime.now()
        .add(_lockDuration)
        .millisecondsSinceEpoch;

    await prefs.setString(deviceId, updatedDevice.toString());

    setState(() {
      _isLocked = true;
      _childDevice = updatedDevice;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Apps locked for ${_lockDuration.inHours} hours')),
    );
  }

  Future<void> _unlockApps() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = _childDevice!['id'] as String;
    final updatedDevice = Map<String, dynamic>.from(_childDevice!);
    updatedDevice['isLocked'] = false;
    updatedDevice['lockUntil'] = null;

    await prefs.setString(deviceId, updatedDevice.toString());

    setState(() {
      _isLocked = false;
      _childDevice = updatedDevice;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Apps unlocked')));
  }

  @override
  Widget build(BuildContext context) {
    if (_childDevice == null)
      return const Scaffold(
        body: Center(child: Text('No child device selected')),
      );

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage ${_childDevice!['name'] ?? 'Child Device'}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.child_care, color: kAccentColor),
                    const SizedBox(width: 8),
                    Text(
                      _childDevice!['name'] ?? 'Child Device',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isLocked ? kSuccessColor : kTextSubtleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isLocked ? 'LOCKED' : 'UNLOCKED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Apps to Lock:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _selectedApps.entries)
                      FilterChip(
                        label: Text(entry.key),
                        selected: entry.value,
                        onSelected: _isLocked
                            ? null
                            : (v) =>
                                  setState(() => _selectedApps[entry.key] = v),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lock Duration:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: '1 Hour',
                        isPrimary: false,
                        onPressed: _isLocked
                            ? null
                            : () => setState(
                                () => _lockDuration = const Duration(hours: 1),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GradientButton(
                        label: '2 Hours',
                        isPrimary: false,
                        onPressed: _isLocked
                            ? null
                            : () => setState(
                                () => _lockDuration = const Duration(hours: 2),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GradientButton(
                        label: '4 Hours',
                        isPrimary: false,
                        onPressed: _isLocked
                            ? null
                            : () => setState(
                                () => _lockDuration = const Duration(hours: 4),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actions:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: _isLocked ? 'Unlock Apps' : 'Lock Apps',
                        icon: _isLocked ? Icons.lock_open : Icons.lock,
                        onPressed: _isLocked ? _unlockApps : _lockApps,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Time Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Usage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              const labels = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ];
                              final i = v.toInt();
                              return Text(
                                i >= 0 && i < labels.length ? labels[i] : '',
                                style: const TextStyle(color: kTextSubtleColor),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: kAccentColor,
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(1, 2),
                            FlSpot(2, 4),
                            FlSpot(3, 1),
                            FlSpot(4, 3),
                            FlSpot(5, 5),
                            FlSpot(6, 2),
                          ],
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                kAccentColor.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Usage Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...['Instagram', 'YouTube', 'Twitter'].map(
                  (app) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.apps)),
                    title: Text(app),
                    subtitle: const Text('2h 30m today'),
                    trailing: const Text(
                      '45%',
                      style: TextStyle(color: kAccentColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});
  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _taskController = TextEditingController();
  final Map<String, bool> _apps = {
    'Instagram': false,
    'YouTube': false,
    'Twitter': false,
  };
  bool _requirePhoto = true;

  void _startTask() {
    final selected = _apps.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    Navigator.pushReplacementNamed(
      context,
      '/focus',
      arguments: {
        'task': _taskController.text.trim(),
        'apps': selected,
        'requirePhoto': _requirePhoto,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Focus Task')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Task'),
                const SizedBox(height: 8),
                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Finish chapter notes',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Lock Apps'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _apps.entries)
                      FilterChip(
                        label: Text(entry.key),
                        selected: entry.value,
                        onSelected: (v) => setState(() => _apps[entry.key] = v),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Require Photo Proof to Unlock'),
                  value: _requirePhoto,
                  onChanged: (v) => setState(() => _requirePhoto = v),
                ),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'Start Focus',
                  icon: Icons.play_arrow,
                  onPressed: _startTask,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kSurfaceColor,
      child: SafeArea(
        child: ListView(
          children: [
            const ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Username'),
              subtitle: Text('Streak: 3 • XP: 120'),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Achievements'),
              onTap: () => Navigator.pushNamed(context, '/achievements'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Streaks / Calendar'),
              onTap: () => Navigator.pushNamed(context, '/calendar'),
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Leaderboard'),
              onTap: () => Navigator.pushNamed(context, '/leaderboard'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.add_task),
              title: const Text('New Task'),
              onTap: () => Navigator.pushNamed(context, '/task-create'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSessionsStrip extends StatelessWidget {
  const _RecentSessionsStrip();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => SizedBox(
          width: 220,
          child: SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session ${i + 1}'),
                const SizedBox(height: 8),
                const Text(
                  '25 min • +20 XP',
                  style: TextStyle(color: kTextSubtleColor),
                ),
              ],
            ),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 6,
      ),
    );
  }
}

class _AppLockChips extends StatelessWidget {
  const _AppLockChips();
  @override
  Widget build(BuildContext context) {
    final apps = ['Instagram', 'YouTube', 'TikTok', 'Twitter'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final a in apps)
          FilterChip(label: Text(a), selected: false, onSelected: (_) {}),
      ],
    );
  }
}

class _MemberList extends StatelessWidget {
  const _MemberList();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (i) => ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('Member ${i + 1}'),
          subtitle: const LinearProgressIndicator(
            value: 0.5,
            color: kPrimaryColor,
            backgroundColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final String title;
  const _LeaderboardList({required this.title});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (ctx, i) {
        final isTop = i < 3;
        return Container(
          decoration: BoxDecoration(
            gradient: isTop ? kPrimaryGradient : null,
            color: isTop ? null : const Color(0xFF242424),
            borderRadius: kRadiusMedium,
            boxShadow: isTop
                ? [
                    BoxShadow(
                      color: kAccentColor.withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isTop ? Colors.white : Colors.white10,
              child: Text(
                '#${i + 1}',
                style: TextStyle(color: isTop ? Colors.black : Colors.white),
              ),
            ),
            title: Text('$title User ${i + 1}'),
            subtitle: const Text('XP: 1200'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 20,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rndOffsets = [
      const Offset(50, 120),
      Offset(size.width - 80, 200),
      Offset(size.width * 0.3, size.height * 0.25),
      Offset(size.width * 0.7, size.height * 0.65),
      const Offset(120, 420),
    ];
    final paint = Paint()..color = const Color(0xFF3BA3FF).withOpacity(0.25);
    for (final o in rndOffsets) {
      canvas.drawCircle(o, 3, paint);
      canvas.drawCircle(
        o + const Offset(12, -8),
        2,
        paint..color = const Color(0xFF7B61FF).withOpacity(0.18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void showForgotPasswordDialog(BuildContext context) {
  String email = '';
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Reset Password'),
      content: TextField(
        decoration: InputDecoration(hintText: 'Enter your email'),
        onChanged: (value) => email = value,
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text('Send Reset Link'),
          onPressed: () async {
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: email.trim(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset link sent to email')),
              );
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
            }
          },
        ),
      ],
    ),
  );
}
