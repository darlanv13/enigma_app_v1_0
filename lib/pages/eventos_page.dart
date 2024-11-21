// lib/pages/eventos_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enigma_app_v1_0/providers/eventos_provider.dart';
import 'package:enigma_app_v1_0/models/evento.dart';
import 'package:enigma_app_v1_0/widgets/event_card.dart'; // Importe o EventCard

class EventosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldBody();
  }
}

class ScaffoldBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final eventosProvider = Provider.of<EventosProvider>(context);
    const Color secundarioColor = Color(0xffffffff);
    Color primaryColor = Theme.of(context).primaryColor;
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // Tratar o estado de carregamento de dados do usuário
    if (eventosProvider.isLoadingUserData) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    // Tratar o erro de autenticação ou outros erros
    if (eventosProvider.errorMessage != null) {
      // Redirecionar para a página de login se o usuário não estiver autenticado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: Text(eventosProvider.errorMessage!)),
      );
    }

    // Tratar o estado de carregamento de eventos
    if (eventosProvider.isLoadingEventos) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    // Tratar o erro ao carregar eventos
    if (eventosProvider.eventosErrorMessage != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: Text(eventosProvider.eventosErrorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Widget com informações do usuário
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Material(
                elevation: 2.0,
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      // Foto do usuário
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: eventosProvider.photoURL != null
                            ? NetworkImage(eventosProvider.photoURL!)
                            : AssetImage('assets/images/default_user.gif')
                                as ImageProvider,
                      ),
                      SizedBox(width: 16),
                      // Informações do usuário
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventosProvider.nomeCompleto ?? 'Usuário',
                              style: TextStyle(
                                color: secundarioColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'CPF: ${eventosProvider.cpf ?? 'Não disponível'}',
                              style: TextStyle(
                                color: secundarioColor,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            // Exemplo de progresso (pode ser um valor percentual)
                            Text(
                              'Progresso: ${eventosProvider.progresso}%',
                              style: TextStyle(
                                color: secundarioColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // **Botões de Navegação para Outras Páginas do Usuário**
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botão para RankPage
                  ElevatedButton.icon(
                    onPressed: () {
                      final selectedEvento = eventosProvider.selectedEvento;
                      if (selectedEvento != null) {
                        Navigator.pushNamed(
                          context,
                          '/rank',
                          arguments:
                              selectedEvento, // Passe o Evento selecionado
                        );
                      } else if (eventosProvider.eventos.isNotEmpty) {
                        // Se nenhum Evento estiver selecionado, selecione o primeiro
                        final primeiroEvento = eventosProvider.eventos[0];
                        eventosProvider.selectEvento(primeiroEvento);
                        Navigator.pushNamed(
                          context,
                          '/rank',
                          arguments: primeiroEvento,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Nenhum evento disponível para ranking.')),
                        );
                      }
                    },
                    icon: Icon(Icons.leaderboard),
                    label: Text('Ranking'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: secundarioColor,
                      backgroundColor: primaryColor, // Cor do texto e ícone
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),

                  // Botão para SettingsPage
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    icon: Icon(Icons.settings),
                    label: Text('Configurações'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: secundarioColor,
                      backgroundColor: primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),

                  // Botão para UserInfoPage
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/userInfo');
                    },
                    icon: Icon(Icons.person),
                    label: Text('Perfil'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: secundarioColor,
                      backgroundColor: primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Título da página
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          'Eventos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de eventos em grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Número de colunas
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 0.7, // Proporção do card
                ),
                itemCount: eventosProvider.eventos.length,
                itemBuilder: (context, index) {
                  final evento = eventosProvider.eventos[index];
                  return EventCard(
                    evento: evento,
                    onTap: () {
                      eventosProvider
                          .selectEvento(evento); // Seleciona o evento
                      Navigator.pushNamed(
                        context,
                        '/fasesGrid',
                        arguments: evento, // Passe o objeto Evento diretamente
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
