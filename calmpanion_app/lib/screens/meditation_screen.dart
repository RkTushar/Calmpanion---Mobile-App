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

  // Breathing states
  String _breathingState = 'Ready';
  int _breathingCycle = 0;
  final int _inhaleDuration = 4;
  final int _holdDuration = 4;
  final int _exhaleDuration = 4;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration:
          Duration(seconds: _inhaleDuration + _holdDuration + _exhaleDuration),
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
        _breathingController.reset();
        _breathingController.forward();
        _breathingCycle++;
      }
    });

    _breathingController.addListener(() {
      if (_isMeditating) {
        final progress = _breathingController.value;
        final totalDuration = _inhaleDuration + _holdDuration + _exhaleDuration;
        if (progress < _inhaleDuration / totalDuration) {
          setState(() => _breathingState = 'Breathe In');
        } else if (progress <
            (_inhaleDuration + _holdDuration) / totalDuration) {
          setState(() => _breathingState = 'Hold');
        } else {
          setState(() => _breathingState = 'Breathe Out');
        }
      }
    });
  }

  void _startMeditation() {
    setState(() {
      _isMeditating = true;
      _remainingSeconds = _selectedDuration * 60;
      _breathingCycle = 0;
    });
    _breathingController.forward();
    _startTimer();
  }

  void _stopMeditation() {
    setState(() {
      _isMeditating = false;
      _remainingSeconds = 0;
      _breathingState = 'Ready';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isMeditating) ...[
              const Text(
                'Choose Duration',
                style: TextStyle(
                  fontSize: 28,
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
            Stack(
              alignment: Alignment.center,
              children: [
                // Background circles
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isMeditating
                            ? _breathingAnimation.value * (1 - index * 0.2)
                            : 1.0,
                        child: Container(
                          width: 200 + index * 40,
                          height: 200 + index * 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1 - index * 0.02),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3 - index * 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                // Main circle
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _breathingState,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isMeditating
                                  ? _formatTime(_remainingSeconds)
                                  : _formatTime(_selectedDuration * 60),
                              style: TextStyle(
                                fontSize: _isMeditating ? 48 : 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (_isMeditating) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Cycle: $_breathingCycle',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Stop',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }
}
