// ignore_for_file: unused_local_variable, body_might_complete_normally_catch_error

import 'dart:async';
import 'dart:convert';


import 'package:audioplayers/audioplayers.dart';
import 'package:bar_fit/one_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mode_screen.dart';
import 'settings_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
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

  timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    if (remainingTime == 0) {
      if (isBreakTime) {
        nextExerciseOrRound();
      } else {
        startBreak();
      }
    } else {
      if (remainingTime == 5) {
        var audioPlayer = _audioPlayer;
        audioPlayer.setSource(AssetSource(selectedMelody)).catchError((error) {});
        audioPlayer.resume().catchError((error) {});
      }
      if (remainingTime <= 5) {
        var tickPlayer = _tickPlayer;
        tickPlayer.setSource(AssetSource('assets/sounds/tick.mp3')).catchError((error) {});
        tickPlayer.resume().catchError((error) {});
      }
      setState(() {
        remainingTime--;
      });
    }
  });
}

  void stopTimer() {
    setState(() {
      isRunning = false;
      isSaved = false;
      currentExercise = 1;
      currentRound = 1;
      remainingTime = exerciseDuration;
      totalTime = exerciseDuration;
      isBreakTime = false;
      isRoundBreakTime = false;
    });
    timer?.cancel();
  }

  void pauseTimer() {
    setState(() {
      isRunning = false;
    });
    timer?.cancel();
  }

  void resetTimer() {
    setState(() {
      isRunning = false;
      isSaved = false;
      currentExercise = 1;
      currentRound = 1;
      remainingTime = exerciseDuration;
      totalTime = exerciseDuration;
      isBreakTime = false;
      isRoundBreakTime = false;
    });
    timer?.cancel();
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
    setState(() {
      savedModes.add(modeData);
      isSaved = true;
    });
    _saveModes();
  }

  void loadMode(Map<String, dynamic> modeData) {
    setState(() {
      totalExercises = modeData['totalExercises'];
      exerciseDuration = modeData['exerciseDuration'];
      exerciseBreak = modeData['exerciseBreak'];
      roundDuration = modeData['roundDuration'];
      roundBreak = modeData['roundBreak'];
      currentExercise = modeData['currentExercise'];
      currentRound = modeData['currentRound'];
      isRunning = false;
      remainingTime = exerciseDuration;
      totalTime = exerciseDuration;
      timer?.cancel();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    _tickPlayer.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return GestureDetector(
    onVerticalDragEnd: (details) {
  if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
    // Свайп вниз
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OneScreen(), // Замените на ваш предыдущий экран
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // Экран уходит вниз
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  } else if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
    // Свайп вверх
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OneScreen(), // Замените на ваш предыдущий экран
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0); // Экран уходит вверх
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Таймер',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const SizedBox(height: 140),
              Text(
                '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                style:
                    const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: isRunning ? pauseTimer : startTimer,
                    child: Icon(isRunning ? Icons.pause : Icons.play_arrow,
                        size: 40),
                  ),
                  if (isRunning) const SizedBox(width: 10),
                  if (isRunning)
                    GestureDetector(
                      onTap: stopTimer,
                      child: const Icon(Icons.stop, size: 40),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              _exerciseCard(context),
              if (isSaved)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child:
                      Text('Сохранено!', style: TextStyle(color: Colors.green)),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _exerciseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 180,
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow('Упражнения', '$currentExercise/$totalExercises', 18,
              Colors.blue),
          const SizedBox(height: 10),
          _buildRow('Круги', '$currentRound/$roundDuration', 18, Colors.blue),
          const SizedBox(height: 10),
          _progressBar(),
          const Spacer(),
          Row(
            children: [
              _actionButton('Режим', Icons.settings_input_svideo, () {
                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ModeScreen(
      savedModes: savedModes, // Передаем сохраненные режимы
      onModeSelected: loadMode, // Метод для загрузки выбранного режима
      onDeleteMode: (mode) {
        setState(() {
          savedModes.remove(mode); // Удаляем режим
        });
        _saveModes(); // Сохраняем изменения
      },
    ),
  ),
);
              }),
              const SizedBox(width: 10),
              _iconButton(Icons.bookmark_border, bookmarkMode),
              const SizedBox(width: 10),
              _iconButton(Icons.settings, () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()));
                _loadSettings();
              }),
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
                fontSize: fontSize, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _progressBar() {
    double progressFraction = isBreakTime
        ? 1 - (remainingTime / totalTime)
        : (totalTime - remainingTime) / totalTime;

    return Container(
      height: 20,
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
            width: (300 * progressFraction).clamp(0, 300),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}