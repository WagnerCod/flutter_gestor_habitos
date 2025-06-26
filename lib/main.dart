import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gestor_habitos/login/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // Mantenha para initializeDateFormatting

// Novas importações para localização
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Removido por não ser gerado automaticamente ainda

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  var options = const FirebaseOptions(
    apiKey: "AIzaSyAwF1nTMTUZrL5XalJMHyFlkrk0JNIvXmI",
    authDomain: "flu-gestor-habitos.firebaseapp.com",
    projectId: "flu-gestor-habitos",
    storageBucket: "flu-gestor-habitos.appspot.com",
    messagingSenderId: "544644543277",
    appId:
        "1:544644543277:web:6bccce24b96339df7f19a4", // Use o appId real do seu projeto
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

class GestorHabitosApp extends StatelessWidget {
  const GestorHabitosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Hábitos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginPage(),

      // === NOVAS CONFIGURAÇÕES PARA LOCALIZAÇÃO ===
      // Delegados de localização são responsáveis por fornecer os valores localizados
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Para widgets do Material Design
        GlobalWidgetsLocalizations.delegate, // Para widgets genéricos
        GlobalCupertinoLocalizations
            .delegate, // Para widgets no estilo Cupertino
        // Se você usar a geração automática de AppLocalizations via `flutter gen-l10n`,
        // descomente a linha abaixo e adicione `generate: true` ao `flutter:` no `pubspec.yaml`.
        // AppLocalizations.delegate,
      ],
      // Define as localidades que seu aplicativo suporta
      supportedLocales: const [
        Locale('pt', 'BR'), // Suporte para Português do Brasil
        // Adicione outras localidades se o seu aplicativo for multilíngue, ex:
        // Locale('en', 'US'), // Suporte para Inglês Americano
      ],
      // ===========================================
    );
  }
}
