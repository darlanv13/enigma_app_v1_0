// lib/pages/fases_grid_page.dart

import 'package:enigma_app_v1_0/providers/fases_grid_provider.dart';
import 'package:enigma_app_v1_0/providers/fases_grid_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/evento.dart';
import '../pages/fase_page_wrapper.dart';
import '../pages/settings_page.dart';
import '../widgets/user_info_header.dart';

class FasesGridPage extends StatelessWidget {
  final Evento evento;

  const FasesGridPage({Key? key, required this.evento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FasesGridProvider>(
      create: (_) => FasesGridProvider(evento: evento),
      child: ScaffoldBody(),
    );
  }
}

class ScaffoldBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<FasesGridProvider>(context);
    Color primaryColor = Theme.of(context).primaryColor;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // Tratar o estado de carregamento
    if (logic.isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    // Tratar o erro de autenticação ou outros erros
    if (logic.errorMessage != null) {
      // Redirecionar para a página de login se o usuário não estiver autenticado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: Text(logic.errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              // Cabeçalho com informações do usuário, configurações e informações do evento
              UserInfoHeader(
                valorPremio: logic.evento.valorPremio,
                nomeCompleto: logic.nomeCompleto ?? 'Usuário',
                photoURL: logic.photoURL,
                tipoDesafio: logic.evento.tipoDesafio,
                quantDesafios: logic.evento.quantDesafios,
                local: logic.evento.local,
                onBack: () {
                  Navigator.pop(context);
                },
                onSettings: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),

              // Título da Grade
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            'Fases Disponíveis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Grid de Fases
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: GridView.builder(
                      itemCount: logic.evento.fases.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Número de colunas
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.8, // Ajuste para ficar proporcional
                      ),
                      itemBuilder: (context, index) {
                        final fase = logic.evento.fases[index];
                        final isDesbloqueada = logic.isFaseDesbloqueada(index);
                        final isConcluida = logic.isFaseConcluida(index);

                        return GestureDetector(
                          onTap: isDesbloqueada
                              ? () async {
                                  if (isConcluida) {
                                    _mostrarDialogoFaseConcluida(
                                        context, fase.numeroFase);
                                  } else {
                                    // Navegar para a FasePage
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FasePageWrapper(
                                          evento: logic.evento,
                                          faseIndex: index,
                                        ),
                                      ),
                                    );

                                    // Após retornar da FasePage, recarregar os dados
                                    await logic.reloadData();
                                  }
                                }
                              : null,
                          child: Stack(
                            children: [
                              Card(
                                elevation: 3.0,
                                color: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(10.0)),
                                        child: fase.imgCapaFase.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: fase.imgCapaFase,
                                                fit: BoxFit.scaleDown,
                                                placeholder: (context, url) =>
                                                    Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: primaryColor,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: Colors.grey,
                                                  child: const Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 50.0,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey,
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.white,
                                                  size: 50.0,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          // Número da Fase
                                          Text(
                                            'Fase ${fase.numeroFase}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 5.0),
                                          // Status da Fase
                                          Text(
                                            isConcluida
                                                ? 'Concluída'
                                                : isDesbloqueada
                                                    ? 'Disponível'
                                                    : 'Bloqueada',
                                            style: TextStyle(
                                              color: isConcluida
                                                  ? Colors.greenAccent
                                                  : isDesbloqueada
                                                      ? Colors.yellowAccent
                                                      : Colors.redAccent,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Ícone de cadeado para fases bloqueadas
                              if (!isDesbloqueada)
                                const Center(
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 50.0,
                                  ),
                                ),
                              // Ícone de check para fases concluídas
                              if (isConcluida)
                                const Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.greenAccent,
                                    size: 24.0,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Exibe um diálogo informando que a fase já foi concluída
  void _mostrarDialogoFaseConcluida(BuildContext context, int numeroFase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          title: Text('Fase $numeroFase Concluída'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de conclusão
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                  'Você já concluiu esta fase e não pode acessá-la novamente.'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
