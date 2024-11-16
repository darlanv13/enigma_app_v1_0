// lib/pages/eventos_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enigma_app_v1_0/providers/eventos_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/evento.dart';
import 'fases_grid_page.dart';
import 'settings_page.dart';
import '../widgets/user_info_header.dart';

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
    const Color primaryColor = Color(0xFF3e8da1);
    const Color backgroundColor = Color(0xFF0A5C69);
    const Color secundarioColor = Color(0xffffffff);

    // Tratar o estado de carregamento
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
              child: StreamBuilder<QuerySnapshot>(
                stream: eventosProvider.eventosStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar os eventos.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  final eventos = snapshot.data!.docs
                      .map((doc) => Evento.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          ))
                      .toList();

                  if (eventos.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum evento disponível.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Número de colunas
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 0.7, // Proporção do card
                    ),
                    itemCount: eventos.length,
                    itemBuilder: (context, index) {
                      final evento = eventos[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/fasesGrid',
                            arguments:
                                evento, // Passe o objeto Evento diretamente
                          );
                        },
                        child: Card(
                          color: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  child: evento.imgCapaEvento.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: evento.imgCapaEvento,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey,
                                          child: Icon(
                                            Icons.event,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  evento.titulo,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
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
