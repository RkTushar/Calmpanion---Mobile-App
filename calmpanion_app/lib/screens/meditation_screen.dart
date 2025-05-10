import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  int _selectedDuration = 5; // Default 5 minutes
  bool _isMeditating = false;
  int _remainingSeconds = 0;
  final List<int> _durations = [5, 10, 15, 20, 30];
  final _storage = GetStorage();
  static const String _meditationKey = 'meditation_sessions';

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _breathingController.forward();
      }
    });
  }

  void _startMeditation() {
    setState(() {
      _isMeditating = true;
      _remainingSeconds = _selectedDuration * 60;
    });
    _breathingController.forward();
    _startTimer();
  }

  void _stopMeditation() {
    setState(() {
      _isMeditating = false;
      _remainingSeconds = 0;
    });
    _breathingController.stop();
    _breathingController.reset();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isMeditating && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _startTimer();
      } else if (_remainingSeconds == 0) {
        _completeMeditation();
      }
    });
  }

  void _completeMeditation() {
    _stopMeditation();
    _saveMeditationSession();
    _showCompletionDialog();
  }

  void _saveMeditationSession() {
    try {
      final List<dynamic> sessions = _storage.read(_meditationKey) ?? [];
      sessions.add({
        'duration': _selectedDuration,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _storage.write(_meditationKey, sessions);
    } catch (e) {
      debugPrint('Error saving meditation session: $e');
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Great job! 🎉'),
        content: Text(
          'You\'ve completed a $_selectedDuration minute meditation session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Meditation'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isMeditating) ...[
            const Text(
              'Choose Duration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _durations.map((duration) {
                return ChoiceChip(
                  label: Text('$duration min'),
                  selected: _selectedDuration == duration,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDuration = duration;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isMeditating ? _breathingAnimation.value : 1.0,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _isMeditating ? _formatTime(_remainingSeconds) : 'Ready',
                      style: TextStyle(
                        fontSize: _isMeditating ? 48 : 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          if (!_isMeditating)
            ElevatedButton(
              onPressed: _startMeditation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Start Meditation',
                style: TextStyle(fontSize: 18),
              ),
            )
          else
            ElevatedButton(
              onPressed: _stopMeditation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Stop',
                style: TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }
}
