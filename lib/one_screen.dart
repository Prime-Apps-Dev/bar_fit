import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen.dart';
import 'three_screen.dart';
import 'two_screen.dart';

void main() {
  runApp(MaterialApp(home: OneScreen()));
}

class OneScreen extends StatefulWidget {
  const OneScreen({super.key});

  @override
  _OneScreenState createState() => _OneScreenState();
}

class _OneScreenState extends State<OneScreen> {
  late Timer _timer;
  int _secondsSpent = 0, _goalMinutes = 30;
  String? _userName, _userLastName, _previousDate, _currentTip;

  final List<String> _tips = [
    'Разогревайся перед каждой тренировкой.',
    'Делай заминку после тренировки.',
    'Работай с прогрессивной нагрузкой.',
    'Следи за техникой выполнения упражнений.',
    'Не забывай про растяжку.',
    'Не пропускай тренировки.',
    'Следи за дыханием во время упражнений.',
    'Комбинируй силовые и кардио нагрузки.',
    'Тренируй мышцы антагонисты (бицепс/трицепс, грудь/спина).',
    'Работай с разными диапазонами повторений.',
    'Используй суперсеты для повышения интенсивности.',
    'Добавляй дроп-сеты для шокирования мышц.',
    'Меняй программу раз в 6-8 недель.',
    'Используй периодизацию нагрузок.',
    'Работай над мобильностью суставов.',
    'Не тренируйся до изнеможения каждый день.',
    'Увеличивай нагрузку постепенно.',
    'Уделяй внимание технике, а не весу.',
    'Тренируй все группы мышц равномерно.',
    'Работай над осанкой.',
    'Спи не менее 7-9 часов в день.',
    'Давай мышцам отдых после тяжелых тренировок.',
    'Используй массажный ролик для восстановления.',
    'Делай контрастный душ после тренировок.',
    'Уменьши уровень стресса.',
    'Следи за уровнем витаминов и минералов.',
    'Пей достаточно воды.',
    'Избегай обезвоживания.',
    'Следи за уровнем железа, особенно если чувствуешь усталость.',
    'Дыши глубже во время тренировок и в повседневной жизни.',
    'Следи за уровнем кортизола.',
    'Избегай частых ночных перекусов.',
    'Давай отдых не только телу, но и нервной системе.',
    'Избегай чрезмерного употребления алкоголя.',
    'Уменьши потребление сахара.',
    'Проверяй уровень гормонов при длительном упадке сил.',
    'Делай перерывы в тренировках при болезни.',
    'Не злоупотребляй стимуляторами перед тренировками.',
    'Уменьши употребление кофеина, если нарушен сон.',
    'Избегай долгого сидячего положения.',
    'Ешь больше белка для роста мышц.',
    'Потребляй сложные углеводы перед тренировкой.',
    'Употребляй полезные жиры для гормонального здоровья.',
    'Увеличивай количество овощей в рационе.',
    'Следи за количеством клетчатки.',
    'Ешь больше цельных продуктов.',
    'Следи за балансом БЖУ.',
    'Избегай переедания.',
    'Не злоупотребляй фастфудом.',
    'Следи за уровнем сахара в крови.',
    'Ешь медленно, чтобы избежать переедания.',
    'Используй пищевой дневник для контроля рациона.',
    'Ешь больше рыбы для здоровья сердца.',
    'Пей больше воды вместо сладких напитков.',
    'Завтракай правильно: белки + полезные жиры.',
    'Готовь еду заранее, чтобы не срываться на вредную пищу.',
    'Ешь после тренировки для восстановления мышц.',
    'Контролируй потребление соли.',
    'Питайся разнообразно.',
    'Не исключай углеводы полностью.',
    'Добавь кардио для укрепления сердца.',
    'Меняй интенсивность кардио для лучшего эффекта.',
    'Делай кардио натощак, если цель – жиросжигание.',
    'Используй интервальные тренировки.',
    'Не забывай про плавание для щадящей нагрузки.',
    'Не делай слишком много кардио, если цель – набор массы.',
    'Используй ходьбу как дополнительное кардио.',
    'Включай беговые тренировки раз в неделю.',
    'Добавляй спринты для ускорения метаболизма.',
    'Кардио можно заменять активными играми.',
    'Развивай гибкость для лучшего прогресса в силовых.',
    'Используй статическую и динамическую растяжку.',
    'Делай упражнения на баланс.',
    'Используй йогу или пилатес для восстановления.',
    'Работай над подвижностью суставов.',
    'Уделяй внимание стопам и их укреплению.',
    'Развивай чувство тела в пространстве.',
    'Не игнорируй растяжку спины.',
    'Работай над координацией движений.',
    'Делай упражнения босиком для укрепления стоп.',
    'Ставь четкие цели в тренировках.',
    'Не сравнивай себя с другими.',
    'Записывай прогресс.',
    'Найди приятную музыку для тренировок.',
    'Делай фото до/после для мотивации.',
    'Следи за своими успехами, а не чужими.',
    'Тренируйся для себя, а не ради чужого мнения.',
    'Найди партнера для тренировок.',
    'Пробуй новые виды спорта.',
    'Чередуй тренировки, чтобы избежать скуки.',
    'Не зацикливайся на весах, следи за объемами.',
    'Добавляй активность в повседневную жизнь.',
    'Используй лестницы вместо лифта.',
    'Не пропускай разминку, даже если мало времени.',
    'Меняй программы тренировок каждые 2-3 месяца.',
    'Дыши правильно во время упражнений.',
    'Прислушивайся к своему телу.',
    'Умей отдыхать без чувства вины.',
    'Следи за осанкой не только в зале, но и в жизни.',
    'Получай удовольствие от тренировок!',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();
    _scheduleTipUpdate();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
      _userLastName = prefs.getString('userLastName');
      _secondsSpent = prefs.getInt('totalTime') ?? 0;
      _goalMinutes = prefs.getInt('goalMinutes') ?? 30;
      _previousDate = prefs.getString('previousDate');
      _currentTip = prefs.getString('currentTip') ?? _generateRandomTip();
      if (_shouldUpdateTip()) {
        _currentTip = _generateRandomTip();
        prefs.setString('currentTip', _currentTip!);
        prefs.setString('previousDate', DateTime.now().toIso8601String());
      }
    });
    if (_userName == null || _userLastName == null) _showNameInputDialog();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalTime', _secondsSpent);
    await prefs.setString('previousDate', DateTime.now().toIso8601String());
    await prefs.setString('currentTip', _currentTip!);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsSpent++);
      _saveData();
    });
  }

  void _scheduleTipUpdate() {
    final now = DateTime.now();
    final nextUpdate = DateTime(now.year, now.month, now.day + 2);
    final durationUntilNextUpdate = nextUpdate.difference(now);

    Timer(durationUntilNextUpdate, () {
      setState(() {
        _currentTip = _generateRandomTip();
      });
      _saveData();
      _scheduleTipUpdate(); // Рекурсивно планируем следующий запуск
    });
  }

  bool _shouldUpdateTip() {
    if (_previousDate == null) return true;
    final previousDateTime = DateTime.parse(_previousDate!);
    final now = DateTime.now();
    return now.difference(previousDateTime).inDays >= 2;
  }

  String _generateRandomTip() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }

  void _showNameInputDialog() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Введите ваше имя и фамилию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: firstNameController,
                decoration: const InputDecoration(hintText: 'Ваше имя')),
            TextField(
                controller: lastNameController,
                decoration: const InputDecoration(hintText: 'Ваша фамилия'))
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (firstNameController.text.isNotEmpty &&
                  lastNameController.text.isNotEmpty) {
                _saveUserName(
                    firstNameController.text, lastNameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserName(String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', firstName);
    await prefs.setString('userLastName', lastName);
    setState(() {
      _userName = firstName;
      _userLastName = lastName;
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ПРИВЕТ, ${_userName?.toUpperCase() ?? 'ГОСТЬ'} ${_userLastName?.toUpperCase() ?? ''}.',
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 27,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text('ГОТОВ К НОВОЙ',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const Text('ТРЕНИРОВКЕ?',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen())),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Сегодня',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text('Сегодня: ${_formatTime(_secondsSpent)}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: CircularProgressIndicator(
                                value: _secondsSpent / (_goalMinutes * 60),
                                backgroundColor: Colors.grey.shade300,
                                color: Colors.blue,
                                strokeWidth: 20,
                              ),
                            ),
                            Text(_formatTime(_secondsSpent),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ThreeScreen())),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Таймер',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        height: 100,
                        width: 90,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined,
                                size: 40, color: Colors.white),
                            Text('Режим',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text('победителя',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Новый контейнер для советов по тренировкам
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Container(
                height: 80,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb, color: Colors.blue, size: 30),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentTip ?? 'Загрузка совета...',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(left: 10),
                        child: const Icon(Icons.workspace_premium,
                            color: Colors.white, size: 35),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen())),
                      child: const Icon(Icons.account_circle_outlined,
                          color: Colors.blue, size: 35),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OneScreen())),
                      child:
                      const Icon(Icons.home, color: Colors.black, size: 35),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TwoScreen())),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.settings,
                            color: Colors.black, size: 35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}