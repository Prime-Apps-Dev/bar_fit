import 'dart:async';
import 'dart:convert';
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
  late Timer _tipUpdateTimer;
  Timer? _sessionTimer;
  Timer? _sharedTimerListener;
  Timer? _midnightTimer;
  int _goalMinutes = 30;
  String? _userName, _userLastName, _previousDate, _currentTip;
  int _currentSessionSeconds = 0;
  int _sharedTimerSeconds = 0;
  DateTime? _firstSessionDate;

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

  Map<String, int> _historyByDay = {};

  final PageController _pageController = PageController(initialPage: 1);
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startSharedTimerListener();
    _scheduleTipUpdate();
    _scheduleMidnightUpdate();
  }

 void _scheduleMidnightUpdate() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  final duration = tomorrow.difference(now);

  _midnightTimer?.cancel();
  _midnightTimer = Timer(duration, () async {
    _updateTodayHistory();
    await _resetCurrentSessionTime();
    setState(() {});
    _scheduleMidnightUpdate(); // Запланировать снова
  });
}


  @override
  void dispose() {
    _tipUpdateTimer.cancel();
    _sharedTimerListener?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
      _userLastName = prefs.getString('userLastName');
      _goalMinutes = prefs.getInt('goalMinutes') ?? 30;
      _previousDate = prefs.getString('previousDate');
      _currentTip = prefs.getString('currentTip') ?? _generateRandomTip();
      final firstDateStr = prefs.getString('firstSessionDate');
      if (firstDateStr != null) {
        _firstSessionDate = DateTime.tryParse(firstDateStr);
      }
    });
    if (_firstSessionDate == null) {
      final now = DateTime.now();
      _firstSessionDate = now;
      await prefs.setString('firstSessionDate', now.toIso8601String());
    }
    if (_userName == null || _userLastName == null) _showNameInputDialog();
    _loadCurrentSessionTime();
    _loadHistoryByDay();
  }

  Future<void> _loadCurrentSessionTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentSessionSeconds = prefs.getInt('currentSessionTime') ?? 0;
    });
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentSessionSeconds = (_currentSessionSeconds + 1);
      });
      await prefs.setInt('currentSessionTime', _currentSessionSeconds);
    });
  }

  void _scheduleTipUpdate() {
    final now = DateTime.now();
    final nextUpdate = DateTime(now.year, now.month, now.day + 2);
    final durationUntilNextUpdate = nextUpdate.difference(now);

    _tipUpdateTimer = Timer(durationUntilNextUpdate, () {
      setState(() {
        _currentTip = _generateRandomTip();
      });
      _saveCurrentTip();
      _scheduleTipUpdate();
    });
  }

  Future<void> _saveCurrentTip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentTip', _currentTip!);
    await prefs.setString('previousDate', DateTime.now().toIso8601String());
  }

  String _generateRandomTip() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }

  void _showNameInputDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Добро пожаловать!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Пожалуйста, введите ваше имя',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Ваше имя',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _saveUserName(nameController.text, '');
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Сохранить', style: TextStyle(fontSize: 16)),
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

  void _startSharedTimerListener() {
    _sharedTimerListener = Timer.periodic(const Duration(seconds: 1), (_) async {
      final prefs = await SharedPreferences.getInstance();
      final seconds = prefs.getInt('sharedTimer') ?? 0;
      if (seconds != _sharedTimerSeconds) {
        setState(() {
          _sharedTimerSeconds = seconds;
        });
      }
    });
  }

  Future<void> _resetCurrentSessionTime() async {
    _currentSessionSeconds = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sharedTimer', 0);
  }

  int get _daysSinceFirstSession {
    if (_firstSessionDate == null) return 0;
    return DateTime.now().difference(_firstSessionDate!).inDays + 1;
  }

  int get _weeksSinceFirstSession {
    if (_firstSessionDate == null) return 0;
    return ((DateTime.now().difference(_firstSessionDate!).inDays) / 7).ceil();
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      // Только секунды
      return '${seconds.toString().padLeft(2, '0')} сек';
    } else if (seconds < 3600) {
      // Минуты:Секунды
      final int minutes = seconds ~/ 60;
      final int remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      // Часы:Минуты:Секунды
      final int hours = seconds ~/ 3600;
      final int minutes = (seconds % 3600) ~/ 60;
      final int remainingSeconds = seconds % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatDayTime(int seconds) {
    if (seconds < 60) {
      return '$seconds сек';
    } else if (seconds < 3600) {
      final int minutes = seconds ~/ 60;
      return '$minutes мин';
    } else {
      final int hours = seconds ~/ 3600;
      final int minutes = (seconds % 3600) ~/ 60;
      return '$hours ч $minutes мин';
    }
  }

  Future<void> _loadHistoryByDay() async {
    final prefs = await SharedPreferences.getInstance();
    final mapString = prefs.getString('historyByDay');
    if (mapString != null) {
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(
        (mapString.isNotEmpty) ? Map<String, dynamic>.from(jsonDecode(mapString)) : {},
      );
      setState(() {
        _historyByDay = decoded.map((k, v) => MapEntry(k, v as int));
      });
    }
  }

  Future<void> _saveHistoryByDay() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('historyByDay', jsonEncode(_historyByDay));
  }

  void _updateTodayHistory() async {
    final now = DateTime.now();
    final key = "${now.year}-${now.month}-${now.day}";
    _historyByDay[key] = _sharedTimerSeconds;
    await _saveHistoryByDay();
  }

  String _normalizeDateKey(String key) {
  final parts = key.split('-');
  if (parts.length == 3) {
    final year = parts[0];
    final month = parts[1].padLeft(2, '0');
    final day = parts[2].padLeft(2, '0');
    return '$year-$month-$day';
  }
  return key;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // фон экрана теперь белый
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          ProfileScreen(),
          _buildMainContent(context),
          TwoScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        child: Container(
          height: 70,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
  onTap: () {
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 350), curve: Curves.ease);
  },
  child: Container(
    width: 55,
    height: 55,
    margin: const EdgeInsets.only(left: 7),
    decoration: BoxDecoration(
      color: Colors.blue,  // фон всегда синий
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.all(8),
    child: Icon(
      Icons.workspace_premium,
      color: Colors.white,  // иконка всегда белая
      size: 35,
    ),
  ),
),


              const Spacer(),
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(0, duration: const Duration(milliseconds: 350), curve: Curves.ease);
                },
                child: Icon(Icons.account_circle_outlined,
                    color: _currentPage == 0 ? Colors.blue : Colors.black, size: 35),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.ease);
                },
                child: Icon(Icons.home,
                    color: _currentPage == 1 ? Colors.blue : Colors.black, size: 35),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _pageController.animateToPage(2, duration: const Duration(milliseconds: 350), curve: Curves.ease);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: Icon(Icons.settings,
                      color: _currentPage == 2 ? Colors.blue : Colors.black, size: 35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'ПРИВЕТ, ${_userName?.toUpperCase() ?? 'ГОСТЬ'} ${_userLastName?.toUpperCase() ?? ''}.',
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 27,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 135,
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [ // добавлена тень
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
                          Text('Сегодня: ${_formatTime(_sharedTimerSeconds)}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                          
                          
                          
                          const SizedBox(height: 10),
// Вот этот блок добавляет историю по дням:
...(() {
  final now = DateTime.now();
  return _historyByDay.entries
      .toList()
      .reversed
      .take(7)
      .map((entry) {
    var tryParse = DateTime.tryParse(entry.key);
    final date = tryParse;
    String label;
    if (date != null &&
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Сегодня';
    } else if (date != null) {
      label = [
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
        'Воскресенье'
      ][date.weekday - 1];
    } else {
      label = entry.key;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '$label: ${_formatDayTime(entry.value)}',
        style: const TextStyle(
            fontSize: 13, color: Colors.black54),
      ),
    );
  }).toList();
})(),
                         ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 90, // например, 120 вместо 80
                              width: 90,  // например, 120 вместо 80
                              child: CircularProgressIndicator(
                                value: (_goalMinutes * 60) > 0
                                    ? (_sharedTimerSeconds / (_goalMinutes * 60)).clamp(0.0, 1.0)
                                    : 0,
                                backgroundColor: Colors.grey.shade300,
                                color: Colors.blue,
                                strokeWidth: 18, // толщина линии круга
                              ),
                            ),
                            Text(
                              _formatTime(_sharedTimerSeconds),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 135,
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [ // добавлена тень
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
                     Spacer(),
                    Container(
                      height: 100,
                      width: 100,
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
          // Контейнер для советов по тренировкам
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [ // добавлена тень
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
        ],
      ),
    );
  }

  // ...existing code...
}