import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar datas
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o userId

// Importe o modelo de hábito
import '../models/habits_model.dart';
// Importe o novo modal de adicionar/editar hábito
import 'add_edit_habit_modal_tab.dart';
// Importe o serviço de hábitos
import '../services/habits_services.dart';
// Importe o ClearField se _CartaoHabito ainda estiver aqui e o usar

import '../../widgets_utils/clear_field.dart';

// --- Widget Cartão de Hábito (Privado e no mesmo arquivo) ---
// Idealmente, este widget estaria em um arquivo separado para melhor modularidade.
class _CartaoHabito extends StatelessWidget {
  final HabitoModel habito; // Agora recebe um HabitoModel completo
  final String Function(Timestamp?) formatarData;
  final Function(String, HabitoModel)
  aoEditar; // Passa o HabitoModel para editar
  final Function(String, String) aoExcluir; // ID e título para exclusão

  const _CartaoHabito({
    super.key,
    required this.habito,
    required this.formatarData,
    required this.aoEditar,
    required this.aoExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6, // Elevação aumentada para mais profundidade
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Cantos mais arredondados
      ),
      child: Stack(
        children: [
          InkWell(
            onTap:
                () => aoEditar(
                  habito.id,
                  habito,
                ), // Abre o modal de edição ao tocar no card
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(20), // Preenchimento maior
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habito.titulo, // Usa o modelo
                    style: TextStyle(
                      fontSize: 22, // Título maior e em negrito
                      fontWeight: FontWeight.bold,
                      color:
                          colorScheme.onSurface, // Cor do texto baseada no tema
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    habito.descricao, // Usa o modelo
                    style: TextStyle(
                      color:
                          Colors
                              .grey[700], // Cinza mais escuro para melhor legibilidade
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, // Espaçamento entre os chips
                    runSpacing: 6, // Espaçamento entre as linhas de chips
                    children: [
                      Chip(
                        label: Text(
                          "Frequência: ${habito.frequencia}", // Usa o modelo
                          style: const TextStyle(fontSize: 13),
                        ),
                        backgroundColor:
                            Colors.blue.shade50, // Cor de fundo suave
                        labelStyle: TextStyle(
                          color: Colors.blue.shade700,
                        ), // Cor do texto
                        side: BorderSide(
                          color: Colors.blue.shade200,
                        ), // Borda sutil
                      ),
                      if (habito.meta != null && habito.meta!.isNotEmpty)
                        Chip(
                          label: Text(
                            "Meta: ${habito.meta}", // Usa o modelo
                            style: const TextStyle(fontSize: 13),
                          ),
                          backgroundColor: Colors.purple.shade50,
                          labelStyle: TextStyle(color: Colors.purple.shade700),
                          side: BorderSide(color: Colors.purple.shade200),
                        ),
                      Chip(
                        label: Text(
                          habito.feitoHoje
                              ? 'Concluído hoje!'
                              : 'Ainda não concluído', // Usa o modelo
                          style: TextStyle(
                            color:
                                habito.feitoHoje
                                    ? Colors.white
                                    : Colors.red.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                            habito.feitoHoje
                                ? Colors.green
                                : Colors.red.shade100,
                        side: BorderSide(
                          color:
                              habito.feitoHoje
                                  ? Colors.green.shade700
                                  : Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Criado em: ${formatarData(habito.dataCriacao != null ? Timestamp.fromDate(habito.dataCriacao!) : null)}', // Usa o modelo
                    style: const TextStyle(
                      fontSize: 12, // Fonte um pouco menor para a data
                      color: Colors.grey, // Cor cinza para menor proeminência
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ícone de Editar - Posicionado no canto superior direito
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.blueAccent.shade400,
                size: 24,
              ),
              onPressed:
                  () => aoEditar(habito.id, habito), // Abre o modal de edição
              tooltip: 'Editar Hábito',
            ),
          ),

          // Ícone de Excluir - Posicionado no canto inferior direito
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade600, size: 24),
              onPressed:
                  () => aoExcluir(
                    habito.id,
                    habito.titulo,
                  ), // Chama a função de exclusão
              tooltip: 'Excluir Hábito',
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASSE HabitsPage (Página Principal) ---
class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  // Instância do HabitService para lidar com as operações de CRUD
  final HabitService _habitService = HabitService();
  // Instância do Firebase Auth para obter o ID do usuário atual
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para formatar o timestamp do Firestore em uma string legível
  String _formatarData(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final data = timestamp.toDate();
    // Importante: certifique-se de que o locale 'pt_BR' esteja inicializado no seu main.dart
    return DateFormat("dd 'de' MMMM 'de' y 'às' HH:mm", 'pt_BR').format(data);
  }

  // Método para exibir o modal de adicionar ou editar hábito
  void _showAddEditHabitModal(
    BuildContext context, {
    HabitoModel? habitoParaEditar,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal se ajuste ao teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddEditHabitModal(
          // Chama o novo modal AddEditHabitModal
          habitoParaEditar: habitoParaEditar,
        );
      },
    );
  }

  // Função para exibir o diálogo de confirmação de exclusão
  void _confirmarExclusaoHabito(
    BuildContext context,
    String idHabito,
    String titulo,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              'Excluir Hábito',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              'Tem certeza que deseja excluir o hábito "$titulo"? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(
                    context,
                  ); // Fecha o diálogo antes de tentar deletar

                  final String? errorMessage = await _habitService
                      .deletarHabito(idHabito);

                  if (errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hábito excluído com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obter o ID do usuário logado. Isso é crucial para filtrar hábitos.
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      // Se o usuário não estiver logado, exibe uma mensagem ou redireciona
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Meus Hábitos',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Por favor, faça login para ver seus hábitos.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Hábitos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<HabitoModel>>(
        // Altera o tipo do StreamBuilder para List<HabitoModel>
        stream: _habitService.listarHabitosDoUsuario(
          currentUserId,
        ), // Usa o serviço para listar hábitos do usuário
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar hábitos: ${snapshot.error}'),
            );
          }

          final List<HabitoModel> habitos =
              snapshot.data ?? []; // Recebe uma lista de HabitoModel

          if (habitos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum hábito cadastrado ainda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Toque no botão "+" para adicionar um novo hábito!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habitos.length,
            itemBuilder: (context, index) {
              final HabitoModel habito =
                  habitos[index]; // Pega o HabitoModel diretamente

              return _CartaoHabito(
                habito: habito, // Passa o modelo completo
                formatarData: _formatarData,
                aoEditar:
                    (id, habitoModel) => _showAddEditHabitModal(
                      // Passa HabitoModel para editar
                      context,
                      habitoParaEditar: habitoModel,
                    ),
                aoExcluir:
                    (id, titulo) =>
                        _confirmarExclusaoHabito(context, id, titulo),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () =>
                _showAddEditHabitModal(context), // Abre o modal para adicionar
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
