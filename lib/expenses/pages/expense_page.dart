import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para StreamBuilder e Timestamp
import 'package:intl/intl.dart'; // Para formatar datas
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o ID do usuário

import '../models/expenses_model.dart'; // Importe o DespesaModel
import '../service/expense_service.dart'; // Importe o ExpenseService
import 'add_edit_expense_modal.dart'; // Importe o modal de adicionar/editar despesa

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  // Instância do Firebase Auth para obter o ID do usuário atual
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instância do ExpenseService para interagir com o Firestore para despesas
  final ExpenseService _expenseService = ExpenseService();

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

  // Método para exibir o modal de adicionar nova despesa
  void _mostrarAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal se ajuste ao teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Passa null para indicar que é um novo registro
        return const AddEditExpenseModal(despesaParaEditar: null);
      },
    );
  }

  // Método para exibir o modal de editar despesa
  void _mostrarEditExpenseModal(BuildContext context, DespesaModel despesa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Passa o objeto DespesaModel para o modal no modo edição
        return AddEditExpenseModal(despesaParaEditar: despesa);
      },
    );
  }

  // Método para confirmar e excluir uma despesa
  Future<void> _confirmarExclusaoDespesa(
    BuildContext context,
    String idDespesa,
    String descricao,
  ) async {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              'Excluir Despesa',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              'Tem certeza que deseja excluir a despesa "$descricao"? Esta ação não pode ser desfeita.',
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

                  final String? errorMessage = await _expenseService
                      .deletarDespesa(idDespesa);

                  if (errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Despesa excluída com sucesso!'),
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
    // Obter o ID do usuário logado. Isso é crucial para filtrar despesas.
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      // Se o usuário não estiver logado, exibe uma mensagem ou redireciona
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Minhas Despesas',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Por favor, faça login para ver suas despesas.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Despesas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuta as despesas do Firestore, filtrando pelo userId e ordenando por data.
        stream: _expenseService.listarDespesasDoUsuario(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar despesas: ${snapshot.error}'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            // Mensagem de estado vazio se não houver despesas
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.money_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma despesa registrada ainda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  Text(
                    'Toque no "+" para adicionar sua primeira despesa!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Lista de despesas
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              // Cria uma instância de DespesaModel a partir dos dados do Firestore
              final DespesaModel despesa = DespesaModel.fromMap(doc.id, data);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap:
                      () => _mostrarEditExpenseModal(
                        context,
                        despesa,
                      ), // Abre modal para edição
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                despesa.descricao, // Usa o modelo
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
                              'R\$ ${despesa.valor.toStringAsFixed(2).replaceAll('.', ',')}', // Formata valor para moeda
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent, // Despesa em vermelho
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
                              label: Text(despesa.categoria), // Usa o modelo
                              backgroundColor: Colors.orange.shade50,
                              labelStyle: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                              ),
                              side: BorderSide(color: Colors.orange.shade200),
                            ),
                            Chip(
                              label: Text(
                                _formatarData(
                                  despesa.dataCriacao != null
                                      ? Timestamp.fromDate(despesa.dataCriacao!)
                                      : null,
                                ),
                              ), // Usa o modelo e formata
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
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
                                    () => _mostrarEditExpenseModal(
                                      context,
                                      despesa,
                                    ), // Abre o modal de edição
                                tooltip: 'Editar Despesa',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _confirmarExclusaoDespesa(
                                      context,
                                      despesa.id,
                                      despesa.descricao,
                                    ), // Chama a função de exclusão
                                tooltip: 'Excluir Despesa',
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => _mostrarAddExpenseModal(
              context,
            ), // Abre o modal para adicionar despesa
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
