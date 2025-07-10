import 'dart:io'; // Para File, usado com image_picker
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o usuário atual
import 'package:image_picker/image_picker.dart'; // Para selecionar imagem

import '../../widgets_utils/clear_field.dart'; // Seu widget ClearField
import '../services/profile_service.dart'; // O serviço de perfil
import '../../login/pages/login_page.dart'; // Para redirecionar após logout

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nomeUsuarioController = TextEditingController();

  String? _currentPhotoUrl; // URL da foto de perfil atual (vindo do Firestore)
  File?
  _pickedImageFile; // Arquivo de imagem selecionado localmente (para pré-visualização antes do upload)
  bool _isLoading = false; // Estado de carregamento para operações do perfil

  // Stream para ouvir as atualizações do perfil em tempo real do Firestore
  late Stream<Map<String, dynamic>?> _profileDataStream;

  @override
  void initState() {
    super.initState();
    // Inicia o stream para carregar e ouvir dados do perfil
    _profileDataStream = _profileService.getProfileData();
    _profileDataStream.listen((data) {
      if (mounted) {
        // Verifica se o widget ainda está montado antes de chamar setState
        setState(() {
          // Apenas atualiza o controlador de texto se não estiver editando ativamente
          // ou se o valor do banco de dados for diferente do que está no campo.
          // Isso evita que o cursor pule ou que o campo seja sobrescrito enquanto o usuário digita.
          if (_nomeUsuarioController.text.isEmpty ||
              (_nomeUsuarioController.text != (data?['nomeUsuario'] ?? '') &&
                  !_nomeUsuarioController.text.startsWith('Carregando...'))) {
            _nomeUsuarioController.text = data?['nomeUsuario'] ?? '';
          }
          _currentPhotoUrl = data?['fotoPerfilUrl'];
          _pickedImageFile =
              null; // Limpa a pré-visualização local após um upload ou carregamento de rede.
        });
      }
    });
  }

  @override
  void dispose() {
    _nomeUsuarioController.dispose();
    super.dispose();
  }

  // Exibe um modal para o usuário escolher a fonte da imagem
  Future<void> _showImageSourceSelectionModal() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        // Cantos arredondados no topo do modal
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(
            20.0,
          ), // Padding interno para o conteúdo do modal
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Escolha a Fonte da Imagem',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.blueAccent,
                ),
                title: const Text(
                  'Galeria de Fotos',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Câmera', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              // Opção de remover foto, visível apenas se houver uma foto atual
              if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Remover Foto Atual',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Permite ao usuário selecionar uma imagem do ImagePicker
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true; // Ativa o carregamento
    });
    try {
      final ImagePicker picker = ImagePicker();
      // 'imageQuality' reduz o tamanho do arquivo, útil para upload e economia de dados.
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImageFile = File(
            pickedFile.path,
          ); // Guarda o arquivo local para pré-visualização
        });
        await _uploadImage(
          _pickedImageFile!,
        ); // Tenta fazer upload imediatamente após selecionar
      } else {
        _showSnackBar('Nenhuma imagem selecionada.', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Erro ao selecionar imagem: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false; // Desativa o carregamento
      });
    }
  }

  // Faz o upload da imagem selecionada para o Firebase Storage
  Future<void> _uploadImage(File imageFile) async {
    if (_pickedImageFile == null) {
      _showSnackBar('Nenhuma imagem para upload.', Colors.red);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final String? resultUrl = await _profileService.uploadProfilePicture(
      imageFile,
    );
    setState(() {
      _isLoading = false;
    });
    if (resultUrl != null) {
      _showSnackBar('Foto de perfil atualizada com sucesso!', Colors.green);
      // A atualização do _currentPhotoUrl e _pickedImageFile = null será feita pelo stream listener.
    } else {
      _showSnackBar('Erro ao fazer upload da foto.', Colors.red);
      // Em caso de erro, remove a pré-visualização local para não mostrar uma imagem quebrada.
      setState(() {
        _pickedImageFile = null;
      });
    }
  }

  // Remove a foto de perfil do Firebase Storage e do Firestore
  Future<void> _removePhoto() async {
    setState(() {
      _isLoading = true;
    });
    final String? errorMessage = await _profileService.removeProfilePicture();
    setState(() {
      _isLoading = false;
    });
    if (errorMessage == null) {
      _showSnackBar('Foto de perfil removida com sucesso!', Colors.green);
      // A atualização do _currentPhotoUrl e _pickedImageFile = null será feita pelo stream listener.
    } else {
      _showSnackBar('Erro ao remover foto: $errorMessage', Colors.red);
    }
  }

  // Atualiza o nome de usuário no Firestore
  Future<void> _updateUserName() async {
    // Tira o foco para fechar o teclado
    FocusScope.of(context).unfocus();

    if (_nomeUsuarioController.text.trim().isEmpty) {
      _showSnackBar('O nome de usuário não pode estar vazio.', Colors.red);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final String? errorMessage = await _profileService.updateUserName(
      _nomeUsuarioController.text.trim(),
    );
    setState(() {
      _isLoading = false;
    });
    if (errorMessage == null) {
      _showSnackBar('Nome de usuário atualizado!', Colors.green);
    } else {
      _showSnackBar('Erro ao atualizar nome: $errorMessage', Colors.red);
    }
  }

  // Helper para exibir SnackBar (mensagens temporárias)
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser; // Obtém o usuário Firebase atual

    // Se não houver usuário logado, exibe uma mensagem
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Por favor, faça login para ver e editar seu perfil.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Estilo de decoração para os campos de input do perfil
    final inputDecorationProfile = InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: TextStyle(color: Colors.grey[700]),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      prefixIconColor: Colors.grey[600],
    );

    // Layout principal da página de perfil
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading // Se estiver carregando, mostra um CircularProgressIndicator
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                // Permite rolagem se o conteúdo exceder a tela
                padding: const EdgeInsets.all(24), // Preenchimento geral
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .center, // Centraliza os elementos na coluna
                  children: [
                    // Seção de Foto de Perfil
                    Card(
                      elevation:
                          8, // Sombra mais proeminente para o card da foto
                      shape: CircleBorder(), // Card circular
                      clipBehavior:
                          Clip.antiAliasWithSaveLayer, // Garante que a imagem dentro do card seja recortada corretamente
                      child: InkWell(
                        // Torna a área da foto clicável
                        onTap: _showImageSourceSelectionModal,
                        child: Container(
                          width: 160, // Aumenta o tamanho da área da foto
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            image:
                                _pickedImageFile != null
                                    ? DecorationImage(
                                      image: FileImage(_pickedImageFile!),
                                      fit: BoxFit.cover,
                                    )
                                    : (_currentPhotoUrl != null &&
                                            _currentPhotoUrl!.isNotEmpty
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            _currentPhotoUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null),
                          ),
                          child:
                              _pickedImageFile == null &&
                                      (_currentPhotoUrl == null ||
                                          _currentPhotoUrl!.isEmpty)
                                  ? Icon(
                                    Icons
                                        .person, // Ícone padrão se não houver foto
                                    size: 80,
                                    color: Colors.grey[600],
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty
                          ? 'Toque na foto para mudar ou remover'
                          : 'Toque para adicionar uma foto de perfil',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Informações Básicas do Usuário
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 0,
                      ), // Preenchimento lateral do card
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Informações da Conta',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              height: 30,
                              thickness: 1,
                            ), // Divisor visual
                            Text(
                              'Email: ${user.email ?? 'Não disponível'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campo para Nome de Usuário
                            ClearField(
                              label: 'Nome de Usuário',
                              controller: _nomeUsuarioController,
                              onLimpar:
                                  () => setState(
                                    () => _nomeUsuarioController.clear(),
                                  ),
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              decoration: inputDecorationProfile.copyWith(
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Botão para Salvar Nome de Usuário
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _updateUserName,
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Salvar Nome',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 3, // Sombra para o botão
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Seção de Ações da Conta (Ex: Logout)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Ações da Conta',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 30, thickness: 1),
                            ElevatedButton.icon(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                }); // Ativa o carregamento antes do logout
                                await _auth
                                    .signOut(); // Usa a instância do _auth
                                // Redireciona para a tela de login e remove todas as rotas anteriores
                                if (mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Sair',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 3, // Sombra para o botão
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
