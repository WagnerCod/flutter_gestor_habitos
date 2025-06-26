// lib/incomes/pages/incomes_page.dart
import 'package:flutter/material.dart';

class IncomesPage extends StatelessWidget {
  const IncomesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Receitas')),
      body: const Center(
        child: Text(
          'Página de Receitas (Em breve!)',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
