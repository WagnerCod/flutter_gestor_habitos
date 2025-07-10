import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gestor_habitos/login/pages/login_page.dart'; // Importa a LoginPage
import 'package:flutter_gestor_habitos/home/pages/home_page.dart'; // Importa a HomePage
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Importante: Importar Firebase Auth
import 'package:intl/date_symbol_data_local.dart'; // Mantenha para initializeDateFormatting

// Importações para localização (DatePicker)
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Remover se não estiver usando a geração automática

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase
  var options = const FirebaseOptions(
    apiKey: "AIzaSyAwF1nTMTUZrL5XalJMHyFlkrk0JNIvXmI",
    authDomain: "flu-gestor-habitos.firebaseapp.com",
    projectId: "flu-gestor-habitos",
    storageBucket: "flu-gestor-habitos.appspot.com",
    messagingSenderId: "544644543277",
    appId:
        "1:544644543277:web:6bccce24b96339df7f19a4", // Verifique/ajuste seu appId REAL
    measurementId: "G-EWSNQ930LJ",
  );
  if (kIsWeb) {
    await Firebase.initializeApp(options: options);
  } else {
    // Para Android/iOS, que usa google-services.json e GoogleService-Info.plist
    await Firebase.initializeApp();
  }
  await initializeDateFormatting(
    'pt_BR',
    null,
  ); // Inicializa formatos de data/hora para pt_BR
  runApp(const GestorHabitosApp());
}

class GestorHabitosApp extends StatefulWidget {
  // Convertido para StatefulWidget
  const GestorHabitosApp({super.key});

  @override
  State<GestorHabitosApp> createState() => _GestorHabitosAppState();
}

class _GestorHabitosAppState extends State<GestorHabitosApp> {
  // Variável para armazenar o usuário autenticado (ou null se não estiver logado)
  User? _user;
  // Variável para indicar se o estado de autenticação já foi verificado
  bool _isAuthChecked = false;

  @override
  void initState() {
    super.initState();
    // Ouve as mudanças no estado de autenticação do Firebase.
    // Isso é chamado quando o app inicia, quando o usuário loga/desloga, etc.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        // Verifica se o widget ainda está montado antes de chamar setState
        setState(() {
          _user = user; // Atualiza o usuário
          _isAuthChecked =
              true; // Marca que o estado de autenticação já foi verificado
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Exibe um CircularProgressIndicator enquanto o estado de autenticação está sendo verificado
    if (!_isAuthChecked) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Tela de carregamento inicial
          ),
        ),
      );
    }

    // Após verificar o estado de autenticação, decide qual tela mostrar
    return MaterialApp(
      title: 'Gestor de Hábitos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // === CONFIGURAÇÕES PARA LOCALIZAÇÃO ===
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Suporte para Português do Brasil
      ],
      // ===================================
      // Define a tela inicial com base no estado de autenticação
      home: _user == null ? const LoginPage() : const HomePage(),
    );
  }
}
