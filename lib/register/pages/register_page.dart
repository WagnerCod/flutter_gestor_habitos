import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
import '../../home/pages/home_page.dart'; // Certifique-se de que o caminho para HomePage está correto

// Converte LoginPage de StatelessWidget para StatefulWidget
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores para os campos de email, senha e confirmação de senha
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // Novo controlador

  // Variável para controlar o estado de carregamento do botão
  bool _isLoading = false;

  // Variáveis para controlar a visibilidade das senhas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword =
      true; // Nova variável para visibilidade da confirmação de senha

  // Instância do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // Libera os controladores quando o widget é descartado
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Libera o novo controlador
    super.dispose();
  }

  // Método para registrar um novo usuário
  Future<void> _registerUser() async {
    // Reseta o foco para fechar o teclado antes de registrar
    FocusScope.of(context).unfocus();

    // Validação básica dos campos
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      // Inclui o novo campo na validação
      _showSnackBar('Por favor, preencha todos os campos.', Colors.red);
      return;
    }

    // Validação de formato de email (simples)
    if (!_emailController.text.contains('@')) {
      _showSnackBar('Por favor, insira um email válido.', Colors.red);
      return;
    }

    // Validação de tamanho da senha
    if (_passwordController.text.length < 6) {
      _showSnackBar('A senha deve ter pelo menos 6 caracteres.', Colors.red);
      return;
    }

    // NOVA VALIDAÇÃO: Confirmação de senha
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar(
        'As senhas não coincidem. Por favor, verifique.',
        Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Ativa o indicador de carregamento
    });

    try {
      // Tenta criar o usuário com email e senha no Firebase
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Se o registro for bem-sucedido, exibe uma mensagem e navega para a HomePage
      if (userCredential.user != null) {
        // SALVAR DADOS DO USUÁRIO NO FIRESTORE AQUI
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
              'email': userCredential.user!.email,
              'nomeUsuario':
                  _emailController.text.split('@',
                  )[0], // Nome de usuário inicial (parte do email antes do @)
              'dataCadastro': FieldValue.serverTimestamp(),
              'fotoPerfilUrl': null, // Inicializa sem foto
            });

        _showSnackBar('Usuário registrado com sucesso!', Colors.green);
        // Usa pushReplacement para que o usuário não possa voltar para a tela de registro
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Captura e trata erros específicos do Firebase Auth
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Este email já está em uso para outra conta.';
      } else {
        errorMessage = 'Erro no registro: ${e.message}';
      }
      _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      // Captura outros erros inesperados
      _showSnackBar('Ocorreu um erro inesperado: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false; // Desativa o indicador de carregamento
      });
    }
  }

  // Helper para exibir SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior:
            SnackBarBehavior.floating, // Adiciona um comportamento flutuante
        duration: const Duration(seconds: 3), // Define a duração
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar conta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black, // Cor de fundo da AppBar
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Cor do ícone de voltar
        elevation: 0, // Remove a sombra da AppBar
      ),
      backgroundColor: Colors.black, // Cor de fundo da tela
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            // Usar ListView para evitar overflow quando o teclado aparece
            children: [
              const SizedBox(height: 20),
              Text(
                'Cadastre-se para começar a organizar seus hábitos!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Campo de Email
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType:
                      TextInputType.emailAddress, // Tipo de teclado para email
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email, color: Colors.white70),
                    border: InputBorder.none,
                    hintText:
                        'Email Address', // Usar hintText para campos escuros
                    hintStyle: TextStyle(color: Colors.white54),
                    labelText: 'Email', // labelText também pode ser útil
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Senha
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _passwordController,
                  obscureText:
                      _obscurePassword, // Controla a visibilidade da senha
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock, color: Colors.white70),
                    border: InputBorder.none,
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.white54),
                    labelText: 'Senha',
                    labelStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: IconButton(
                      // Botão para alternar visibilidade da senha
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ), // Espaçamento entre senha e confirmação
              // NOVO CAMPO: Confirmar Senha
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller:
                      _confirmPasswordController, // Usa o novo controlador
                  obscureText:
                      _obscureConfirmPassword, // Controla a visibilidade
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.lock_reset,
                      color: Colors.white70,
                    ), // Novo ícone
                    border: InputBorder.none,
                    hintText: 'Confirm Password',
                    hintStyle: const TextStyle(color: Colors.white54),
                    labelText: 'Confirme a Senha', // Novo label
                    labelStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: IconButton(
                      // Botão para alternar visibilidade
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botão de Registro
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : _registerUser, // Desabilita o botão enquanto carrega
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Cor verde
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(
                          color: Colors.white,
                        ) // Indicador de carregamento
                        : const Text(
                          'Registrar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
              ),
              const SizedBox(height: 20),

              // Botão para voltar ao Login (se o usuário já tem conta)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Já tem uma conta?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      ); // Volta para a tela anterior (Login)
                    },
                    child: const Text(
                      'Faça Login',
                      style: TextStyle(
                        color: Color(0xFF4CAF50), // Cor verde para o link
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
