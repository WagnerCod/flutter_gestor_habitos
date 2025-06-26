import 'package:flutter/material.dart';
import '../../home/pages/home_page.dart'; // Certifique-se de que o caminho para HomePage está correto
import '../../register/pages/register_page.dart'; // Certifique-se de que o caminho para RegisterPage está correto
import '../services/login_page_service.dart'; // Importe o serviço de login

// Converte LoginPage de StatelessWidget para StatefulWidget para gerenciar o estado
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de email e senha
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variáveis de estado para a UI
  bool _rememberMe = false; // Estado para o checkbox "Lembrar-me"
  bool _obscurePassword = true; // Estado para controlar a visibilidade da senha
  bool _isLoading = false; // Estado para controlar o indicador de carregamento

  @override
  void dispose() {
    // Libera os controladores quando o widget é descartado para evitar vazamentos de memória
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Método assíncrono para lidar com o login via email e senha
  Future<void> _handleEmailPasswordLogin() async {
    // Tira o foco de qualquer campo de texto para fechar o teclado
    FocusScope.of(context).unfocus();

    // Validação básica para garantir que os campos não estão vazios
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar('Por favor, preencha o email e a senha.', Colors.red);
      return;
    }

    // Ativa o indicador de carregamento na UI
    setState(() {
      _isLoading = true;
    });

    // Chama o método de login do serviço, delegando a lógica de autenticação
    final String? errorMessage = await LoginPageService.signInWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );

    // Desativa o indicador de carregamento, independentemente do resultado
    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      // Se errorMessage for null, significa sucesso no login
      _showSnackBar('Login bem-sucedido!', Colors.green);
      // Navega para a HomePage e remove todas as rotas anteriores da pilha
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) =>
            false, // Impede que o usuário volte para a tela de login
      );
    } else {
      // Se houver uma mensagem de erro, exibe-a
      _showSnackBar(errorMessage, Colors.red);
    }
  }

  // Método assíncrono para lidar com o login via Google
  Future<void> _handleGoogleSignIn() async {
    // Tira o foco de qualquer campo de texto para fechar o teclado
    FocusScope.of(context).unfocus();

    // Ativa o indicador de carregamento na UI
    setState(() {
      _isLoading = true;
    });

    // Chama o método de login do Google do serviço
    final String? errorMessage = await LoginPageService.signInWithGoogle();

    // Desativa o indicador de carregamento, independentemente do resultado
    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      // Se errorMessage for null, significa sucesso no login
      _showSnackBar('Login com Google bem-sucedido!', Colors.green);
      // Navega para a HomePage e remove todas as rotas anteriores da pilha
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) =>
            false, // Impede que o usuário volte para a tela de login
      );
    } else {
      // Se houver uma mensagem de erro, exibe-a
      _showSnackBar(errorMessage, Colors.red);
    }
  }

  // Helper para exibir mensagens temporárias (SnackBar) na parte inferior da tela
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // Conteúdo da mensagem
        backgroundColor: color, // Cor de fundo da SnackBar
        behavior:
            SnackBarBehavior.floating, // Comportamento flutuante da SnackBar
        duration: const Duration(
          seconds: 3,
        ), // Duração que a SnackBar ficará visível
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cor de fundo da tela de login
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            // Permite rolagem se o conteúdo for maior que a tela (útil com teclado)
            children: [
              const SizedBox(height: 20),
              // Botão de voltar, alinhado ao topo à esquerda
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    // Verifica se há rotas para voltar, caso contrário, exibe uma mensagem
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      _showSnackBar('Esta é a primeira tela.', Colors.grey);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Título principal da página de login
              const Text(
                'Faça sua conta ou entre para organizar seus hábitos',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Subtítulo da página
              const Text(
                'Entre com seu email e senha',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),

              // Tabs simuladas (Login / Registrar)
              // Esta é uma UI para alternar entre as telas de Login e Registro.
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              Colors
                                  .white, // A aba "Login" está ativa (fundo branco)
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => Navigator.push(
                              // Ao tocar, navega para a tela de Registro
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Center(
                            child: Text(
                              'Registrar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                      TextInputType
                          .emailAddress, // Teclado otimizado para emails
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email, color: Colors.white70),
                    border: InputBorder.none,
                    labelText: 'Email Address',
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
                      _obscurePassword, // Alterna a visibilidade da senha
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock, color: Colors.white70),
                    border: InputBorder.none,
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: IconButton(
                      // Ícone para alternar visibilidade da senha
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
              const SizedBox(height: 10),

              // Seção "Lembrar-me" e "Esqueceu a senha?"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value:
                            _rememberMe, // O estado do checkbox é controlado pela variável _rememberMe
                        onChanged: (value) {
                          setState(() {
                            _rememberMe =
                                value ?? false; // Atualiza o estado do checkbox
                          });
                        },
                        checkColor:
                            Colors.black, // Cor do "check" quando marcado
                        fillColor: MaterialStateProperty.all(
                          Colors.white,
                        ), // Cor do fundo do checkbox
                      ),
                      const Text(
                        'Lembrar-me', // Texto do checkbox
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _showSnackBar(
                        'Funcionalidade de "Esqueceu a Senha?" em desenvolvimento.',
                        Colors.blue,
                      );
                      // TODO: Implementar a lógica de recuperação de senha aqui
                    },
                    child: const Text(
                      'Esqueceu a senha?', // Link para recuperação de senha
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botão de Login (Email/Senha)
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : _handleEmailPasswordLogin, // Desabilita o botão enquanto _isLoading é true
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF4CAF50,
                  ), // Cor de fundo do botão (verde)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // Cantos arredondados
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ), // Preenchimento vertical
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(
                          color: Colors.white,
                        ) // Mostra um indicador de carregamento
                        : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ), // Texto do botão
                        ),
              ),
              const SizedBox(height: 20),

              //Separador "Ou login com"
              const Center(
                child: Text(
                  'Ou login com',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),

              //Botões de Login Social (Google)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão de Login com Google
                  socialButton(
                    label: 'Google',
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg', // URL de um ícone do Google
                      height: 20,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.g_mobiledata,
                            color: Colors.black,
                            size: 24,
                          ), // Fallback para o ícone
                    ),
                    onPressed:
                        _isLoading
                            ? null
                            : _handleGoogleSignIn, // Chama o método de login com Google
                  ),
                  const SizedBox(width: 20),
                  // Você pode adicionar outros botões de login social aqui, como Facebook
                  // socialButton(
                  //   label: 'Facebook',
                  //   icon: Image.asset('assets/facebook.png', height: 20), // Requer o asset 'facebook.png' na pasta 'assets'
                  //   onPressed: () { /* Lógica para Facebook */ },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizável para criar botões de login social (Google, Facebook, etc.)
  Widget socialButton({
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed, // O callback para o botão
      icon: icon, // O ícone do botão
      label: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ), // O texto do botão
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Fundo branco para botões sociais
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Preenchimento interno
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ), // Cantos arredondados
      ),
    );
  }
}
