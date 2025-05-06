import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'three_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController exerciseCountController = TextEditingController();
  final TextEditingController roundCountController = TextEditingController();
  int exerciseMinutes = 0,
      exerciseSeconds = 30,
      breakSeconds = 10,
      roundBreakMinutes = 0,
      roundBreakSeconds = 30;
  String selectedMelody = 'assets/sounds/002.mp3';
  final List<String> melodies = [
    'assets/sounds/002.mp3',
    'assets/sounds/006.mp3',
    'assets/sounds/007.mp3',
    'assets/sounds/008.mp3',
    'assets/sounds/009.mp3',
    'assets/sounds/010.mp3',
    'assets/sounds/011.mp3',
    'assets/sounds/012.mp3',
    'assets/sounds/013.mp3',
    'assets/sounds/014.mp3',
    'assets/sounds/015.mp3'
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      exerciseCountController.text =
          (prefs.getInt('exerciseCount') ?? 5).toString();
      roundCountController.text = (prefs.getInt('roundCount') ?? 5).toString();
      int exerciseDuration = prefs.getInt('exerciseDuration') ?? 30;
      exerciseMinutes = exerciseDuration ~/ 60;
      exerciseSeconds = exerciseDuration % 60;
      breakSeconds = prefs.getInt('exerciseBreak') ?? 10;
      int roundBreak = prefs.getInt('roundBreak') ?? 30;
      roundBreakMinutes = roundBreak ~/ 60;
      roundBreakSeconds = roundBreak % 60;
      selectedMelody =
          prefs.getString('selectedMelody') ?? 'assets/sounds/002.mp3';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'exerciseCount', int.parse(exerciseCountController.text));
    await prefs.setInt(
        'exerciseDuration', exerciseMinutes * 60 + exerciseSeconds);
    await prefs.setInt('exerciseBreak', breakSeconds);
    await prefs.setInt('roundCount', int.parse(roundCountController.text));
    await prefs.setInt(
        'roundBreak', roundBreakMinutes * 60 + roundBreakSeconds);
    await prefs.setString('selectedMelody', selectedMelody);
  }

  void _showPicker(BuildContext context, String title, List<int> initialValues,
      Function(List<int>) onConfirm) {
    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
            begin: 0,
            end: 59,
            initValue: initialValues[0],
            suffix: Text(' мин')),
        NumberPickerColumn(
            begin: 0,
            end: 59,
            initValue: initialValues[1],
            suffix: Text(' сек')),
      ]),
      delimiter: [
        PickerDelimiter(
            child: Container(
                width: 30.0,
                height: 150,
                alignment: Alignment.center,
                child: Text(':'))),
      ],
      hideHeader: false,
      title: Text(title),
      selectedTextStyle:
          TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      confirmText: 'Выбрать',
      confirmTextStyle:
          TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      cancelText: 'Отмена',
      cancelTextStyle:
          TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      onConfirm: (Picker picker, List value) {
        onConfirm(value.cast<int>());
      },
    ).showModal(context);
  }

  void _showExerciseBreakPicker(BuildContext context, String title,
      int initialValue, Function(int) onConfirm) {
    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
            begin: 3, end: 10, initValue: initialValue, suffix: Text(' сек')),
      ]),
      hideHeader: false,
      title: Text(title),
      selectedTextStyle:
          TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      confirmText: 'Выбрать',
      confirmTextStyle:
          TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      cancelText: 'Отмена',
      cancelTextStyle:
          TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      onConfirm: (Picker picker, List value) {
        onConfirm(value[0] as int);
      },
    ).showModal(context);
  }

  void _showRoundBreakPicker(BuildContext context, String title,
      List<int> initialValues, Function(List<int>) onConfirm) {
    Picker(
      adapter: NumberPickerAdapter(data: [
        NumberPickerColumn(
            begin: 0,
            end: 2,
            initValue: initialValues[0],
            suffix: Text(' мин')),
        NumberPickerColumn(
            begin: 0,
            end: 59,
            initValue: initialValues[1],
            suffix: Text(' сек')),
      ]),
      delimiter: [
        PickerDelimiter(
            child: Container(
                width: 30.0,
                height: 150,
                alignment: Alignment.center,
                child: Text(':'))),
      ],
      hideHeader: false,
      title: Text(title),
      selectedTextStyle:
          TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      confirmText: 'Выбрать',
      confirmTextStyle:
          TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      cancelText: 'Отмена',
      cancelTextStyle:
          TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      onConfirm: (Picker picker, List value) {
        onConfirm(value.cast<int>());
      },
    ).showModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text('Настройки Режима',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
              const SizedBox(height: 20),
              _buildSettingsCard(
                  Icons.emoji_events_outlined, 'Режим победителя', true),
              const SizedBox(height: 20),
              _buildRoundSettingsCard(),
              const SizedBox(height: 20),
              _buildExerciseSettingsCard(),
              const SizedBox(height: 20),
              _buildMusicSettingsCard(),
              const SizedBox(height: 30),
              _buildActionButton('Сохранить', () async {
                await _saveSettings();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ThreeScreen()));
              }),
              const SizedBox(height: 10),
              _buildActionButton('Отменить', () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ThreeScreen()));
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(IconData icon, String title, bool isMain,
      [TextEditingController? controller]) {
    return Container(
      height: 70,
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(icon, size: 30, color: Colors.black),
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          if (isMain)
            Row(
              children: [
                IconButton(
                    icon: Icon(Icons.star, size: 30, color: Colors.blue),
                    onPressed: _saveSettings),
                IconButton(
                    icon: Icon(Icons.bookmark, size: 30, color: Colors.blue),
                    onPressed: _saveSettings),
              ],
            )
          else
            IconButton(
              icon: Padding(
                padding: const EdgeInsets.only(left: 150),
                child: Icon(Icons.edit, size: 30, color: Colors.blue),
              ),
              onPressed: () => _showEditBottomSheet(
                context,
                title,
                [controller!],
                ['Введите количество $title'.toLowerCase()],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoundSettingsCard() {
    return Container(
      height: 90,
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsHeader(Icons.timer_outlined, 'Круги',
              roundCountController, 'Введите количество кругов'),
          _buildRoundBreakPickerRow(
              'Перерыв:', roundBreakMinutes, roundBreakSeconds,
              (values) {
            setState(() {
              roundBreakMinutes = values[0];
              roundBreakSeconds = values[1];
            });
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseSettingsCard() {
    return Container(
      height: 130,
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsHeader(Icons.timer_outlined, 'Упражнения',
              exerciseCountController, 'Введите количество упражнений'),
          _buildPickerRow('Длительность:', exerciseMinutes, exerciseSeconds,
              (values) {
            setState(() {
              exerciseMinutes = values[0];
              exerciseSeconds = values[1];
            });
          }),
          const SizedBox(height: 10),
          _buildExerciseBreakPickerRow('Перерыв:', breakSeconds, (value) {
            setState(() {
              breakSeconds = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildMusicSettingsCard() {
    return GestureDetector(
      onTap: () => _showBottomSheet(context, 'Мелодия'),
      child: Container(
        height: 70,
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.music_note, size: 30, color: Colors.blue),
            Text('Мелодия',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const Padding(
              padding: EdgeInsets.only(left: 150),
              child: Icon(Icons.edit, size: 30, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsHeader(IconData icon, String title,
      TextEditingController controller, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
          ],
        ),
        IconButton(
          icon: Icon(Icons.edit, size: 30, color: Colors.blue),
          onPressed: () =>
              _showEditBottomSheet(context, title, [controller], [label]),
        ),
      ],
    );
  }

  Widget _buildPickerRow(
      String text, int minutes, int seconds, Function(List<int>) onConfirm) {
    return GestureDetector(
      onTap: () => _showPicker(context, text, [minutes, seconds], onConfirm),
      child: _buildInfoRow(Icons.timer, text, '$minutes мин $seconds сек'),
    );
  }

  Widget _buildExerciseBreakPickerRow(
      String text, int seconds, Function(int) onConfirm) {
    return GestureDetector(
      onTap: () => _showExerciseBreakPicker(context, text, seconds, onConfirm),
      child: _buildInfoRow(Icons.timer, text, '$seconds сек'),
    );
  }

  Widget _buildRoundBreakPickerRow(
      String text, int minutes, int seconds, Function(List<int>) onConfirm) {
    return GestureDetector(
      onTap: () =>
          _showRoundBreakPicker(context, text, [minutes, seconds], onConfirm),
      child: _buildInfoRow(Icons.timer, text, '$minutes мин $seconds сек'),
    );
  }

  Widget _buildInfoRow(IconData icon, String leftText, String rightText) {
    return Container(
      height: 30,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(icon, color: Colors.blue)),
          const SizedBox(width: 5),
          Text(leftText, style: const TextStyle(color: Colors.black)),
          const Spacer(),
          Text(rightText, style: const TextStyle(color: Colors.black)),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 320,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white)),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, String title,
      List<TextEditingController> controllers, List<String> labels) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  for (int i = 0; i < controllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextField(
                        controller: controllers[i],
                        decoration: InputDecoration(labelText: labels[i]),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  _buildBottomSheetActionButtons(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15)),
            onPressed: () async {
              await _saveSettings();
              Navigator.of(context).pop();
            },
            child: const Text("Сохранить",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Отмена",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, String title) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 450,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: melodies.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      await _audioPlayer.setSource(AssetSource(melodies[index]));
                      await _audioPlayer.resume();
                      setState(() {
                        selectedMelody = melodies[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.music_note,
                              size: 30, color: Colors.blue),
                          Text('Мелодия ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          Icon(Icons.check,
                              size: 30,
                              color: selectedMelody == melodies[index]
                                  ? Colors.green
                                  : Colors.transparent),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
}
