import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Este é o serviço de login que irá conter a lógica de autenticação.
// Ele será um StatelessWidget, o que significa que não tem estado mutável próprio,
// mas pode interagir com o Firebase Auth e Google Sign-In.
class LoginPageService {
  // Instâncias de FirebaseAuth e GoogleSignIn são obtidas aqui.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Construtor privado para garantir que seja usado como singleton ou acessado por métodos estáticos,
  // embora para esta implementação, os métodos serão estáticos.
  LoginPageService._(); // Construtor privado

  // Método estático para fazer login com email e senha
  // Retorna uma String com mensagem de sucesso ou erro.
  static Future<String?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Retorna null para indicar sucesso
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Nenhum usuário encontrado para este email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta para este email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O formato do email é inválido.';
      } else if (e.code == 'too-many-requests') {
        errorMessage =
            'Muitas tentativas de login. Tente novamente mais tarde.';
      } else {
        errorMessage = 'Erro no login: ${e.message}';
      }
      return errorMessage; // Retorna a mensagem de erro
    } catch (e) {
      return 'Ocorreu um erro inesperado: $e'; // Retorna erro genérico
    }
  }

  // Método estático para fazer login com Google
  // Retorna uma String com mensagem de sucesso ou erro.
  static Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return 'Login com Google cancelado.'; // Usuário cancelou
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return null; // Retorna null para indicar sucesso
    } on FirebaseAuthException catch (e) {
      return 'Erro no login com Google: ${e.message}';
    } catch (e) {
      return 'Ocorreu um erro inesperado no login com Google: $e';
    }
  }
}
