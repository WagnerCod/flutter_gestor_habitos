import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para StreamBuilder e Timestamp
import 'package:intl/intl.dart'; // Para formatar datas
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o ID do usuário

import '../models/incomes.model.dart'; // Importe o ReceitaModel
import 'add_edit_incomes_modal_tab.dart'; // Importe o modal de adicionar/editar receita
import '../services/incomes.service.dart'; // Importe o ReceitaService

class IncomesPage extends StatefulWidget {
  const IncomesPage({super.key});

  @override
  State<IncomesPage> createState() => _IncomesPageState();
}

class _IncomesPageState extends State<IncomesPage> {
  // Instância do Firebase Auth para obter o ID do usuário atual
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instância do ReceitaService para interagir com o Firestore para receitas
  final ReceitaService _receitaService = ReceitaService();

  // Método para formatar a data do Timestamp para exibição
  String _formatarData(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    final data = timestamp.toDate();
    // Garanta que 'pt_BR' está inicializado no main.dart para o DateFormat
    return DateFormat(
      "dd 'de' MMMM 'de' y",
      'pt_BR',
    ).format(data); // Formato de data sem a hora
  }

  // Método para exibir o modal de adicionar nova receita
  void _mostrarAddReceitaModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal se ajuste ao teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Passa null para indicar que é um novo registro
        return const AddEditReceitaModal(receitaParaEditar: null);
      },
    );
  }

  // Método para exibir o modal de editar receita
  void _mostrarEditReceitaModal(BuildContext context, ReceitaModel receita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Passa o objeto ReceitaModel para o modal no modo edição
        return AddEditReceitaModal(receitaParaEditar: receita);
      },
    );
  }

  // Método para confirmar e excluir uma receita
  Future<void> _confirmarExclusaoReceita(
    BuildContext context,
    String idReceita,
    String descricao,
  ) async {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              'Excluir Receita',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              'Tem certeza que deseja excluir a receita "$descricao"? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Fecha o diálogo
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

                  final String? errorMessage = await _receitaService
                      .deletarReceita(idReceita);

                  if (errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receita excluída com sucesso!'),
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
    // Obter o ID do usuário logado. Isso é crucial para filtrar receitas.
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      // Se o usuário não estiver logado, exibe uma mensagem ou redireciona
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Minhas Receitas',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Por favor, faça login para ver suas receitas.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Receitas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ReceitaModel>>(
        // Escuta as receitas do Firestore
        stream: _receitaService.listarReceitasDoUsuario(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar receitas: ${snapshot.error}'),
            );
          }

          final List<ReceitaModel> receitas = snapshot.data ?? [];

          // Calcula o total das receitas
          final double totalReceitas = receitas.fold(
            0.0,
            (sum, item) => sum + item.valor,
          );

          if (receitas.isEmpty) {
            // Mensagem de estado vazio se não houver receitas
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma receita registrada ainda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  Text(
                    'Toque no "+" para adicionar sua primeira receita!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            // Usa Column para poder adicionar o card do total acima da lista
            children: [
              // Card do Total das Receitas
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.green.shade700, // Cor de destaque para receitas
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total de Receitas:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'R\$ ${totalReceitas.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Lista de receitas (Expanded para ocupar o espaço restante)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ), // Apenas lateral, já tem padding no total
                  itemCount: receitas.length,
                  itemBuilder: (context, index) {
                    final ReceitaModel receita =
                        receitas[index]; // Pega o ReceitaModel diretamente

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap:
                            () => _mostrarEditReceitaModal(
                              context,
                              receita,
                            ), // Abre modal para edição
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      receita.descricao, // Usa o modelo
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow:
                                          TextOverflow
                                              .ellipsis, // Lida com descrições longas
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${receita.valor.toStringAsFixed(2).replaceAll('.', ',')}', // Formata valor para moeda
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green, // Receita em verde
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    label: Text(
                                      receita.categoria,
                                    ), // Usa o modelo
                                    backgroundColor: Colors.green.shade50,
                                    labelStyle: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                    ),
                                    side: BorderSide(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      _formatarData(
                                        receita.dataCriacao != null
                                            ? Timestamp.fromDate(
                                              receita.dataCriacao!,
                                            )
                                            : null,
                                      ),
                                    ), // Usa o modelo e formata
                                    backgroundColor: Colors.grey.shade100,
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Ícones de ação dentro do card
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _mostrarEditReceitaModal(
                                            context,
                                            receita,
                                          ), // Abre o modal de edição
                                      tooltip: 'Editar Receita',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _confirmarExclusaoReceita(
                                            context,
                                            receita.id,
                                            receita.descricao,
                                          ), // Chama a função de exclusão
                                      tooltip: 'Excluir Receita',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => _mostrarAddReceitaModal(
              context,
            ), // Abre o modal para adicionar receita
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
