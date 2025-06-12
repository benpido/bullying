import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/routes/app_routes.dart';
import 'package:math_expressions/math_expressions.dart';


class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with TickerProviderStateMixin {
  String _expression = '';
  String _result = '';
  int _equalPressCount = 0;
  final bool _showDecimalAlways = false;

  final List<String> _buttons = [
    'C',
    '(',
    ')',
    '÷',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    '=',
  ];

  late Map<String, AnimationController> _buttonAnimations;

  @override
  void initState() {
    super.initState();
    _buttonAnimations = {
      for (var button in _buttons)
        button: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        ),
    };
  }

  void _onPressed(String value) {
    HapticFeedback.mediumImpact();
    _buttonAnimations[value]?.forward().then((_) {
      _buttonAnimations[value]?.reverse();
    });

    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
        _equalPressCount = 0;
      } else if (value == '=') {
        _equalPressCount++;
        if (_equalPressCount >= 5) {
          _equalPressCount = 0;
          Navigator.pushNamed(context, AppRoutes.emergency);
        } else {
          try {
            final finalExpression = _expression
                .replaceAll('×', '*')
                .replaceAll('÷', '/');
            final parser = ShuntingYardParser();
            final exp = parser.parse(finalExpression);
            final cm = ContextModel();
            final eval = exp.evaluate(EvaluationType.REAL, cm);

            if (_showDecimalAlways) {
              _result = eval.toStringAsFixed(2);
            } else {
              _result =
                  eval == eval.toInt()
                      ? eval.toInt().toString()
                      : eval.toString();
            }
          } catch (_) {
            _result = 'Error';
          }
        }
      } else {
        _expression += value;
        _equalPressCount = 0;
      }
    });
  }

  void _deleteLast() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  void _navigateToConfig() {
    Navigator.pushNamed(context, AppRoutes.config);
  }
  @override
  void dispose() {
    for (final controller in _buttonAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }
  Widget buildButton(
    String value,
    Color color, {
    bool isLarge = false,
    Widget? icon,
  }) {
    return GestureDetector(
      onTap: () => _onPressed(value),
      onLongPress: value == 'C' ? _deleteLast : null,
      child: AnimatedBuilder(
        animation: _buttonAnimations[value]!,
        builder: (context, child) {
          final scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
            CurvedAnimation(
              parent: _buttonAnimations[value]!,
              curve: Curves.easeInOut,
            ),
          );
          final scale = scaleAnimation.value;
          final borderRadius = scale == 1.0 ? 32 : 50;

          return ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(4),
              width:
                  isLarge
                      ? (MediaQuery.of(context).size.width / 4 * 2 - 16)
                      : (MediaQuery.of(context).size.width / 4 * 2 - 16) / 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius.toDouble()),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Center(
                child:
                    icon ??
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _navigateToConfig,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 28,
                        color: isDarkMode ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _buttons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 4,
                          mainAxisExtent: 78,
                        ),
                    itemBuilder: (context, index) {
                      final value = _buttons[index];
                      Color color;

                      if (value == 'C') {
                        color = Colors.deepOrangeAccent;
                      } else if (value == '+' ||
                          value == '-' ||
                          value == '×' ||
                          value == '÷') {
                        color = Colors.teal;
                      } else if (value == '=') {
                        color = Colors.teal.shade700;
                      } else if (value == '.') {
                        color = Colors.orangeAccent;
                      } else {
                        color = Colors.indigo;
                      }

                      if (value == '0') {
                        return GridTile(
                          child: buildButton(value, color, isLarge: true),
                        );
                      } else {
                        return buildButton(value, color);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
