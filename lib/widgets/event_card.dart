// lib/widgets/event_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // Importação do pacote intl
import '../models/evento.dart';

class EventCard extends StatefulWidget {
  final Evento evento;
  final VoidCallback onTap;

  const EventCard({
    Key? key,
    required this.evento,
    required this.onTap,
  }) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador para a animação de escala
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );

    // Define a animação de escala
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
  }

  void _onTapCancel() {
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final Color secundarioColor =
        Colors.white; // Defina sua cor secundária aqui
    final Color destaqueColor =
        Colors.greenAccent; // Cor para destacar o valor do prêmio

    // Instância de NumberFormat para formatação de moedas
    final formatCurrency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem do Evento
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: widget.evento.imgCapaEvento.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.evento.imgCapaEvento,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: destaqueColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey,
                            child: const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.event,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                ),
              ),
              // Valor do Prêmio
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Text(
                  formatCurrency.format(widget.evento.valorPremio),
                  style: TextStyle(
                    color: destaqueColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Título do Evento
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.evento.titulo,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              // Valor de Inscrição e Local do Evento
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Inscrição: ${formatCurrency.format(widget.evento.valorInscricao)}',
                          style: TextStyle(
                            color: secundarioColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Local: ${widget.evento.local}',
                      style: TextStyle(
                        color: secundarioColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
