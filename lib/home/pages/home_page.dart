import 'package:flutter/material.dart';
import 'package:flutter_gestor_habitos/expenses/pages/expense_page.dart'; // Renomeado para expenses_page.dart
import 'package:flutter_gestor_habitos/habits/pages/habits_page.dart';
import 'package:flutter_gestor_habitos/profile/pages/profile_page.dart';
import '../../habits/pages/add_edit_habit_modal_tab.dart';
// Importe a página de Receitas (vamos criar o esqueleto dela em breve)
import '../../incomes/pages/incomes_page.dart'; // Certifique-se de criar este arquivo

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex =
      0; // Índice do item selecionado na barra de navegação inferior

  // Lista de widgets (páginas/abas) que serão exibidos na HomePage
  // A ordem aqui corresponde à ordem dos BottomNavigationBarItem.
  // IMPORTANTE: Mantenha a ordem dos seus itens da BottomNavigationBar aqui.
  final List<Widget> _tabs = [
    const HabitsPage(), // Abas de Hábitos
    const ExpensesPage(), // Aba de Despesas
    const IncomesPage(), // Aba de Receitas (Será criada no próximo passo)
    const ProfilePage(),
  ];

  // Método chamado quando um item da barra de navegação é tocado.
  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index); // Atualiza o índice selecionado.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A AppBar terá um título genérico para a aplicação.
      // Você pode querer mudar isso para o título da aba atual dinamicamente.
      appBar: AppBar(
        title: const Text(
          'Gestor de Hábitos & Finanças', // Título mais abrangente
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Texto branco para contraste
          ),
        ),
        centerTitle: true, // Centraliza o título da AppBar
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Cor da AppBar do tema
        elevation: 4, // Adiciona uma pequena sombra à AppBar
      ),

      // O corpo da HomePage exibe a página/aba selecionada com base no _selectedIndex.
      body: _tabs[_selectedIndex],


      // A barra de navegação inferior (BottomNavigationBar).
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // O item atualmente selecionado.
        onTap: _onTabTapped, // Callback ao tocar em um item.
        selectedItemColor:
            Theme.of(context).colorScheme.primary, // Cor do item selecionado.
        unselectedItemColor: Colors.grey, // Cor dos itens não selecionados.
        type:
            BottomNavigationBarType
                .fixed, // Garante que todos os itens são exibidos igualmente.
        backgroundColor:
            Theme.of(context).cardColor, // Cor de fundo da barra de navegação.

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl_outlined), // Ícone para Hábitos
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.paid_outlined,
            ), // Ícone para Despesas (Dinheiro pago)
            label: 'Despesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.savings_outlined,
            ), // Ícone para Receitas (Economias)
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ), // Ícone para Receitas (Economias)
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
