import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o ID do usuário autenticado
import '../models/incomes.model.dart'; // Importe o ReceitaModel

class ReceitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coleção do Firestore para receitas
  final CollectionReference _receitasCollection = FirebaseFirestore.instance
      .collection('receitas'); // Nome da coleção em português

  // Método para adicionar uma nova receita ao Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> adicionarReceita({
    required String descricao,
    required double valor,
    required String categoria,
    required DateTime data,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para adicionar receitas.";
      }
      final String usuarioId = currentUser.uid;

      // Cria um objeto ReceitaModel
      final ReceitaModel novaReceita = ReceitaModel(
        id: '', // O ID será gerado pelo Firestore
        descricao: descricao,
        valor: valor,
        categoria: categoria,
        data: data,
        usuarioId: usuarioId,
        dataCriacao: DateTime.now(), // Define data de criação no modelo
      );

      // Adiciona o documento à coleção 'receitas' no Firestore
      await _receitasCollection.add(novaReceita.toMap());

      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao adicionar receita (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao adicionar receita: $e";
    }
  }

  // Método para listar receitas do usuário
  Stream<List<ReceitaModel>> listarReceitasDoUsuario(String usuarioId) {
    return _receitasCollection
        .where('usuarioId', isEqualTo: usuarioId) // Filtra pelo usuarioId
        .orderBy('data', descending: true) // Ordena pela 'data' da receita
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => ReceitaModel.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
        );
  }

  // Método para atualizar uma receita existente no Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> atualizarReceita({
    required String idReceita,
    required ReceitaModel
    receitaAtualizada, // Recebe o modelo completo atualizado
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para atualizar receitas.";
      }
      final String usuarioId = currentUser.uid;

      // Converte o modelo atualizado para um mapa
      final Map<String, dynamic> dadosParaAtualizar = receitaAtualizada.toMap();
      // Remove o ID do documento do mapa, pois não se atualiza o ID
      dadosParaAtualizar.remove('id');
      // Garante que usuarioId não seja alterado por engano no update
      dadosParaAtualizar['usuarioId'] = usuarioId;

      await _receitasCollection.doc(idReceita).update(dadosParaAtualizar);

      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao atualizar receita (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao atualizar receita: $e";
    }
  }

  // Método para deletar uma receita do Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> deletarReceita(String idReceita) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para deletar receitas.";
      }
      // Suas regras de segurança do Firestore devem garantir que um usuário só pode deletar suas próprias receitas.

      await _receitasCollection.doc(idReceita).delete();
      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao excluir receita (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao excluir receita: $e";
    }
  }
}
