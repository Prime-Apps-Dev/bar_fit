// ignore_for_file: unused_local_variable, body_might_complete_normally_catch_error

import 'dart:async';
import 'dart:convert';
import 'package:bar_fit/one_screen.dart';
import 'package:audioplayers/audioplayers.dart';


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_screen.dart';
import 'mode_screen.dart';

class ThreeScreen extends StatefulWidget {
  @override
  _ThreeScreenState createState() => _ThreeScreenState();
}

class _ThreeScreenState extends State<ThreeScreen> {
  int totalExercises = 5,
      exerciseDuration = 30,
      exerciseBreak = 10,
      roundDuration = 5,
      roundBreak = 30;
  int currentExercise = 1, currentRound = 1, remainingTime = 30, totalTime = 30;
  Timer? timer;
  bool isRunning = false,
      isBreakTime = false,
      isSaved = false,
      isRoundBreakTime = false;
  List<Map<String, dynamic>> savedModes = [];
  String selectedMelody = 'assets/sounds/002.mp3';
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _tickPlayer = AudioPlayer();

  int sessionSeconds = 0; // <--- новое поле

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSessionSeconds(); // загружаем сохранённое время
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalExercises = prefs.getInt('exerciseCount') ?? 5;
      exerciseDuration = prefs.getInt('exerciseDuration') ?? 30;
      exerciseBreak = prefs.getInt('exerciseBreak') ?? 10;
      roundDuration = prefs.getInt('roundCount') ?? 5;
      roundBreak = prefs.getInt('roundBreak') ?? 30;
      remainingTime = exerciseDuration;
      totalTime = exerciseDuration;
      selectedMelody =
          prefs.getString('selectedMelody') ?? 'assets/sounds/002.mp3';
      savedModes = (prefs.getStringList('savedModes') ?? [])
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
    });
  }

  Future<void> _saveModes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'savedModes', savedModes.map((e) => jsonEncode(e)).toList());
  }

  Future<void> _updateCurrentSessionTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentSessionTime', sessionSeconds);
  }

  Future<void> _resetCurrentSessionTime() async {
    sessionSeconds = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentSessionTime', 0);
  }

  Future<void> _loadSessionSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sessionSeconds = prefs.getInt('sharedTimer') ?? 0;
    });
  }

  void startTimer() {
    setState(() {
      isRunning = true;
      isSaved = false;
    });
    timer?.cancel();
    totalTime = isBreakTime
        ? (isRoundBreakTime ? roundBreak : exerciseBreak)
        : exerciseDuration;
    remainingTime = totalTime;

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (remainingTime == 0) {
        if (isBreakTime) {
          nextExerciseOrRound();
        } else {
          startBreak();
        }
      } else {
       if (remainingTime == 5) {
  var audioPlayer = _audioPlayer;
  try {
    await audioPlayer.setSource(AssetSource(selectedMelody));
    await audioPlayer.resume();
  } catch (error) {
    print('Ошибка при воспроизведении мелодии: $error');
  }
}

        if (remainingTime <= 5) {
          var tickPlayer = _tickPlayer;
          tickPlayer.setSource(AssetSource('assets/sounds/tick.mp3')).catchError((error) {});
          tickPlayer.resume().catchError((error) {});
        }
        setState(() {
          remainingTime--;
          sessionSeconds++;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('sharedTimer', sessionSeconds);
      }
    });
  }

  void stopTimer() async {
    setState(() {
      isRunning = false;
      isSaved = false;
      currentExercise = 1;
      currentRound = 1;
      remainingTime = exerciseDuration;
      totalTime = exerciseDuration;
      isBreakTime = false;
      isRoundBreakTime = false;
      sessionSeconds = 0;
    });
    timer?.cancel();
    await _resetCurrentSessionTime();
  }

  void pauseTimer() {
    setState(() {
      isRunning = false;
    });
    timer?.cancel();
  }

  void resetTimer() async {
    setState(() {
      isRunning = false;
      isSaved = false;
      currentExercise = 1;
      currentRound = 1;
      remainingTime = exerciseDuration;
      totalTime = exerciseDuration;
      isBreakTime = false;
      isRoundBreakTime = false;
      sessionSeconds = 0;
    });
    timer?.cancel();
    await _resetCurrentSessionTime();
  }

  void startBreak() {
    setState(() {
      isBreakTime = true;
      remainingTime = isRoundBreakTime ? roundBreak : exerciseBreak;
      totalTime = isRoundBreakTime ? roundBreak : exerciseBreak;
    });
  }

  void nextExerciseOrRound() {
    if (isRoundBreakTime) {
      setState(() {
        isRoundBreakTime = false;
        isBreakTime = false;
        currentExercise = 1;
        currentRound++;
        startTimer();
      });
    } else {
      setState(() {
        isBreakTime = false;
        if (currentExercise < totalExercises) {
          currentExercise++;
          startTimer();
        } else if (currentRound < roundDuration) {
          currentExercise = 1;
          isRoundBreakTime = true;
          startBreak();
        } else {
          timer?.cancel();
          resetTimer();
        }
      });
    }
  }

  void bookmarkMode() {
    String mode = 'Exercise $currentExercise / Round $currentRound';
    Map<String, dynamic> modeData = {
      'mode': mode,
      'totalExercises': totalExercises,
      'exerciseDuration': exerciseDuration,
      'exerciseBreak': exerciseBreak,
      'roundDuration': roundDuration,
      'roundBreak': roundBreak,
      'currentExercise': currentExercise,
      'currentRound': currentRound,
    };

    savedModes.add(modeData);
    _saveModes();
    setState(() {
      isSaved = true; // это вызовет отображение _modeDataContainer
    });
  }

  void loadMode(Map<String, dynamic> modeData) {
    setState(() {
      totalExercises = modeData['totalExercises'];
      exerciseDuration = modeData['exerciseDuration'];
      exerciseBreak = modeData['exerciseBreak'];
      roundDuration = modeData['roundDuration'];
      roundBreak = modeData['roundBreak'];
      currentExercise = 1; // всегда с первого упражнения
      currentRound = 1;    // всегда с первого круга
      isRunning = false;
      remainingTime = exerciseDuration;
      totalTime = exerciseDuration;
      timer?.cancel();
      sessionSeconds = 0;
    });
    _resetCurrentSessionTime();
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    _tickPlayer.dispose();
    _resetCurrentSessionTime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double timerFontSize = width * 0.28;
    double cardWidth = width * 0.90;
    double cardHeight = height * 0.24;
    double buttonHeight = height * 0.09; // было 0.065, стало выше
    double iconSize = width * 0.11; // например, было 0.09, стало 0.13

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          // Свайп вниз
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OneScreen(),
            ),
          );
        } else if (details.primaryVelocity != null &&
            details.primaryVelocity! < 0) {
          // Свайп вверх
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const OneScreen(), // Замените на ваш предыдущий экран
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, -1.0); // Экран уходит вверх
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween =
                    Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Верхняя часть (таймер и кнопки)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Text('Таймер',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: height * 0.01),
                    Spacer(flex: 80),
                    Text(
                      '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: timerFontSize, fontWeight: FontWeight.bold),
                    ),
                    Spacer(flex: 35),
                    Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    GestureDetector(
      onTap: isRunning ? pauseTimer : startTimer,
      child: Icon(
        isRunning ? Icons.pause : Icons.play_arrow,
        size: iconSize, // ← теперь зависит от iconSize
      ),
    ),
    if (isRunning) SizedBox(width: width * 0.025),
    if (isRunning)
      GestureDetector(
        onTap: stopTimer,
        child: Icon(Icons.stop, size: iconSize), // ← тоже iconSize
      ),
  ],
),
                    SizedBox(height: height * 0.02),
                    if (isSaved)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text('Сохранено!', style: TextStyle(color: Colors.blue)),
                      ),
                    Spacer(flex: 2),
                  ],
                ),
              ),
              // Нижний контейнер всегда внизу
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _exerciseCard(context, cardWidth, cardHeight, buttonHeight, iconSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, double cardWidth, double cardHeight, double buttonHeight, double iconSize) {
    return Container(
      padding: const EdgeInsets.all(19),
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // мягкая тень
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow('Упражнения', '$currentExercise/$totalExercises', 26, Colors.black),
          const SizedBox(height: 12),
          _buildRow('Круги', '$currentRound/$roundDuration', 24, Colors.black),
          const SizedBox(height: 12),
          _progressBar(cardWidth),
          const SizedBox(height: 18),
          Row(
            children: [
              _actionButton('Режимы', Icons.settings_input_svideo, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModeScreen(
                      savedModes: savedModes,
                      onModeSelected: loadMode,
                      onDeleteMode: (mode) {
                        setState(() {
                          savedModes.remove(mode);
                        });
                        _saveModes();
                      },
                    ),
                  ),
                );
              }, 58, iconSize: 32, labelFontSize: 18),
              SizedBox(width: 14),
              _iconButton(Icons.bookmark_border, bookmarkMode, 58, iconSize - 6),
              SizedBox(width: 14),
              _iconButton(Icons.settings, () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()));
                _loadSettings();
              }, 58, iconSize - 6),
            ],
          ),
        
        ],
      ),
    );
  }

  Widget _buildRow(
    String leftText, String rightText, double fontSize, Color color) {
  return Row(
    children: [
      Text(leftText,
          style: TextStyle(
              fontSize: fontSize, fontWeight: FontWeight.bold, color: color)),
      const Spacer(),
      Text(rightText,
          style: TextStyle(
              fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.blue)), // всегда синий
    ],
  );
}

  Widget _progressBar(double cardWidth) {
    double progressFraction = isBreakTime
        ? 1 - (remainingTime / totalTime)
        : (totalTime - remainingTime) / totalTime;

    return Container(
      height: 37,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            alignment:
                isBreakTime ? Alignment.centerRight : Alignment.centerLeft,
            width: (cardWidth - 30) * progressFraction, // 30 = padding*2
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    double height, {
    double iconSize = 24,
    double labelFontSize = 25, // <-- добавили параметр
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: iconSize),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: labelFontSize, // <-- увеличенный размер
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, double height, double iconSize) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: height * 0.9,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}