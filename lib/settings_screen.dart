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
  int roundMinutes = 8;
  int roundBreakMinutes = 2;
  int roundBreakSeconds = 0;
  int exerciseMinutes = 0;
  int exerciseSeconds = 30;
  int breakSeconds = 3;
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
  
  void _playMelody(String path) async {
  try {
    await _audioPlayer.stop(); // остановить предыдущую мелодию
    await _audioPlayer.setSource(AssetSource(path));
    await _audioPlayer.resume();
  } catch (e) {
    print('Ошибка воспроизведения звука: $e');
  }
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

  void _showCustomDurationPicker(BuildContext context, String title,
      int initialMinutes, int initialSeconds, Function(int, int) onConfirm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        int selectedMinutes = initialMinutes;
        int selectedSeconds = initialSeconds;

        return Container(
          height: 380,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Текст "МИН"
                    const Text(
                      'МИН',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Рулетка для минут
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 60,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          selectedMinutes = index;
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                          childCount: 60,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Рулетка для секунд
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 60,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          selectedSeconds = index;
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                          childCount: 60,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Текст "СЕК"
                    const Text(
                      'СЕК',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Кнопки по вертикали, обе синие
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onConfirm(selectedMinutes, selectedSeconds);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Сохранить', style: TextStyle(color: Colors.white),), 
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Отменить', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBottomSheet(BuildContext context, String title,
      List<TextEditingController> controllers, List<String> labels) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              minHeight: 0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Контейнер для ввода количества упражнений или кругов
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: controllers[0],
                            decoration: InputDecoration(
                              labelText: labels[0],
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Длительность
                  GestureDetector(
                    onTap: () => _showCustomDurationPicker(
                      context,
                      'Длительность',
                      exerciseMinutes,
                      exerciseSeconds,
                      (minutes, seconds) {
                        setState(() {
                          exerciseMinutes = minutes;
                          exerciseSeconds = seconds;
                        });
                      },
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.timer, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                'Длительность',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$exerciseMinutes мин $exerciseSeconds сек',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Длительность перерыва
                  GestureDetector(
                    onTap: () => _showCustomDurationPicker(
                      context,
                      'Перерыв',
                      roundBreakMinutes,
                      roundBreakSeconds,
                      (minutes, seconds) {
                        setState(() {
                          roundBreakMinutes = minutes;
                          roundBreakSeconds = seconds;
                        });
                      },
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pause_circle_filled, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                'Перерыв',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$roundBreakMinutes мин $roundBreakSeconds сек',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Кнопки по вертикали, обе синие
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Сохранить', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Отменить', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth > 500 ? 440 : screenWidth * 0.97;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // Добавили отступы
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Все ваши карточки идут тут, теперь с отступами слева и справа
                Container(
                  width: cardWidth,
                  constraints: const BoxConstraints(minHeight: 80), // минимальная высота
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24), // увеличили padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // чуть больше скругление
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 32, color: Colors.black),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text('Режим победителя',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.star, color: Colors.blue, size: 30),
                        onPressed: _saveSettings,
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: Colors.blue, size: 30),
                        onPressed: _saveSettings,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Круги
                Container(
                  width: cardWidth,
                  constraints: const BoxConstraints(minHeight: 110),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle_outlined, color: Colors.blue, size: 28),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Круги',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _showEditBottomSheet(
                          context,
                          'Настройки круга',
                          [roundCountController],
                          ['Введите количество кругов'],
                        ),
                        child: Column(
                          children: [
                            buildEditCard(
                              Icons.timer,
                              'Длительность',
                              '$exerciseMinutes мин $exerciseSeconds сек',
                              () => _showEditBottomSheet(
                                context,
                                'Настройки круга',
                                [roundCountController],
                                ['Введите количество кругов'],
                              ),
                            ),
                            const SizedBox(height: 6),
                            buildEditCard(
                              Icons.pause_circle,
                              'Перерыв',
                              '$roundBreakMinutes мин $roundBreakSeconds сек',
                              () => _showEditBottomSheet(
                                context,
                                'Настройки круга',
                                [roundCountController],
                                ['Введите количество кругов'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Упражнения
                Container(
                  width: cardWidth,
                  constraints: const BoxConstraints(minHeight: 110),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle_outlined, color: Colors.blue, size: 28),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Упражнения',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _showEditBottomSheet(
                          context,
                          'Настройки упражнения',
                          [exerciseCountController],
                          ['Введите количество упражнений'],
                        ),
                        child: Column(
                          children: [
                            buildEditCard(
                              Icons.timer,
                              'Длительность',
                              '$exerciseMinutes мин $exerciseSeconds сек',
                              () => _showEditBottomSheet(
                                context,
                                'Настройки упражнения',
                                [exerciseCountController],
                                ['Введите количество упражнений'],
                              ),
                            ),
                            const SizedBox(height: 6),
                            buildEditCard(
                              Icons.pause,
                              'Перерыв',
                              '$breakSeconds сек',
                              () => _showEditBottomSheet(
                                context,
                                'Настройки упражнения',
                                [exerciseCountController],
                                ['Введите количество упражнений'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Музыка
                GestureDetector(
                  onTap: () => _showBottomSheet(context, 'Мелодия'),
                  child: Container(
                    width: cardWidth,
                    constraints: const BoxConstraints(minHeight: 80),
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.blue, size: 28),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Мелодия',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black)),
                        ),
                        const Icon(Icons.edit, color: Colors.blue, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
             
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveSettings();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => ThreeScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Отмена
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Отменить', style: TextStyle(color: Colors.white)),
                ),
              ),
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
          _buildSettingsHeader(Icons.timer_outlined, 'Круги',
              roundCountController, 'Введите количество кругов'),
          // Теперь вся настройка круга по нажатию на любую строку
          GestureDetector(
            onTap: () => _showEditBottomSheet(
              context,
              'Настройки круга',
              [roundCountController],
              ['Введите количество кругов'],
            ),
            child: Column(
              children: [
                _buildPickerContainer(
                  'Длительность круга',
                  '$exerciseMinutes мин $exerciseSeconds сек',
                ),
                const SizedBox(height: 10),
                _buildPickerContainer(
                  'Перерыв',
                  '$roundBreakMinutes мин $roundBreakSeconds сек',
                ),
              ],
            ),
          ),
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
          // Теперь вся настройка упражнения по нажатию на любую строку
          GestureDetector(
            onTap: () => _showEditBottomSheet(
              context,
              'Настройки упражнения',
              [exerciseCountController],
              ['Введите количество упражнений'],
            ),
            child: Column(
              children: [
                _buildPickerContainer(
                  'Длительность',
                  '$exerciseMinutes мин $exerciseSeconds сек',
                ),
                const SizedBox(height: 10),
                _buildPickerContainer(
                  'Перерыв',
                  '$breakSeconds сек',
                ),
              ],
            ),
          ),
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
      mainAxisAlignment: MainAxisAlignment.start,
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
    );
  }

  Widget _buildPickerRow(
      String text, int minutes, int seconds, Function(List<int>) onConfirm) {
    return GestureDetector(
      onTap: () => _showCustomDurationPicker(
          context, text, minutes, seconds, (min, sec) => onConfirm([min, sec])),
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
                      try {
                        // Остановить предыдущий звук
                        await _audioPlayer.stop();
                        // Установить новый источник
                        await _audioPlayer.setSource(
                          AssetSource(melodies[index]),
                        );
                        // Запустить воспроизведение
                        await _audioPlayer.resume();

                        setState(() {
                          selectedMelody = melodies[index];
                        });

                        // Закрыть BottomSheet, если хочешь
                        // Navigator.pop(context);
                      } catch (e) {
                        print('Ошибка воспроизведения звука: $e');
                      }
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
                          const Icon(Icons.music_note,
                              size: 30, color: Colors.blue),
                          Text(
                            'Мелодия ${index + 1}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
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

  Widget _buildPickerContainer(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditCard(IconData icon, String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Добавлен новый метод для сборки карточки настроек с возможностью редактирования
  Widget _buildEditableSettingsCard(IconData icon, String title, String value, VoidCallback onEditTap) {
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
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.edit, size: 20, color: Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
