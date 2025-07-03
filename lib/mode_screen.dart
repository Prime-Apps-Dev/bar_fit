import 'package:flutter/material.dart';

class ModeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> savedModes;
  final Function(Map<String, dynamic>) onModeSelected;
  final Function(Map<String, dynamic>) onDeleteMode;

  const ModeScreen({
    Key? key,
    required this.savedModes,
    required this.onModeSelected,
    required this.onDeleteMode,
  }) : super(key: key);

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  int? selectedIndex;
  int? editingIndex;
  String? editingText;

  // 1. Список доступных иконок
  final List<IconData> availableIcons = [
    Icons.sports_mma,
    Icons.directions_run,
    Icons.fitness_center,
    Icons.sports_kabaddi,
    Icons.sports_handball,
    Icons.sports_basketball,
    Icons.sports_football,
    Icons.sports_tennis,
    Icons.sports_volleyball,
    Icons.sports_baseball,
    Icons.sports_cricket,
    Icons.sports_golf,
    Icons.sports_hockey,
    Icons.sports_motorsports,
    Icons.sports_soccer,
  ];

  void _startEditing(int index, String currentText) {
    setState(() {
      editingIndex = index;
      editingText = currentText;
    });
  }

  void _saveEditing(int index) {
    if (editingText != null) {
      setState(() {
        widget.savedModes[index]['name'] = editingText;
        editingIndex = null;
        editingText = null;
      });
    }
  }

  void _selectIcon(int index) async {
    final IconData? selected = await showDialog<IconData>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Выберите иконку'),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: availableIcons.map((icon) {
              return IconButton(
                icon: Icon(icon, size: 32),
                onPressed: () => Navigator.pop(context, icon),
              );
            }).toList(),
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        widget.savedModes[index]['icon'] = selected;
      });
    }
  }

  // Пример функции для добавления нового режима
  void addNewMode() {
    int iconIndex = widget.savedModes.length % availableIcons.length;
    Map<String, dynamic> newMode = {
      'name': 'Новый режим',
      'icon': availableIcons[iconIndex],
      // другие поля по необходимости
    };
    setState(() {
      widget.savedModes.add(newMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Режимы'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addNewMode,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: widget.savedModes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Нет режимов',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Добавить режим'),
                        onPressed: addNewMode,
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;
                    int crossAxisCount = 2;
                    if (width > 1200) {
                      crossAxisCount = 5;
                    } else if (width > 900) {
                      crossAxisCount = 4;
                    } else if (width > 600) {
                      crossAxisCount = 3;
                    }
                    double spacing = width * 0.02;
                    double cardWidth = (width - spacing * (crossAxisCount - 1)) / crossAxisCount;
                    double cardHeight = cardWidth * 1.10; // ← Здесь задаётся высота карточки

                    return GridView.builder(
                      itemCount: widget.savedModes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: 1, // Было 0.85, теперь 1 для квадрата
                      ),
                      itemBuilder: (context, index) {
                        final mode = widget.savedModes[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            widget.onModeSelected(mode);
                          },
                          onLongPress: () => widget.onDeleteMode(mode),
                          child: SizedBox(
                            width: cardWidth,
                            height: cardHeight, // ← фиксируем высоту!
                            child: _modeDataContainer(
                              mode,
                              isSelected: selectedIndex == index,
                              index: index,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _modeDataContainer(
    Map<String, dynamic> modeData, {
    bool isSelected = false,
    required int index,
  }) {
    final String name = modeData['name'] ?? 'Быстрый режим';
    // Используем выбранную иконку или первую из availableIcons
    final IconData icon = modeData['icon'] ?? availableIcons[0];
    final Color iconColor = modeData['iconColor'] ?? Colors.black;
    final bool filled = isSelected || (modeData['filled'] ?? false);

    final String? topValue = modeData['topValue'];
    final String? bottomValue = modeData['bottomValue'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final double iconSize = cardWidth * 0.13;
        final double circleSize = cardWidth * 0.18;
        final double fontSize = cardWidth * 0.09;
        final double rowIconSize = cardWidth * 0.07; // добавьте это
        final double rowFontSize = cardWidth * 0.06; // и это

        return Container(
          constraints: BoxConstraints(minHeight: 140),
          padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.015, vertical: cardWidth * 0.025),
          decoration: BoxDecoration(
            color: filled ? null : Colors.white,
            gradient: filled
                ? const LinearGradient(
                    colors: [Color(0xFF3887FE), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(cardWidth * 0.09),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Центрируем всё по горизонтали
            children: [
              // --- Верхняя строка: иконка-перчатка слева, остальные иконки справа ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Центрируем иконки
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(icon, size: iconSize, color: filled ? Colors.white : iconColor),
                    onPressed: () => _selectIcon(index),
                    splashRadius: iconSize * 0.7,
                    tooltip: 'Выбрать иконку',
                  ),
                  SizedBox(width: cardWidth * 0.38),
                  Icon(Icons.bookmark, size: iconSize * 0.8, color: Colors.blue),
                  SizedBox(width: cardWidth * 0.02),
                  Icon(Icons.star_border, size: iconSize * 0.8, color: Colors.blue),
                ],
              ),
              SizedBox(height: cardWidth * 0.02),
              // --- Текст (название режима) по центру ---
              editingIndex == index
                  ? Padding(
                    padding: const EdgeInsets.only(left: 5 ),
                    child: TextField(
                        autofocus: true,
                        controller: TextEditingController(text: editingText ?? name),
                        onChanged: (val) => editingText = val,
                        onSubmitted: (_) => _saveEditing(index),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: filled ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero, // убираем все внутренние отступы
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                  )
                  : GestureDetector(
                      onTap: () => _startEditing(index, name),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: filled ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              SizedBox(height: cardWidth * 0.02),
              // --- Круги и параметры: всё по центру ---
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _DashedCircle(selected: true, size: circleSize, filled: filled),
                        SizedBox(height: cardWidth * 0.02),
                        _DashedCircle(selected: false, size: circleSize * 0.9, filled: filled),
                      ],
                    ),
                    SizedBox(width: cardWidth * 0.04),
                    // Параметры по центру
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _ModeRow(
                            icon: Icons.looks_4,
                            text: '${modeData['roundDuration'] ?? 8} минут',
                            filled: filled,
                            iconSize: rowIconSize,
                            fontSize: rowFontSize,
                          ),
                          _ModeRow(
                            icon: Icons.pause_circle_filled,
                            text: '${modeData['roundBreak'] ?? 2} минуты',
                            filled: filled,
                            faded: true,
                            iconSize: rowIconSize,
                            fontSize: rowFontSize,
                          ),
                          SizedBox(height: cardWidth * 0.012),
                          _ModeRow(
                            icon: Icons.filter_8,
                            text: '${modeData['exerciseDuration'] ?? 30} секунд',
                            filled: filled,
                            iconSize: rowIconSize,
                            fontSize: rowFontSize,
                          ),
                          _ModeRow(
                            icon: Icons.pause_circle_filled,
                            text: '${modeData['exerciseBreak'] ?? 3} секунды',
                            filled: filled,
                            faded: true,
                            iconSize: rowIconSize,
                            fontSize: rowFontSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: cardWidth * 0.018),
              if (bottomValue != null)
                Center(
                  child: Text(
                    bottomValue,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize * 0.8,
                      color: filled ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeDataRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickModeCard() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                radius: 18,
                child: Icon(Icons.sports_mma, color: Colors.black87, size: 22),
              ),
              Spacer(),
              Icon(Icons.bookmark, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Icon(Icons.star_border, color: Colors.blue, size: 24),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Быстрый режим',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Первый круглый индикатор
              Column(
                children: [
                  _circleProgress(0.8, Colors.blue),
                  SizedBox(height: 8),
                  _circleProgress(0.3, Colors.blue[200]!),
                ],
              ),
              SizedBox(width: 12),
              // Описание
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.looks_4, size: 18, color: Colors.black87),
                        SizedBox(width: 4),
                        Text('8 минут', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pause_circle_filled, size: 18, color: Colors.black54),
                        SizedBox(width: 4),
                        Text('2 минуты', style: TextStyle(fontSize: 15, color: Colors.black54)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.filter_8, size: 18, color: Colors.black87),
                        SizedBox(width: 4),
                        Text('30 секунд', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pause_circle_filled, size: 18, color: Colors.black54),
                        SizedBox(width: 4),
                        Text('3 секунды', style: TextStyle(fontSize: 15, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleProgress(double value, Color color, {double size = 32}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Container(
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCircle extends StatelessWidget {
  final bool selected;
  final double size;
  final bool filled;
  const _DashedCircle({required this.selected, required this.size, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          color: selected
              ? (filled ? Colors.white : Colors.blue)
              : Colors.grey.shade300,
          dashWidth: size * 0.13,
          gapWidth: size * 0.09,
          strokeWidth: size * 0.08,
        ),
        child: Center(
          child: Container(
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? (filled ? Colors.white : Colors.blue)
                    : Colors.grey.shade300,
                width: size * 0.05,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double gapWidth;
  final double strokeWidth;

  _DashedCirclePainter({
    required this.color,
    this.dashWidth = 4,
    this.gapWidth = 3,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double radius = (size.width / 2) - strokeWidth;
    double circumference = 2 * 3.141592653589793 * radius;
    int dashCount = (circumference / (dashWidth + gapWidth)).floor();

    for (int i = 0; i < dashCount; i++) {
      double startAngle = (i * (dashWidth + gapWidth)) / radius;
      double sweepAngle = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ModeRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool filled;
  final bool faded;
  final double iconSize;
  final double fontSize;
  const _ModeRow({
    required this.icon,
    required this.text,
    this.filled = false,
    this.faded = false,
    this.iconSize = 16,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: faded
                ? (filled ? Colors.white70 : Colors.black54)
                : (filled ? Colors.white : Colors.black87),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: faded
                  ? (filled ? Colors.white70 : Colors.black54)
                  : (filled ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
