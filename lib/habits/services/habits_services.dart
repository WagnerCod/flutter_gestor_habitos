import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o ID do usuário autenticado
import '../models/habits_model.dart'; // Importe o HabitoModel

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coleção do Firestore para hábitos
  final CollectionReference _habitosCollection = FirebaseFirestore.instance
      .collection('habitos'); // Nome da coleção em português

  // Método para adicionar um novo hábito ao Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> adicionarHabito({
    required String titulo,
    required String descricao,
    required String frequencia,
    String? meta,
    DateTime? ultimaConclusao, // Usar DateTime aqui para consistência
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para adicionar hábitos.";
      }
      final String usuarioId = currentUser.uid;

      // Cria um objeto HabitoModel
      final HabitoModel novoHabito = HabitoModel(
        id: '', // O ID será gerado pelo Firestore
        titulo: titulo,
        descricao: descricao,
        frequencia: frequencia,
        meta: meta,
        feitoHoje: false, // Hábito novo sempre começa como não feito hoje
        dataCriacao: DateTime.now(), // Define data de criação no modelo
        usuarioId: usuarioId, // Garante que o usuarioId seja passado
        ultimaConclusao: ultimaConclusao,
      );

      // Adiciona o documento à coleção 'habitos' no Firestore
      await _habitosCollection.add(novoHabito.toMap());

      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao adicionar hábito (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao adicionar hábito: $e";
    }
  }

  // Método para listar hábitos do usuário
  Stream<List<HabitoModel>> listarHabitosDoUsuario(String usuarioId) {
    return _habitosCollection
        .where('usuarioId', isEqualTo: usuarioId) // Filtra pelo usuarioId
        .orderBy('dataCriacao', descending: true) // Ordena pela data de criação
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => HabitoModel.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
        );
  }

  // Método para atualizar um hábito existente no Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> atualizarHabito({
    required String idHabito,
    required HabitoModel
    habitoAtualizado, // Recebe o modelo completo atualizado
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para atualizar hábitos.";
      }
      final String usuarioId = currentUser.uid;

      // Opcional: Verificar se o hábito pertence ao usuário (se não for feito nas regras de segurança)
      // QuerySnapshot query = await _habitosCollection.doc(idHabito).get();
      // if (query.data()?['usuarioId'] != usuarioId) {
      //   return "Você não tem permissão para atualizar este hábito.";
      // }

      // Converte o modelo atualizado para um mapa
      final Map<String, dynamic> dadosParaAtualizar = habitoAtualizado.toMap();
      // Remove o ID do documento do mapa, pois não se atualiza o ID
      dadosParaAtualizar.remove('id');
      // Garante que usuarioId não seja alterado por engano no update
      dadosParaAtualizar['usuarioId'] = usuarioId;

      await _habitosCollection.doc(idHabito).update(dadosParaAtualizar);

      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao atualizar hábito (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao atualizar hábito: $e";
    }
  }

  // Método para deletar um hábito do Firestore
  // Retorna null em caso de sucesso, ou uma mensagem de erro em caso de falha.
  Future<String?> deletarHabito(String idHabito) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Usuário não autenticado. Faça login para excluir hábitos.";
      }
      // Suas regras de segurança do Firestore devem garantir que um usuário só pode deletar seus próprios documentos.
      // Poderia-se adicionar uma verificação de propriedade aqui, se necessário.

      await _habitosCollection.doc(idHabito).delete();
      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao excluir hábito (Firebase): ${e.message}";
    } catch (e) {
      return "Erro inesperado ao excluir hábito: $e";
    }
  }
}
