import 'package:flutter/material.dart';
import 'components.dart';
import 'theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
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
              child: CustomPaint(painter: _ParticlePainter()).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: const Duration(seconds: 3),
                colors: const [Color(0x113BA3FF), Color(0x333BA3FF), Color(0x117B61FF)],
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
                      boxShadow: [BoxShadow(color: kAccentColor.withOpacity(0.35), blurRadius: 30, spreadRadius: 2)],
                    ),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Text('Lock distractions. Unlock focus.', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: kTextSubtleColor)),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GradientButton(label: 'Get Started', icon: Icons.play_arrow_rounded, onPressed: () => Navigator.pushNamed(context, '/auth')),
                      const SizedBox(width: 16),
                      GradientButton(label: 'Login', isPrimary: false, onPressed: () => Navigator.pushNamed(context, '/auth')),
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
                TextField(decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?', style: TextStyle(color: kTextSubtleColor)),
                  ),
                ),
                const SizedBox(height: 8),
                GradientButton(label: 'Login', onPressed: () => Navigator.pushReplacementNamed(context, '/user-type')),
                const SizedBox(height: 12),
                GradientButton(label: 'Register', onPressed: () => Navigator.pushReplacementNamed(context, '/user-type')),
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
                onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                child: SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.person, size: 48), SizedBox(height: 8), Text('Individual')]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pushReplacementNamed(context, '/parent-dashboard'),
                child: SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.family_restroom, size: 48), SizedBox(height: 8), Text('Parent')]),
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
          builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        title: const Text('LockIn'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isChildDevice && _isLocked) ...[
            SoftCard(
              child: Column(children: [
                const Icon(Icons.lock, color: kAccentColor, size: 48),
                const SizedBox(height: 8),
                const Text('Parent Lock Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Locked Apps: ${_lockedApps.join(', ')}', style: const TextStyle(color: kTextSubtleColor)),
                const SizedBox(height: 12),
                GradientButton(label: 'Emergency Unlock', icon: Icons.lock_open, onPressed: _showEmergencyUnlock),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          if (!_isChildDevice) ...[
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Join Parent Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Enter parent code to connect your device', style: TextStyle(color: kTextSubtleColor)),
                const SizedBox(height: 12),
                GradientButton(label: 'Join as Child', icon: Icons.child_care, onPressed: () => Navigator.pushNamed(context, '/join-child')),
              ]),
            ),
            const SizedBox(height: 16),
          ],
          SoftCard(
            child: Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Stay focused ✨', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('“Lock distractions. Unlock focus.”', style: TextStyle(color: kTextSubtleColor))])),
                const SizedBox(width: 12),
                GradientButton(label: 'Start Focus', icon: Icons.play_arrow, onPressed: () => Navigator.pushNamed(context, '/focus')),
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
                Row(children: const [
                  Expanded(child: Center(child: FocusProgressRing(progress: 0.35, centerLabel: '15:23'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Text('XP: 120', style: Theme.of(context).textTheme.bodyMedium)),
                  Expanded(child: Text('Streak: 3 days', style: Theme.of(context).textTheme.bodyMedium)),
                  Expanded(child: Text('Total: 12h', style: Theme.of(context).textTheme.bodyMedium)),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: [
                  GradientButton(label: 'Achievements', isPrimary: false, onPressed: () => Navigator.pushNamed(context, '/achievements')),
                  GradientButton(label: 'Join Group', isPrimary: false, onPressed: () => Navigator.pushNamed(context, '/group')),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _RecentSessionsStrip(),
          const SizedBox(height: 16),
          SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Create Focus Task'),
            const SizedBox(height: 8),
            GradientButton(label: 'Write Task & Select Apps', icon: Icons.add_task, onPressed: () => Navigator.pushNamed(context, '/task-create')),
            const SizedBox(height: 16),
            const Text('Select apps to lock'),
            const SizedBox(height: 8),
            const _AppLockChips(),
          ])),
        ],
      ),
    );
  }

  void _showEmergencyUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    final emergencyPin = prefs.getString('emergencyPin') ?? '';
    
    if (emergencyPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No emergency PIN set. Contact parent.')));
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
              const Text('Emergency Unlock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Enter emergency PIN provided by parent', style: TextStyle(color: kTextSubtleColor)),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device unlocked!')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PIN')));
                  }
                },
              ),
              const SizedBox(height: 12),
              GradientButton(label: 'Unlock', onPressed: () => Navigator.pop(ctx)),
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
  Duration _total = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  Timer? _timer;
  bool _isRunning = false;
  bool _requirePhoto = false;
  XFile? _proof;

  double get _progress => 1 - (_remaining.inSeconds / _total.inSeconds).clamp(0.0, 1.0);
  String get _label {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining.inSeconds <= 1) {
        t.cancel();
        setState(() {
          _remaining = Duration.zero;
          _isRunning = false;
        });
        _showCompletedDialog();
      } else {
        setState(() => _remaining = Duration(seconds: _remaining.inSeconds - 1));
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetWith(Duration d) {
    _timer?.cancel();
    setState(() {
      _total = d;
      _remaining = d;
      _isRunning = false;
    });
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF262626),
        title: const Text('Session Complete', style: TextStyle(color: kSuccessColor)),
        content: const Text('Great job! +20 XP earned.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _promptEmergencyUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    final isChildDevice = prefs.getBool('isChildDevice') ?? false;
    final parentLockActive = prefs.getBool('parentLockActive') ?? false;
    
    if (isChildDevice && parentLockActive) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parent lock is active. Contact parent to unlock.')));
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
              const Text('Emergency Unlock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const TextField(obscureText: true, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Enter Parent PIN')),
              const SizedBox(height: 12),
              GradientButton(label: 'Unlock', onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }),
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final taskName = (args?['task'] as String?)?.trim();
    final lockedApps = (args?['apps'] as List?)?.cast<String>() ?? const [];
    _requirePhoto = args?['requirePhoto'] == true;
    return Scaffold(
      body: Stack(
        children: [
          Center(child: FocusProgressRing(progress: _progress, centerLabel: _label)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kSurfaceColor.withOpacity(0.6), borderRadius: kRadiusLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (taskName != null && taskName.isNotEmpty) ...[
                    Row(children: [
                      const Icon(Icons.flag_rounded, size: 18, color: kTextSubtleColor),
                      const SizedBox(width: 6),
                      Expanded(child: Text(taskName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 6),
                    if (lockedApps.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Locked: ${lockedApps.join(', ')}', style: const TextStyle(color: kTextSubtleColor)),
                      ),
                    const SizedBox(height: 10),
                  ] else ...[
                    Row(children: [
                      const Icon(Icons.timer, size: 18, color: kTextSubtleColor),
                      const SizedBox(width: 6),
                      const Expanded(child: Text('Focus Session', style: TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 10),
                  ],
                  Row(children: [
                    Expanded(child: Text(_isRunning ? 'Lock Mode Active' : 'Paused', style: const TextStyle(color: kTextSubtleColor))),
                    if (!_isRunning)
                      GradientButton(label: 'Start', icon: Icons.play_arrow, onPressed: _startTimer)
                    else
                      GradientButton(label: 'Pause', icon: Icons.pause, onPressed: _pauseTimer),
                    const SizedBox(width: 8),
                    if (_requirePhoto)
                      GradientButton(label: _proof == null ? 'Add Photo' : 'Photo Added', onPressed: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(source: ImageSource.camera);
                        if (img != null) setState(() => _proof = img);
                      })
                    else
                      GradientButton(label: 'Emergency Unlock', onPressed: _promptEmergencyUnlock),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: GradientButton(label: '25 min', isPrimary: false, onPressed: () => _resetWith(const Duration(minutes: 25)))),
                    const SizedBox(width: 8),
                    Expanded(child: GradientButton(label: '45 min', isPrimary: false, onPressed: () => _resetWith(const Duration(minutes: 45)))),
                    const SizedBox(width: 8),
                    Expanded(child: GradientButton(label: 'Custom', isPrimary: false, onPressed: () async {
                      final d = await showDialog<Duration>(context: context, builder: (ctx) => const _CustomDurationDialog());
                      if (d != null) _resetWith(d);
                    })),
                  ]),
                  if (_requirePhoto)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(children: const [Icon(Icons.info_outline, size: 16, color: kTextSubtleColor), SizedBox(width: 6), Expanded(child: Text('Photo proof is required to unlock at end of session.', style: TextStyle(color: kTextSubtleColor)))]),
                    ),
                  const SizedBox(height: 10),
                  const Text('Focus Tools:', style: TextStyle(fontWeight: FontWeight.w600, color: kTextSubtleColor)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: GradientButton(label: 'AI Coach', isPrimary: false, icon: Icons.psychology, onPressed: () => _openCoach(context, taskName))),
                    const SizedBox(width: 8),
                    Expanded(child: GradientButton(label: 'Motivate', isPrimary: false, icon: Icons.bolt, onPressed: () => _showMotivation(context))),
                  ]),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.psychology, color: kAccentColor), const SizedBox(width: 8), const Text('AI Coach', style: TextStyle(fontWeight: FontWeight.w700))]),
            if (task != null && task.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Task: $task', style: const TextStyle(color: kTextSubtleColor)),
            ],
            const SizedBox(height: 12),
            ...tips.map((t) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [const Icon(Icons.check_circle, size: 16, color: kSuccessColor), const SizedBox(width: 8), Expanded(child: Text(t))]))),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight, child: GradientButton(label: 'Got it', onPressed: () => Navigator.pop(context), isPrimary: false)),
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

class _CustomDurationDialog extends StatefulWidget {
  const _CustomDurationDialog();
  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  final _controller = TextEditingController(text: '30');
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xCC1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: kRadiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Custom Duration (minutes)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutes')),
            const SizedBox(height: 12),
            GradientButton(label: 'Set', onPressed: () {
              final n = int.tryParse(_controller.text.trim());
              Navigator.pop(context, (n != null && n > 0) ? Duration(minutes: n) : const Duration(minutes: 25));
            }),
          ],
        ),
      ),
    );
  }
}

class GroupLockScreen extends StatelessWidget {
  const GroupLockScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Focus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: GradientButton(label: 'Create Group', onPressed: () {})),
            const SizedBox(width: 12),
            Expanded(child: GradientButton(label: 'Join Group', onPressed: () {})),
          ]),
          const SizedBox(height: 16),
          const _MemberList(),
          const SizedBox(height: 16),
          Center(child: GradientButton(label: 'Start Together', icon: Icons.play_arrow_rounded, onPressed: () {})),
        ],
      ),
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
        itemCount: 6,
        itemBuilder: (_, i) => SoftCard(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.emoji_events, color: kAccentColor, size: 40),
            const SizedBox(height: 8),
            Text('Streak Badge', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('+50 XP', style: TextStyle(color: kSuccessColor)),
            const SizedBox(height: 12),
            GradientButton(label: 'Upload Photo', isPrimary: false, onPressed: () {}),
          ]),
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
                todayDecoration: BoxDecoration(color: kAccentColor, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
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
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final i = v.toInt();
                            return Text(i >= 0 && i < labels.length ? labels[i] : '', style: const TextStyle(color: kTextSubtleColor));
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
                        belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [kAccentColor.withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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
          bottom: const TabBar(tabs: [Tab(text: 'Global'), Tab(text: 'Group')]),
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
    return Scaffold(appBar: AppBar(title: const Text('Profile & Settings')), body: const Center(child: Text('Profile card, preferences, accessibility')));
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
            _childDevices.add(Map<String, dynamic>.from({
              'id': deviceJson,
              'name': 'Child Device ${_childDevices.length + 1}',
              'lockedApps': <String>[],
              'isLocked': false,
            }));
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
              const Text('Add Child Device', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('Share this code with your child:', style: TextStyle(color: kTextSubtleColor)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.2), borderRadius: kRadiusMedium),
                child: Text(_linkCode, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 4)),
              ),
              const SizedBox(height: 16),
              GradientButton(label: 'Generate New Code', onPressed: () {
                setState(() => _linkCode = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString());
              }),
            ],
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.family_restroom, color: kAccentColor),
                const SizedBox(width: 8),
                const Text('Child Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                GradientButton(label: 'Add Child', icon: Icons.add, onPressed: _addChildDevice),
              ]),
              const SizedBox(height: 16),
              if (_childDevices.isEmpty)
                const Center(child: Text('No child devices added yet', style: TextStyle(color: kTextSubtleColor)))
              else
                ..._childDevices.map((device) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.child_care)),
                  title: Text(device['name'] ?? 'Child Device'),
                  subtitle: Text('Apps locked: ${(device['lockedApps'] as List?)?.length ?? 0}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _manageChildDevice(device),
                )),
            ]),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Screen Time Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              GradientButton(label: 'View Reports', icon: Icons.analytics, onPressed: () => Navigator.pushNamed(context, '/reports')),
            ]),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Emergency PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(controller: _pinController, obscureText: true, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Set Emergency PIN')),
              const SizedBox(height: 8),
              GradientButton(label: 'Save PIN', onPressed: () async {
                if (_pinController.text.length >= 4) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('emergencyPin', _pinController.text);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency PIN saved')));
                }
              }),
            ]),
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
                const Text('Enter Parent Link Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Ask your parent for the 6-digit code', style: TextStyle(color: kTextSubtleColor)),
                const SizedBox(height: 16),
                TextField(controller: _codeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '6-digit code')),
                const SizedBox(height: 16),
                GradientButton(label: 'Join', onPressed: () async {
                  if (_codeController.text.length == 6) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isChildDevice', true);
                    await prefs.setString('parentCode', _codeController.text);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device registered as Child')));
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a 6-digit code')));
                  }
                }),
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
  final List<String> _availableApps = ['Instagram', 'YouTube', 'TikTok', 'Twitter', 'Facebook', 'Snapchat', 'Discord', 'Games'];
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
    final selectedApps = _selectedApps.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedApps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one app to lock')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final deviceId = _childDevice!['id'] as String;
    final updatedDevice = Map<String, dynamic>.from(_childDevice!);
    updatedDevice['lockedApps'] = selectedApps;
    updatedDevice['isLocked'] = true;
    updatedDevice['lockUntil'] = DateTime.now().add(_lockDuration).millisecondsSinceEpoch;
    
    await prefs.setString(deviceId, updatedDevice.toString());
    
    setState(() {
      _isLocked = true;
      _childDevice = updatedDevice;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apps locked for ${_lockDuration.inHours} hours')));
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
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apps unlocked')));
  }

  @override
  Widget build(BuildContext context) {
    if (_childDevice == null) return const Scaffold(body: Center(child: Text('No child device selected')));
    
    return Scaffold(
      appBar: AppBar(title: Text('Manage ${_childDevice!['name'] ?? 'Child Device'}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.child_care, color: kAccentColor),
                const SizedBox(width: 8),
                Text(_childDevice!['name'] ?? 'Child Device', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isLocked ? kSuccessColor : kTextSubtleColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_isLocked ? 'LOCKED' : 'UNLOCKED', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 16),
              const Text('Select Apps to Lock:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final entry in _selectedApps.entries)
                  FilterChip(
                    label: Text(entry.key),
                    selected: entry.value,
                    onSelected: _isLocked ? null : (v) => setState(() => _selectedApps[entry.key] = v),
                  ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Lock Duration:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: GradientButton(label: '1 Hour', isPrimary: false, onPressed: _isLocked ? null : () => setState(() => _lockDuration = const Duration(hours: 1)))),
                const SizedBox(width: 8),
                Expanded(child: GradientButton(label: '2 Hours', isPrimary: false, onPressed: _isLocked ? null : () => setState(() => _lockDuration = const Duration(hours: 2)))),
                const SizedBox(width: 8),
                Expanded(child: GradientButton(label: '4 Hours', isPrimary: false, onPressed: _isLocked ? null : () => setState(() => _lockDuration = const Duration(hours: 4)))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Actions:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: GradientButton(label: _isLocked ? 'Unlock Apps' : 'Lock Apps', icon: _isLocked ? Icons.lock_open : Icons.lock, onPressed: _isLocked ? _unlockApps : _lockApps)),
              ]),
            ]),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Daily Usage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            final i = v.toInt();
                            return Text(i >= 0 && i < labels.length ? labels[i] : '', style: const TextStyle(color: kTextSubtleColor));
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
                        belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [kAccentColor.withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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
            ]),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('App Usage Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...['Instagram', 'YouTube', 'TikTok', 'Twitter'].map((app) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.apps)),
                title: Text(app),
                subtitle: const Text('2h 30m today'),
                trailing: const Text('45%', style: TextStyle(color: kAccentColor)),
              )),
            ]),
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
  final Map<String, bool> _apps = {'Instagram': false, 'YouTube': false, 'TikTok': false, 'Twitter': false};
  bool _requirePhoto = true;

  void _startTask() {
    final selected = _apps.entries.where((e) => e.value).map((e) => e.key).toList();
    Navigator.pushReplacementNamed(context, '/focus', arguments: {
      'task': _taskController.text.trim(),
      'apps': selected,
      'requirePhoto': _requirePhoto,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Focus Task')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Task'),
              const SizedBox(height: 8),
              TextField(controller: _taskController, decoration: const InputDecoration(hintText: 'e.g., Finish chapter notes')),
              const SizedBox(height: 16),
              const Text('Lock Apps'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final entry in _apps.entries)
                  FilterChip(
                    label: Text(entry.key),
                    selected: entry.value,
                    onSelected: (v) => setState(() => _apps[entry.key] = v),
                  ),
              ]),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Require Photo Proof to Unlock'),
                value: _requirePhoto,
                onChanged: (v) => setState(() => _requirePhoto = v),
              ),
              const SizedBox(height: 8),
              GradientButton(label: 'Start Focus', icon: Icons.play_arrow, onPressed: _startTask),
            ]),
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
            const ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('Username'), subtitle: Text('Streak: 3 • XP: 120')),
            ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), onTap: () => Navigator.pushReplacementNamed(context, '/dashboard')),
            ListTile(leading: const Icon(Icons.emoji_events), title: const Text('Achievements'), onTap: () => Navigator.pushNamed(context, '/achievements')),
            ListTile(leading: const Icon(Icons.calendar_month), title: const Text('Streaks / Calendar'), onTap: () => Navigator.pushNamed(context, '/calendar')),
            ListTile(leading: const Icon(Icons.leaderboard), title: const Text('Leaderboard'), onTap: () => Navigator.pushNamed(context, '/leaderboard')),
            ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () => Navigator.pushNamed(context, '/settings')),
            ListTile(leading: const Icon(Icons.add_task), title: const Text('New Task'), onTap: () => Navigator.pushNamed(context, '/task-create')),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false)),
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
        itemBuilder: (_, i) => SizedBox(width: 220, child: SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Session ${i + 1}'), const SizedBox(height: 8), const Text('25 min • +20 XP', style: TextStyle(color: kTextSubtleColor))]))),
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
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final a in apps)
        FilterChip(
          label: Text(a),
          selected: false,
          onSelected: (_) {},
        ),
    ]);
  }
}

class _MemberList extends StatelessWidget {
  const _MemberList();
  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(5, (i) => ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text('Member ${i + 1}'), subtitle: const LinearProgressIndicator(value: 0.5, color: kPrimaryColor, backgroundColor: Colors.white24))));
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
            boxShadow: isTop ? [BoxShadow(color: kAccentColor.withOpacity(0.35), blurRadius: 18, spreadRadius: 1)] : const [],
          ),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: isTop ? Colors.white : Colors.white10, child: Text('#${i + 1}', style: TextStyle(color: isTop ? Colors.black : Colors.white))),
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
      canvas.drawCircle(o + const Offset(12, -8), 2, paint..color = const Color(0xFF7B61FF).withOpacity(0.18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


