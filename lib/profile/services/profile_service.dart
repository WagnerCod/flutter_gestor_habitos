import 'dart:io'; // Para File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Para Firebase Storage

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Coleção onde os dados básicos do usuário serão armazenados/atualizados
  final CollectionReference _usuariosCollection = FirebaseFirestore.instance
      .collection('usuarios');

  // Método para obter os dados do perfil do usuário autenticado
  // Retorna um Stream de Map<String, dynamic> para atualizações em tempo real
  Stream<Map<String, dynamic>?> getProfileData() {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(null); // Retorna null se não houver usuário logado
    }
    return _firestore.collection('usuarios').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  // Método para atualizar o nome de usuário no Firestore
  Future<String?> updateUserName(String newName) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return "Usuário não autenticado.";
    }
    try {
      await _usuariosCollection.doc(userId).update({
        'nomeUsuario': newName.trim(),
      });
      return null; // Sucesso
    } on FirebaseException catch (e) {
      return "Erro ao atualizar nome: ${e.message}";
    } catch (e) {
      return "Erro inesperado ao atualizar nome: $e";
    }
  }

  // Método para fazer upload de uma foto de perfil para o Firebase Storage
  // Retorna a URL da foto em caso de sucesso, ou uma mensagem de erro.
  Future<String?> uploadProfilePicture(File imageFile) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return "Usuário não autenticado.";
    }
    try {
      // Cria uma referência para o local da imagem no Storage (ex: 'profile_pictures/userId.jpg')
      final Reference storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');

      // Faz o upload do arquivo
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Aguarda a conclusão do upload e obtém a URL de download
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Atualiza a URL da foto no Firestore para o perfil do usuário
      await _usuariosCollection.doc(userId).update({
        'fotoPerfilUrl': downloadUrl,
      });

      return downloadUrl; // Sucesso, retorna a URL
    } on FirebaseException catch (e) {
      return "Erro ao fazer upload da foto: ${e.message}";
    } catch (e) {
      return "Erro inesperado ao fazer upload da foto: $e";
    }
  }

  // Método para remover a foto de perfil do Firebase Storage e do Firestore
  Future<String?> removeProfilePicture() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return "Usuário não autenticado.";
    }
    try {
      // Primeiro, tenta deletar a imagem do Storage
      final Reference storageRef = _storage
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');
      await storageRef.delete();

      // Em seguida, remove a URL da foto do Firestore
      await _usuariosCollection.doc(userId).update({
        'fotoPerfilUrl': FieldValue.delete(),
      });

      return null; // Sucesso
    } on FirebaseException catch (e) {
      // Se o erro for 'object-not-found', significa que não havia foto, então é sucesso
      if (e.code == 'object-not-found') {
        // Apenas remove a URL do Firestore se a imagem já não existe no Storage
        await _usuariosCollection.doc(userId).update({
          'fotoPerfilUrl': FieldValue.delete(),
        });
        return null;
      }
      return "Erro ao remover foto: ${e.message}";
    } catch (e) {
      return "Erro inesperado ao remover foto: $e";
    }
  }
}
