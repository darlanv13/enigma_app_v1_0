// lib/main.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enigma_app_v1_0/firebase_options.dart';
import 'package:enigma_app_v1_0/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/evento.dart';
import 'pages/criar_usuario_page.dart';
import 'pages/eventos_page.dart';
import 'pages/fases_grid_page.dart';
import 'pages/login_page.dart';
import 'pages/rank_page.dart';
import 'pages/recuperar_acesso_page.dart';
import 'pages/settings_page.dart';
import 'pages/user_info_page.dart';
import 'providers/eventos_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialize o Firebase com as opções geradas pelo FlutterFire CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Definir rotas para o aplicativo
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provedor de Autenticação
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        // Provedor de Eventos
        ChangeNotifierProvider<EventosProvider>(
          create: (_) => EventosProvider(),
        ),
        // Provedor de Usuário
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        // Provedor de Configurações
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        // Outros provedores podem ser adicionados aqui conforme necessário
      ],
      child: MaterialApp(
        title: 'Enigma App',
        theme: ThemeData(
          primaryColor: Color(0xFF3e8da1), // Cor principal
          scaffoldBackgroundColor:
              Color(0xff0a5c69), // Cor de fundo do Scaffold
          textTheme: TextTheme(
            bodyMedium: TextStyle(
                color: const Color(0xFFFFFFFF)), // Cor do texto principal
          ),
        ),
        // Define a página inicial como EventosPageWrapper
        home: EventosPage(),
        // Rotas nomeadas
        routes: {
          '/login': (context) => LoginPage(),
          '/recuperarSenha': (context) => RecuperarAcessoPage(),
          '/criarUsuario': (context) => CriarUsuarioPage(),
          '/settings': (context) => SettingsPage(),
          '/userInfo': (context) => UserInfoPage(), // Adicionada a rota
          '/rank': (context) {
            final Evento evento =
                ModalRoute.of(context)!.settings.arguments as Evento;
            return RankPage(evento: evento);
          },
          // Não defina "/fasesGrid" aqui, pois será gerada dinamicamente via onGenerateRoute
        },
        // Gerenciamento de rotas dinâmicas
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/fasesGrid') {
            // Verifique se os argumentos são do tipo esperado
            if (settings.arguments is Evento) {
              final Evento evento = settings.arguments as Evento;
              return MaterialPageRoute(
                builder: (context) {
                  return FasesGridPage(evento: evento);
                },
              );
            } else {
              // Argumentos inválidos
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text('Erro')),
                  body: Center(
                      child: Text('Argumentos inválidos para "/fasesGrid".')),
                ),
              );
            }
          }

          // Rotas não definidas
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('Rota não encontrada')),
              body: Center(child: Text('Página não encontrada')),
            ),
          );
        },
        // Rotas desconhecidas
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('Rota desconhecida')),
              body: Center(child: Text('Página não encontrada')),
            ),
          );
        },
      ),
    );
  }
}
