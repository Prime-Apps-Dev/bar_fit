import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'one_screen.dart';
import 'three_screen.dart';
import 'two_screen.dart';

void main() {
  runApp(MaterialApp(home: OneScreen()));
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Timer? _timer;
  String? _userName, _userLastName, _profileImagePath;
  bool _isLoading = true;
  int _secondsSpent = 0, _goalMinutes = 30;
  List<int> _dailyTimes = List.generate(7, (_) => 0);
  int _currentDay = DateTime.now().weekday;
  DateTime _selectedDate = DateTime.now();
  static const int maxTime = 3 * 3600;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _startTimer();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    final int today = now.weekday;

    setState(() {
      _userName = prefs.getString('userName') ?? 'Guest';
      _userLastName = prefs.getString('userLastName') ?? '';
      _secondsSpent = prefs.getInt('totalTime') ?? 0;
      _goalMinutes = prefs.getInt('goalMinutes') ?? 30;
      _dailyTimes = (prefs.getStringList('dailyTimes')?.map(int.parse).toList() ?? List.generate(7, (_) => 0));
      _currentDay = prefs.getInt('currentDay') ?? today;
      _selectedDate = prefs.getString('selectedDate') != null ? DateTime.parse(prefs.getString('selectedDate')!) : now;
      _profileImagePath = prefs.getString('profileImagePath');

      if (_currentDay != today) {
        _saveWeeklyStats();
        _resetWeeklyStats();
        _currentDay = today;
        _secondsSpent = 0;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName!);
    await prefs.setString('userLastName', _userLastName!);
    await prefs.setInt('totalTime', _secondsSpent);
    await prefs.setInt('goalMinutes', _goalMinutes);
    await prefs.setStringList('dailyTimes', _dailyTimes.map((e) => e.toString()).toList());
    await prefs.setInt('currentDay', _currentDay);
    await prefs.setString('selectedDate', _selectedDate.toIso8601String());
    await prefs.setString('profileImagePath', _profileImagePath ?? '');
  }

  Future<void> _saveWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String weekKey = 'week_${_selectedDate.year}_${_selectedDate.month}_${_selectedDate.day}';
    await prefs.setStringList(weekKey, _dailyTimes.map((e) => e.toString()).toList());
  }

  void _resetWeeklyStats() {
    setState(() {
      _dailyTimes = List.generate(7, (_) => 0);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final int today = DateTime.now().weekday;
      
      setState(() {
        if (_currentDay != today) {
          _saveWeeklyStats();
          _resetWeeklyStats();
          _currentDay = today;
          _secondsSpent = 0;
        }
        if (_secondsSpent < maxTime) {
          _secondsSpent += 1;
          _dailyTimes[_currentDay - 1] = _secondsSpent;
        }
      });
      _saveProfileData();
    });
  } 

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
      _saveProfileData();
    }
  }

  void _editUserName() async {
    final newName = await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        final controllerFirstName = TextEditingController(text: _userName);
        final controllerLastName = TextEditingController(text: _userLastName);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Изменить имя и фамилию', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(controller: controllerFirstName, decoration: const InputDecoration(labelText: 'Имя пользователя')),
              TextField(controller: controllerLastName, decoration: const InputDecoration(labelText: 'Фамилия пользователя')),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 370,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'firstName': controllerFirstName.text,
                          'lastName': controllerLastName.text
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Сохранить', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 370,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Отмена', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200, color: Colors.white)),
                    ),
                  ),
                  Container(child: const SizedBox(height: 30))
                ],
              )
            ],
          ),
        );
      },
    );

    if (newName != null && newName['firstName']!.isNotEmpty && newName['lastName']!.isNotEmpty) {
      setState(() {
        _userName = newName['firstName'];
        _userLastName = newName['lastName'];
      });
      _saveProfileData();
    }
  }

  void _setGoalTime() async {
    int selectedMinutes = _goalMinutes;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 390,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline_rounded, size: 40),
                  const Text('Изменить цель', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Сколько минут в день вы готовы уделить тренировке?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 118,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(initialItem: selectedMinutes),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedMinutes = index;
                    });
                  },
                  children: List<Widget>.generate(181, (int index) {
                    return Center(child: Text('$index мин'));
                  }),
                ),
              ),
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _goalMinutes = selectedMinutes;
                    });
                    _saveProfileData();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Сохранить', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Отменить', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30)
            ],
          ),
        );
      },
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _saveProfileData();
    }
  }

 @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OneScreen()));
          } else if (details.primaryVelocity! > 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OneScreen()));
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OneScreen()));
          } else if (details.primaryVelocity! > 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OneScreen()));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 15),
              _buildStatisticsContainer(),
              const SizedBox(height: 10),
              _buildDefaultModes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue,
                  backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                  child: _profileImagePath == null
                      ? const Icon(Icons.account_circle_outlined, size: 90, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: InkWell(
                onTap: _editUserName,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Привет, $_userName $_userLastName',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.edit, color: Colors.blue, size: 30),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          width: 325,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timelapse, size: 40, color: Colors.blue),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                            'Моя цель',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text('$_goalMinutes минут', style: const TextStyle(fontSize: 14, color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _setGoalTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white54,
                    fixedSize: const Size(90, 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Задать', style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsContainer() {
    return Center(
      child: Container(
        width: 325,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatistics(),
            const SizedBox(height: 5),
            _buildDateRange(),
            const SizedBox(height: 5),
            _buildDailyStats(),
            const SizedBox(height: 10),
            _buildDayLabels(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        const Text('Статистика', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Spacer(),
        Text(_formatTime(_secondsSpent), style: const TextStyle(color: Colors.blue, fontSize: 12)),
      ],
    );
  }

  Widget _buildDateRange() {
    final String currentDate =
        "${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}";
    return Row(
      children: [
        GestureDetector(
          onTap: _selectDate,
          child: const Icon(Icons.calendar_today_outlined, size: 25, color: Colors.blue),
        ),
        const SizedBox(width: 5),
        Text(currentDate, style: const TextStyle(color: Colors.blue, fontSize: 14)),
      ],
    );
  }

  Widget _buildDailyStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        return _buildStatContainer(
          _formatTime(_dailyTimes[index]),
          index == (_currentDay - 1) ? Colors.blue : Colors.grey,
          _dailyTimes[index] / maxTime,
        );
      }),
    );
  }

  Widget _buildDayLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Text('Пн'),
        Text('Вт'),
        Text('Ср'),
        Text('Чт'),
        Text('Пт'),
        Text('Сб'),
        Text('Вс'),
      ],
    );
  }

  Widget _buildStatContainer(String text, Color color, double fillPercentage) {
    return Expanded(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            height: 80 * fillPercentage,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultModes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [SizedBox(height: 25),
         Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Режим по умолчанию', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: SizedBox(
            height: 120,
            width: 320,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => ThreeScreen()));               },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, size: 50, color: Colors.white),
                        const SizedBox(height: 5),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                          child: Text(
                            'Стандартный режим',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildModeContainer(
                    title: 'Название режима 1',
                    icon: Icons.flash_on,
                    color: Colors.black),
                const SizedBox(width: 10),
                _buildModeContainer(
                    title: 'Название режима 2',
                    icon: Icons.fitness_center,
                    color: Colors.black),
              ],
            ),
          ),
        ),
        const SizedBox(height: 60),
       
      ],
    );
  }

  Widget _buildModeContainer({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OneScreen()),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')} ч ${minutes.toString().padLeft(2, '0')} мин ${seconds.toString().padLeft(2, '0')} сек';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Route _createRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProfileScreen(),
    );
  }
}