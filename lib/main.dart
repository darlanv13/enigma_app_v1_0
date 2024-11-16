// lib/main.dart

import 'package:enigma_app_v1_0/models/evento.dart';
import 'package:enigma_app_v1_0/providers/auth_provider.dart';
import 'package:enigma_app_v1_0/providers/eventos_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'pages/eventos_page.dart';
import 'pages/recuperar_acesso_page.dart';
import 'pages/criar_usuario_page.dart';
import 'pages/settings_page.dart';
import 'pages/fases_grid_page.dart'; // Importe a FasesGridPage
import 'firebase_options.dart'; // Importação do arquivo gerado pelo FlutterFire CLI

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
        // Outros provedores podem ser adicionados aqui conforme necessário
      ],
      child: MaterialApp(
        title: 'Seu App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/eventoWrapper': (context) => EventosPageWrapper(),
          '/login': (context) => LoginPage(),
          '/recuperarSenha': (context) => RecuperarAcessoPage(),
          '/criarUsuario': (context) => CriarUsuarioPage(),
          '/settings': (context) => SettingsPageWrapper(),
          // Não defina "/fasesGrid" aqui, pois será gerada dinamicamente via onGenerateRoute
        },
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

          // Rotas adicionais ou página de erro para rotas não encontradas
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('Rota não encontrada')),
              body: Center(child: Text('Página não encontrada')),
            ),
          );
        },
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

// **Wrappers para páginas que dependem de provedores específicos**

class EventosPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Verifica se o usuário está autenticado
    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user == null) {
      // Redireciona para a página de login se o usuário não estiver autenticado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(); // Retorna um scaffold vazio enquanto redireciona
    }

    return ChangeNotifierProvider<EventosProvider>(
      create: (_) => EventosProvider(),
      child: EventosPage(),
    );
  }
}

class SettingsPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      // Redireciona para a página de login se o usuário não estiver autenticado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold();
    }

    return SettingsPage();
  }
}
