import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController firstController = TextEditingController();
  final TextEditingController secondController = TextEditingController();
  String result = '';
  String? errorText;

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    super.dispose();
  }

  void calculate(String operation) {
    final a = double.tryParse(firstController.text.trim());
    final b = double.tryParse(secondController.text.trim());

    if (a == null || b == null) {
      setState(() {
        errorText = 'Please enter valid numbers in both fields.';
        result = '';
      });
      return;
    }

    double value;
    switch (operation) {
      case '+':
        value = a + b;
        break;
      case '-':
        value = a - b;
        break;
      case '*':
        value = a * b;
        break;
      case '/':
        if (b == 0) {
          setState(() {
            errorText = 'Cannot divide by zero.';
            result = '';
          });
          return;
        }
        value = a / b;
        break;
      default:
        return;
    }

    setState(() {
      errorText = null;
      result = value % 1 == 0 ? value.toInt().toString() : value.toString();
    });
  }

  void clear() {
    setState(() {
      firstController.clear();
      secondController.clear();
      result = '';
      errorText = null;
    });
  }

  Widget opButton(String label, String op) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => calculate(op),
          child: Text(label, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: firstController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'First number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: secondController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Second number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                opButton('+', '+'),
                opButton('-', '-'),
                opButton('×', '*'),
                opButton('÷', '/'),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: clear, child: const Text('Clear')),
            const SizedBox(height: 24),
            if (errorText != null)
              Text(
                errorText!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (result.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Result: $result',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
