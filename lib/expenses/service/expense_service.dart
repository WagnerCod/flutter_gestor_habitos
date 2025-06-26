import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o ID do usuário autenticado
import '../models/expenses_model.dart'; // Importe o DespesaModel

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coleção do Firestore para despesas
  final CollectionReference _despesasCollection = FirebaseFirestore.instance
      .collection('despesas'); // Nome da coleção em português

  // Método para adicionar uma nova despesa ao Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> adicionarDespesa({
    required String descricao,
    required double valor,
    required String categoria,
    required DateTime data,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para adicionar despesas.";
      }
      final String usuarioId = currentUser.uid;

      // Cria um objeto DespesaModel
      final DespesaModel novaDespesa = DespesaModel(
        id: '', // O ID será gerado pelo Firestore
        descricao: descricao,
        valor: valor,
        categoria: categoria,
        data: data,
        usuarioId: usuarioId,
        dataCriacao: DateTime.now(), // Define data de criação no modelo
      );

      // Adiciona o documento à coleção 'despesas' no Firestore
      await _despesasCollection.add(novaDespesa.toMap());

      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao adicionar despesa (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao adicionar despesa: $e";
    }
  }

  // Método para atualizar uma despesa existente no Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> atualizarDespesa({
    required String idDespesa,
    required Map<String, dynamic> dadosAtualizados,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para atualizar despesas.";
      }
      final String usuarioId = currentUser.uid;

      // Opcional: Adicionar ou verificar o 'usuarioId' nos dados atualizados para regras de segurança.
      // dadosAtualizados['usuarioId'] = usuarioId; // Se suas regras exigirem isso no update.

      await _despesasCollection.doc(idDespesa).update(dadosAtualizados);

      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao atualizar despesa (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao atualizar despesa: $e";
    }
  }

  // Método para deletar uma despesa do Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> deletarDespesa(String idDespesa) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para deletar despesas.";
      }
      // Não é estritamente necessário verificar userId aqui se suas regras de segurança do Firestore
      // já garantem que um usuário só pode deletar seus próprios documentos.

      await _despesasCollection.doc(idDespesa).delete();
      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao deletar despesa (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao deletar despesa: $e";
    }
  }

  // Método para listar despesas do usuário (usado na ExpensesPage)
  Stream<QuerySnapshot> listarDespesasDoUsuario(String usuarioId) {
    return _despesasCollection
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('data', descending: true) // Ordena pela 'data' da despesa
        .snapshots();
  }
}
