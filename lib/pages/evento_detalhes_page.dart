import 'package:enigma_app_v1_0/models/evento.dart';
import 'package:flutter/material.dart';

class EventoDetalhesPage extends StatelessWidget {
  final Evento evento;

  EventoDetalhesPage({required this.evento});

  @override
  Widget build(BuildContext context) {
    // Definir as cores personalizadas
    final Color primaryColor = Color(0xFF03E8DA);
    final Color backgroundColor = Color(0xFF0A5C69);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Espaçamento superior e botão de voltar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Botão de voltar
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        evento.titulo,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Imagem temática
              if (evento.imgCapaEvento.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      evento.imgCapaEvento,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              // Detalhes do evento
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      evento.descricao,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tipo de Desafio: ${evento.tipoDesafio}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Valor do Prêmio: ${evento.valorPremio}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Quantidade de Desafios: ${evento.quantDesafios}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Quantidade de Fases: ${evento.quantFases}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Local: ${evento.local}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Status: ${evento.status}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    // Botão para iniciar o evento
                    ElevatedButton(
                      onPressed: () {
                        // Navega para a primeira fase do evento
                        Navigator.pushNamed(
                          context,
                          '/fase',
                          arguments: {
                            'evento': evento,
                            'faseIndex': 0,
                          },
                        );
                      },
                      child: Text('Iniciar Evento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
