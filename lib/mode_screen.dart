import 'package:flutter/material.dart';

class ModeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> savedModes;
  final void Function(Map<String, dynamic>) onModeSelected;
  final void Function(Map<String, dynamic>) onDeleteMode;

  const ModeScreen({
    Key? key,
    required this.savedModes,
    required this.onModeSelected,
    required this.onDeleteMode,
  }) : super(key: key);

  @override
  _ModeScreenState createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  Map<String, dynamic>? selectedMode;

  Widget _buildContainer({
    required Color color,
    required IconData icon1,
    required IconData icon2,
    required IconData icon3,
    required String title,
    required int rounds,
    required int exerciseCount,
    required int exerciseTime,
    required int restTime,
  }) {
    return Container(
      height: 100,
      width: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Тень
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon1,
                    color: color == Colors.blue ? Colors.white : Colors.black),
                Icon(icon2,
                    color: color == Colors.blue ? Colors.white : Colors.black),
                Icon(icon3,
                    color: color == Colors.blue ? Colors.white : Colors.black),
              ],
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color == Colors.blue ? Colors.white : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.repeat,
                    color: color == Colors.blue ? Colors.white : Colors.black),
                const SizedBox(width: 5),
                Text(
                  '$rounds', // Отображение количества раундов
                  style: TextStyle(
                    fontSize: 14,
                    color: color == Colors.blue ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.fitness_center,
                    color: color == Colors.blue ? Colors.white : Colors.black),
                const SizedBox(width: 5),
                Text(
                  '$exerciseCount', // Отображение количества упражнений
                  style: TextStyle(
                    fontSize: 14,
                    color: color == Colors.blue ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.timer,
                    color: color == Colors.blue ? Colors.white : Colors.black),
                const SizedBox(width: 5),
                Text(
                  '$exerciseTime сек', // Отображение времени упражнения
                  style: TextStyle(
                    fontSize: 14,
                    color: color == Colors.blue ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.timer_off,
                    color: color == Colors.blue ? Colors.white : Colors.black),
                const SizedBox(width: 5),
                Text(
                  '$restTime сек', // Отображение времени отдыха
                  style: TextStyle(
                    fontSize: 14,
                    color: color == Colors.blue ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editModeName(Map<String, dynamic> mode) async {
    TextEditingController controller =
        TextEditingController(text: mode['mode']);
    String? newName = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить название режима'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Сохранить'),
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
        ],
      ),
    );
    if (newName != null) {
      setState(() {
        mode['mode'] = newName;
      });
    }
  }

  void _deleteMode(Map<String, dynamic> mode) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить режим'),
        content: const Text('Вы уверены, что хотите удалить этот режим?'),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Удалить'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        widget.savedModes.remove(mode);
      });
      widget.onDeleteMode(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор режима')),
      body: widget.savedModes.isEmpty
          ? const Center(child: Text('Нет сохранённых режимов'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: widget.savedModes.length,
              itemBuilder: (context, index) {
                final mode = widget.savedModes[index];
                final isSelected = mode == selectedMode;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMode = isSelected ? null : mode;
                    });
                    widget.onModeSelected(mode);
                  },
                  onLongPress: () {
                    _editModeName(mode);
                  },
                  onDoubleTap: () {
                    _deleteMode(mode);
                  },
                  child: _buildContainer(
                    color: isSelected ? Colors.blue : Colors.white,
                    icon1: Icons.fitness_center,
                    icon2: Icons.bookmark_add,
                    icon3: Icons.star_outline,
                    title: mode['mode'],
                    rounds: mode['roundDuration'] ?? 0,
                    exerciseCount: mode['totalExercises'] ?? 0,
                    exerciseTime: mode['exerciseDuration'] ?? 0,
                    restTime: mode['exerciseBreak'] ?? 0,
                  ),
                );
              },
            ),
    );
  }
}